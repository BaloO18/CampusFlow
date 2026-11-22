import 'dart:convert';
import 'dart:typed_data';

import 'package:campusflow/core/dio_provider.dart';
import 'package:campusflow/core/stockage_jeton.dart';
import 'package:campusflow/features/auth/application/auth_notifier.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support.dart';

class _Serveur implements HttpClientAdapter {
  _Serveur(this.statut);

  final int statut;
  final entetes = <Map<String, dynamic>>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    entetes.add(options.headers);
    return ResponseBody.fromString(
      jsonEncode(statut == 401 ? {'message': 'Jeton absent'} : []),
      statut,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  group('JetonInterceptor', () {
    test('ajoute le jeton à chaque requête', () async {
      final serveur = _Serveur(200);
      final dio = Dio()
        ..httpClientAdapter = serveur
        ..interceptors.add(
          JetonInterceptor(lireJeton: () async => 'abc', surExpiration: () {}),
        );
      await dio.get<dynamic>('/taches');
      expect(serveur.entetes.single['Authorization'], 'Bearer abc');
    });

    test('prévient quand le serveur répond 401', () async {
      var expire = false;
      final dio = Dio()
        ..httpClientAdapter = _Serveur(401)
        ..interceptors.add(
          JetonInterceptor(
            lireJeton: () async => 'perime',
            surExpiration: () => expire = true,
          ),
        );
      await expectLater(dio.get<dynamic>('/taches'), throwsA(anything));
      expect(expire, isTrue);
    });
  });

  group('AuthNotifier', () {
    test('la connexion range le jeton dans le stockage', () async {
      final stockage = StockageJetonMemoire();
      final container = ProviderContainer(
        overrides: surcharges(stockage: stockage),
        retry: (_, _) => null,
      );
      addTearDown(container.dispose);
      expect(await container.read(authProvider.future), isNull);

      await container
          .read(authProvider.notifier)
          .connexion('amina@campus.bf', '1234');
      expect(stockage.jeton, isNotNull);
      expect(container.read(utilisateurProvider)?.nom, 'Amina');

      await container.read(authProvider.notifier).expirer();
      expect(stockage.jeton, isNull);
      expect(container.read(utilisateurProvider), isNull);
    });
  });
}
