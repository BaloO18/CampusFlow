import 'package:campusflow_models/campusflow_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final campusRepositoryProvider = Provider<CampusRepository>(
  (ref) => FakeCampusRepository(),
);

class AuthNotifier extends Notifier<User?> {
  @override
  User? build() => null;

  Future<void> connexion(String email, String motDePasse) async {
    state = await ref
        .read(campusRepositoryProvider)
        .connexion(email: email, motDePasse: motDePasse);
  }

  Future<void> deconnexion() async {
    await ref.read(campusRepositoryProvider).deconnexion();
    state = null;
  }

  Future<void> activerRappels(bool actif) async {
    final user = state;
    if (user == null) return;
    state = await ref
        .read(campusRepositoryProvider)
        .mettreAJourUtilisateur(user.copyWith(rappelsActives: actif));
  }
}

final authProvider = NotifierProvider<AuthNotifier, User?>(AuthNotifier.new);
