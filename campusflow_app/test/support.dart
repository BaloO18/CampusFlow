import 'package:campusflow/features/auth/application/auth_notifier.dart';
import 'package:campusflow/features/cours/data/cours_repositories.dart';
import 'package:campusflow/features/taches/data/api_task_repository.dart';
import 'package:campusflow/features/taches/data/fake_task_repository.dart';
import 'package:campusflow_models/campusflow_models.dart';
import 'package:flutter_riverpod/misc.dart';

List<Override> surcharges({FakeTaskRepository? taches}) => [
  campusRepositoryProvider.overrideWithValue(
    FakeCampusRepository(latence: Duration.zero),
  ),
  taskRepositoryProvider.overrideWithValue(
    taches ?? FakeTaskRepository(latence: Duration.zero),
  ),
  coursRepositoryProvider.overrideWithValue(FakeCoursRepository()),
];
