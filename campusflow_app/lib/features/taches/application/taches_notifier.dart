import 'package:campusflow_models/campusflow_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_notifier.dart';
import '../data/api_task_repository.dart';
import '../domain/task_repository.dart';

class TachesNotifier extends AsyncNotifier<List<Task>> {
  @override
  Future<List<Task>> build() async {
    if (ref.watch(authProvider) == null) return const [];
    return ref.watch(taskRepositoryProvider).lister();
  }

  TaskRepository get _repo => ref.read(taskRepositoryProvider);

  List<Task> get _actuelles => state.value ?? const [];

  void _remplacer(Task task) {
    state = AsyncData([
      for (final t in _actuelles)
        if (t.id == task.id) task else t,
    ]);
  }

  Future<void> recharger() async {
    ref.invalidateSelf();
    try {
      await future;
    } catch (_) {}
  }

  Future<Task> ajouter(Task task) async {
    final creee = await _repo.ajouter(task);
    state = AsyncData([..._actuelles, creee]);
    return creee;
  }

  Future<Task> modifier(Task task) async {
    final modifiee = await _repo.modifier(task);
    _remplacer(modifiee);
    return modifiee;
  }

  Future<void> basculer(String id) async {
    final avant = _actuelles;
    final task = avant.firstWhere((t) => t.id == id);
    _remplacer(task.copyWith(terminee: !task.terminee));
    try {
      _remplacer(await _repo.basculer(task));
    } catch (_) {
      state = AsyncData(avant);
      rethrow;
    }
  }

  Future<void> supprimer(String id) async {
    await _repo.supprimer(id);
    state = AsyncData([
      for (final t in _actuelles)
        if (t.id != id) t,
    ]);
  }
}

final tachesProvider = AsyncNotifierProvider<TachesNotifier, List<Task>>(
  TachesNotifier.new,
);

final listeTachesProvider = Provider<List<Task>>(
  (ref) => ref.watch(tachesProvider).value ?? const [],
);

final tacheProvider = Provider.family<Task?, String>(
  (ref, id) =>
      ref.watch(listeTachesProvider).where((t) => t.id == id).firstOrNull,
);

final tachesDuCoursProvider = Provider.family<List<Task>, String>(
  (ref, coursId) =>
      ref.watch(listeTachesProvider).where((t) => t.coursId == coursId).toList()
        ..sort((a, b) => a.echeance.compareTo(b.echeance)),
);
