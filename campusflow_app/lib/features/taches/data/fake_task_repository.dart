import 'package:campusflow_models/campusflow_models.dart';

import '../../../core/api_exception.dart';
import '../domain/task_repository.dart';

class FakeTaskRepository implements TaskRepository {
  FakeTaskRepository({
    this.latence = const Duration(milliseconds: 300),
    this.echouer = false,
    DateTime? maintenant,
  }) : _taches = [
         for (final json in tachesJson(maintenant ?? DateTime.now()))
           Task.fromJson(json),
       ];

  final Duration latence;
  bool echouer;
  List<Task> _taches;
  var _compteur = 100;

  Future<void> _attendre() async {
    await Future<void>.delayed(latence);
    if (echouer) throw const ApiException('Serveur injoignable');
  }

  Task _trouver(String id) => _taches.firstWhere(
    (t) => t.id == id,
    orElse: () => throw const ApiException('Tâche introuvable', statut: 404),
  );

  @override
  Future<List<Task>> lister() async {
    await _attendre();
    return List.unmodifiable(_taches);
  }

  @override
  Future<Task> ajouter(Task task) async {
    await _attendre();
    final creee = Task.fromJson({...task.toJson(), 'id': 't${_compteur++}'});
    _taches = [..._taches, creee];
    return creee;
  }

  @override
  Future<Task> modifier(Task task) async {
    await _attendre();
    _trouver(task.id);
    _taches = [
      for (final t in _taches)
        if (t.id == task.id) task else t,
    ];
    return task;
  }

  @override
  Future<Task> basculer(Task task) async {
    final actuelle = _trouver(task.id);
    return modifier(actuelle.copyWith(terminee: !task.terminee));
  }

  @override
  Future<void> supprimer(String id) async {
    await _attendre();
    _trouver(id);
    _taches = [
      for (final t in _taches)
        if (t.id != id) t,
    ];
  }
}
