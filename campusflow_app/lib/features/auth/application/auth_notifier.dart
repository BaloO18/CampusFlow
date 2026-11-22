import 'package:campusflow_models/campusflow_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api_exception.dart';
import '../../../core/stockage_jeton.dart';
import '../data/auth_repositories.dart';
import '../domain/auth_repository.dart';

class AuthNotifier extends AsyncNotifier<User?> {
  AuthRepository get _repo => ref.read(authRepositoryProvider);
  StockageJeton get _stockage => ref.read(stockageJetonProvider);

  @override
  Future<User?> build() async {
    if (await _stockage.lire() == null) return null;
    try {
      return await _repo.moi();
    } on ApiException catch (e) {
      if (!e.nonAuthentifie) rethrow;
      await _stockage.effacer();
      return null;
    }
  }

  Future<void> connexion(String email, String motDePasse) async {
    final session = await _repo.connexion(email: email, motDePasse: motDePasse);
    await _stockage.ecrire(session.jeton);
    state = AsyncData(session.utilisateur);
  }

  Future<void> deconnexion() async {
    try {
      await _repo.deconnexion();
    } on ApiException catch (_) {}
    await _stockage.effacer();
    state = const AsyncData(null);
  }

  Future<void> expirer() async {
    if (state.value == null) return;
    await _stockage.effacer();
    state = const AsyncData(null);
  }

  Future<void> activerRappels(bool actif) async {
    final user = state.value;
    if (user == null) return;
    state = AsyncData(
      await _repo.mettreAJour(user.copyWith(rappelsActives: actif)),
    );
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, User?>(
  AuthNotifier.new,
);

final utilisateurProvider = Provider<User?>(
  (ref) => ref.watch(authProvider).value,
);

final utilisateurIdProvider = Provider<String?>(
  (ref) => ref.watch(utilisateurProvider.select((u) => u?.id)),
);
