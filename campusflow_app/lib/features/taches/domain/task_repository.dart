import 'package:campusflow_models/campusflow_models.dart';

abstract interface class TaskRepository {
  Future<List<Task>> lister();
  Future<Task> ajouter(Task task);
  Future<Task> modifier(Task task);
  Future<Task> basculer(Task task);
  Future<void> supprimer(String id);
}
