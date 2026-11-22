import 'package:campusflow/core/stockage_jeton.dart';
import 'package:campusflow/features/auth/data/auth_repositories.dart';
import 'package:campusflow/features/cours/data/cours_repositories.dart';
import 'package:campusflow/features/taches/data/api_task_repository.dart';
import 'package:campusflow/features/taches/data/fake_task_repository.dart';
import 'package:flutter_riverpod/misc.dart';

List<Override> surcharges({
  FakeTaskRepository? taches,
  StockageJeton? stockage,
}) => [
  authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
  stockageJetonProvider.overrideWithValue(stockage ?? StockageJetonMemoire()),
  taskRepositoryProvider.overrideWithValue(
    taches ?? FakeTaskRepository(latence: Duration.zero),
  ),
  coursRepositoryProvider.overrideWithValue(FakeCoursRepository()),
];
