import 'package:campusflow_models/campusflow_models.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api_exception.dart';
import '../../../core/dio_provider.dart';
import '../domain/auth_repository.dart';

class ApiAuthRepository implements AuthRepository {
  ApiAuthRepository(this._dio);

  final Dio _dio;

  @override
  Future<Session> connexion({
    required String email,
    required String motDePasse,
  }) => appelApi(() async {
    final r = await _dio.post<JsonMap>(
      '/login',
      data: {'email': email.trim().toLowerCase(), 'motDePasse': motDePasse},
    );
    final json = r.data ?? const {};
    return (
      jeton: json['jeton'] as String,
      utilisateur: User.fromJson(json['utilisateur'] as JsonMap),
    );
  });

  @override
  Future<User> moi() => appelApi(() async {
    final r = await _dio.get<JsonMap>('/moi');
    return User.fromJson(r.data ?? const {});
  });

  @override
  Future<User> mettreAJour(User utilisateur) => appelApi(() async {
    final r = await _dio.patch<JsonMap>(
      '/utilisateurs/${utilisateur.id}',
      data: {'rappelsActives': utilisateur.rappelsActives},
    );
    return User.fromJson(r.data ?? const {});
  });

  @override
  Future<void> deconnexion() => appelApi(() => _dio.post<void>('/logout'));
}

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.latence = Duration.zero});

  final Duration latence;
  User? _utilisateur;

  @override
  Future<Session> connexion({
    required String email,
    required String motDePasse,
  }) async {
    await Future<void>.delayed(latence);
    final e = email.trim().toLowerCase();
    if (!e.contains('@') || motDePasse.length < 4) {
      throw const ApiException('Email ou mot de passe incorrect', statut: 401);
    }
    final utilisateur = User.fromJson({...utilisateurJson, 'email': e});
    _utilisateur = utilisateur;
    return (jeton: 'jeton-de-test', utilisateur: utilisateur);
  }

  @override
  Future<User> moi() async {
    await Future<void>.delayed(latence);
    return _utilisateur ??
        (throw const ApiException('Jeton absent ou expiré', statut: 401));
  }

  @override
  Future<User> mettreAJour(User utilisateur) async {
    await Future<void>.delayed(latence);
    return _utilisateur = utilisateur;
  }

  @override
  Future<void> deconnexion() async => _utilisateur = null;
}

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => ApiAuthRepository(ref.watch(dioProvider)),
);
