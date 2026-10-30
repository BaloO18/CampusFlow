import '../models/course.dart';
import '../models/task.dart';
import '../models/user.dart';
import 'campus_repository.dart';
import 'demo_data.dart';
import 'exceptions.dart';

class FakeCampusRepository implements CampusRepository {
  FakeCampusRepository({
    this.latence = const Duration(milliseconds: 600),
    this.echouer = false,
    DateTime? maintenant,
  }) {
    final m = maintenant ?? DateTime.now();
    _cours = [for (final j in coursJson) Course.fromJson(j)];
    _taches = [for (final j in tachesJson(m)) Task.fromJson(j)];
  }

  final Duration latence;
  bool echouer;
  late List<Course> _cours;
  late List<Task> _taches;
  User? _user;
  int _compteur = 100;

  Future<void> _attendre() async {
    await Future<void>.delayed(latence);
    if (echouer) throw const NetworkException();
  }

  @override
  Future<User> connexion({
    required String email,
    required String motDePasse,
  }) async {
    await _attendre();
    final e = email.trim().toLowerCase();
    if (!e.contains('@') || motDePasse.length < 4) {
      throw const AuthException('Email ou mot de passe incorrect');
    }
    final user = User.fromJson({...utilisateurJson, 'email': e});
    _user = user;
    return user;
  }

  @override
  Future<void> deconnexion() async {
    await Future<void>.delayed(latence ~/ 3);
    _user = null;
  }

  @override
  Future<User> mettreAJourUtilisateur(User user) async {
    await Future<void>.delayed(latence ~/ 3);
    _user = user;
    return user;
  }

  User? get utilisateur => _user;

  @override
  Future<List<Course>> chargerCours() async {
    await _attendre();
    return List.unmodifiable(_cours);
  }

  @override
  Future<List<Task>> chargerTaches() async {
    await _attendre();
    return List.unmodifiable(_taches);
  }

  @override
  Future<Task> enregistrerTache(Task task) async {
    await _attendre();
    final aEnregistrer = task.id.isEmpty
        ? Task.fromJson({...task.toJson(), 'id': 't${_compteur++}'})
        : task;
    final i = _taches.indexWhere((t) => t.id == aEnregistrer.id);
    if (i == -1) {
      _taches = [..._taches, aEnregistrer];
    } else {
      _taches = [..._taches]..[i] = aEnregistrer;
    }
    return aEnregistrer;
  }

  @override
  Future<void> supprimerTache(String id) async {
    await _attendre();
    _taches = _taches.where((t) => t.id != id).toList();
  }
}
