import '../models/course.dart';
import '../models/task.dart';
import '../models/user.dart';

abstract interface class CampusRepository {
  Future<User> connexion({required String email, required String motDePasse});
  Future<void> deconnexion();
  Future<User> mettreAJourUtilisateur(User user);
  Future<List<Course>> chargerCours();
  Future<List<Task>> chargerTaches();
  Future<Task> enregistrerTache(Task task);
  Future<void> supprimerTache(String id);
}
