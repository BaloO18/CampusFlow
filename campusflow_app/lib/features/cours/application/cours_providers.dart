import 'package:campusflow_models/campusflow_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_notifier.dart';
import '../data/cours_repositories.dart';

final coursAsyncProvider = FutureProvider<List<Course>>((ref) async {
  if (ref.watch(authProvider) == null) return const [];
  return ref.watch(coursRepositoryProvider).lister();
});

final coursProvider = Provider<List<Course>>(
  (ref) => ref.watch(coursAsyncProvider).value ?? const [],
);

final coursParIdProvider = Provider.family<Course?, String>(
  (ref, id) => ref.watch(coursProvider).where((c) => c.id == id).firstOrNull,
);
