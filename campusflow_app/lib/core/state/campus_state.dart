import 'package:campusflow_models/campusflow_models.dart';
import 'package:flutter/material.dart';

class CampusState extends ChangeNotifier {
  CampusState(this.repo);

  final CampusRepository repo;

  User? utilisateur;
  List<Course> cours = const [];
  List<Task> taches = const [];
  bool chargement = false;
  Object? erreur;
  ThemeMode modeTheme = ThemeMode.system;

  Future<void> connexion(String email, String motDePasse) async {
    utilisateur = await repo.connexion(email: email, motDePasse: motDePasse);
    notifyListeners();
    await charger();
  }

  Future<void> deconnexion() async {
    await repo.deconnexion();
    utilisateur = null;
    cours = const [];
    taches = const [];
    notifyListeners();
  }

  Future<void> charger() async {
    chargement = true;
    erreur = null;
    notifyListeners();
    try {
      final (c, t) = await (repo.chargerCours(), repo.chargerTaches()).wait;
      cours = c;
      taches = t;
    } on ParallelWaitError<dynamic, dynamic> catch (e) {
      erreur = e.errors.$1?.error ?? e.errors.$2?.error ?? e;
    } catch (e) {
      erreur = e;
    } finally {
      chargement = false;
      notifyListeners();
    }
  }

  Course? coursDe(String id) {
    for (final c in cours) {
      if (c.id == id) return c;
    }
    return null;
  }

  Task? tache(String id) {
    for (final t in taches) {
      if (t.id == id) return t;
    }
    return null;
  }

  List<Task> tachesDuCours(String coursId) =>
      taches.where((t) => t.coursId == coursId).toList()
        ..sort((a, b) => a.echeance.compareTo(b.echeance));

  Future<Task> enregistrer(Task task) async {
    final sauvee = await repo.enregistrerTache(task);
    _remplacer(sauvee);
    return sauvee;
  }

  Future<void> basculer(Task task) async {
    final avant = task;
    _remplacer(task.copyWith(terminee: !task.terminee));
    try {
      await repo.enregistrerTache(task.copyWith(terminee: !task.terminee));
    } catch (_) {
      _remplacer(avant);
      rethrow;
    }
  }

  Future<void> supprimer(String id) async {
    await repo.supprimerTache(id);
    taches = taches.where((t) => t.id != id).toList();
    notifyListeners();
  }

  Future<void> activerRappels(bool actif) async {
    final u = utilisateur;
    if (u == null) return;
    utilisateur = await repo.mettreAJourUtilisateur(
      u.copyWith(rappelsActives: actif),
    );
    notifyListeners();
  }

  void changerTheme(ThemeMode mode) {
    modeTheme = mode;
    notifyListeners();
  }

  void _remplacer(Task task) {
    final i = taches.indexWhere((t) => t.id == task.id);
    taches = i == -1 ? [...taches, task] : ([...taches]..[i] = task);
    notifyListeners();
  }
}

class CampusScope extends InheritedNotifier<CampusState> {
  const CampusScope({
    super.key,
    required CampusState super.notifier,
    required super.child,
  });

  static CampusState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<CampusScope>();
    final state = scope?.notifier;
    if (state == null) throw StateError('CampusScope introuvable');
    return state;
  }
}
