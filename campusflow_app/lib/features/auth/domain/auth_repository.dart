import 'package:campusflow_models/campusflow_models.dart';

typedef Session = ({String jeton, User utilisateur});

abstract interface class AuthRepository {
  Future<Session> connexion({
    required String email,
    required String motDePasse,
  });
  Future<User> moi();
  Future<User> mettreAJour(User utilisateur);
  Future<void> deconnexion();
}
