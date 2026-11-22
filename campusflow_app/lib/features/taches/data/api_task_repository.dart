import 'package:campusflow_models/campusflow_models.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api_exception.dart';
import '../../../core/dio_provider.dart';
import '../domain/task_repository.dart';

class ApiTaskRepository implements TaskRepository {
  ApiTaskRepository(this._dio);

  final Dio _dio;

  Task _lire(Response<dynamic> r) => Task.fromJson(r.data as JsonMap);

  @override
  Future<List<Task>> lister() => appelApi(() async {
    final r = await _dio.get<List<dynamic>>('/taches');
    return [
      for (final json in r.data ?? const []) Task.fromJson(json as JsonMap),
    ];
  });

  @override
  Future<Task> ajouter(Task task) => appelApi(
    () async =>
        _lire(await _dio.post('/taches', data: task.toJson()..remove('id'))),
  );

  @override
  Future<Task> modifier(Task task) => appelApi(
    () async =>
        _lire(await _dio.put('/taches/${task.id}', data: task.toJson())),
  );

  @override
  Future<Task> basculer(Task task) => appelApi(
    () async => _lire(
      await _dio.patch(
        '/taches/${task.id}',
        data: {'terminee': !task.terminee},
      ),
    ),
  );

  @override
  Future<void> supprimer(String id) =>
      appelApi(() => _dio.delete<void>('/taches/$id'));
}

final taskRepositoryProvider = Provider<TaskRepository>(
  (ref) => ApiTaskRepository(ref.watch(dioProvider)),
);
