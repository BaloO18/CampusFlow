import 'dart:convert';
import 'dart:typed_data';

import 'package:campusflow/core/api_exception.dart';
import 'package:campusflow/features/taches/data/api_task_repository.dart';
import 'package:campusflow/features/taches/data/fake_task_repository.dart';
import 'package:campusflow_models/campusflow_models.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _ServeurTest implements HttpClientAdapter {
  _ServeurTest(this.repondre);

  final (int, Object?) Function(RequestOptions options) repondre;
  final requetes = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requetes.add(options);
    final (statut, corps) = repondre(options);
    return ResponseBody.fromString(
      jsonEncode(corps),
      statut,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

final _json = {
  'id': 't1',
  'titre': 'Projet Flutter',
  'coursId': 'c1',
  'echeance': '2026-11-27T17:00:00',
  'terminee': false,
};

void main() {
  group('FakeTaskRepository', () {
    test('ajoute, coche et supprime en mémoire', () async {
      final repo = FakeTaskRepository(latence: Duration.zero);
      expect(await repo.lister(), hasLength(6));
      final creee = await repo.ajouter(
        Task(id: '', titre: 'QCM', coursId: 'c1', echeance: DateTime(2030)),
      );
      expect(creee.id, isNotEmpty);
      expect((await repo.basculer(creee)).terminee, isTrue);
      await repo.supprimer(creee.id);
      expect(await repo.lister(), hasLength(6));
    });

    test('renvoie une ApiException quand le serveur est coupé', () async {
      final repo = FakeTaskRepository(latence: Duration.zero, echouer: true);
      await expectLater(repo.lister(), throwsA(isA<ApiException>()));
    });
  });

  group('ApiTaskRepository', () {
    test('GET /taches puis PATCH /taches/:id pour cocher', () async {
      final serveur = _ServeurTest(
        (o) => o.method == 'GET'
            ? (200, [_json])
            : (200, {..._json, 'terminee': true}),
      );
      final dio = Dio()..httpClientAdapter = serveur;
      final repo = ApiTaskRepository(dio);

      final taches = await repo.lister();
      expect(taches.single.titre, 'Projet Flutter');

      final cochee = await repo.basculer(taches.single);
      expect(cochee.terminee, isTrue);
      expect(serveur.requetes.last.method, 'PATCH');
      expect(serveur.requetes.last.path, '/taches/t1');
      expect(serveur.requetes.last.data, {'terminee': true});
    });

    test('POST sans identifiant et DELETE', () async {
      final serveur = _ServeurTest(
        (o) => o.method == 'POST' ? (201, {..._json, 'id': 'abc'}) : (200, {}),
      );
      final repo = ApiTaskRepository(Dio()..httpClientAdapter = serveur);
      final creee = await repo.ajouter(Task.fromJson({..._json, 'id': 'x'}));
      expect(creee.id, 'abc');
      expect((serveur.requetes.first.data as Map).containsKey('id'), isFalse);
      await repo.supprimer('abc');
      expect(serveur.requetes.last.method, 'DELETE');
    });

    test('une réponse 401 devient une ApiException non authentifiée', () async {
      final serveur = _ServeurTest((_) => (401, {'message': 'Jeton absent'}));
      final repo = ApiTaskRepository(Dio()..httpClientAdapter = serveur);
      await expectLater(
        repo.lister(),
        throwsA(
          isA<ApiException>().having((e) => e.nonAuthentifie, '401', isTrue),
        ),
      );
    });
  });
}
