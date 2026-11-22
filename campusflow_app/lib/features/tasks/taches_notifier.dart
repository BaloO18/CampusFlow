import 'package:campusflow_models/campusflow_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TachesNotifier extends Notifier<List<Task>> {
  var _compteur = 100;

  @override
  List<Task> build() => [
    for (final json in tachesJson(DateTime.now())) Task.fromJson(json),
  ];

  Task ajouter(Task task) {
    final nouvelle = Task.fromJson({...task.toJson(), 'id': 't${_compteur++}'});
    state = [...state, nouvelle];
    return nouvelle;
  }

  void modifier(Task task) {
    state = [
      for (final t in state)
        if (t.id == task.id) task else t,
    ];
  }

  void basculer(String id) {
    state = [
      for (final t in state) t.id == id ? t.copyWith(terminee: !t.terminee) : t,
    ];
  }

  void supprimer(String id) {
    state = [
      for (final t in state)
        if (t.id != id) t,
    ];
  }
}

final tachesProvider = NotifierProvider<TachesNotifier, List<Task>>(
  TachesNotifier.new,
);

final tacheProvider = Provider.family<Task?, String>(
  (ref, id) => ref.watch(tachesProvider).where((t) => t.id == id).firstOrNull,
);

final coursProvider = Provider<List<Course>>(
  (ref) => [for (final json in coursJson) Course.fromJson(json)],
);

final coursParIdProvider = Provider.family<Course?, String>(
  (ref, id) => ref.watch(coursProvider).where((c) => c.id == id).firstOrNull,
);

final tachesDuCoursProvider = Provider.family<List<Task>, String>(
  (ref, coursId) =>
      ref.watch(tachesProvider).where((t) => t.coursId == coursId).toList()
        ..sort((a, b) => a.echeance.compareTo(b.echeance)),
);
