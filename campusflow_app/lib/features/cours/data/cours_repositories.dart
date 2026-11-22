import 'package:campusflow_models/campusflow_models.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api_exception.dart';
import '../../../core/dio_provider.dart';
import '../domain/cours_repository.dart';

class ApiCoursRepository implements CoursRepository {
  ApiCoursRepository(this._dio);

  final Dio _dio;

  @override
  Future<List<Course>> lister() => appelApi(() async {
    final r = await _dio.get<List<dynamic>>('/cours');
    return [
      for (final json in r.data ?? const []) Course.fromJson(json as JsonMap),
    ];
  });
}

class FakeCoursRepository implements CoursRepository {
  FakeCoursRepository({this.latence = Duration.zero});

  final Duration latence;

  @override
  Future<List<Course>> lister() async {
    await Future<void>.delayed(latence);
    return [for (final json in coursJson) Course.fromJson(json)];
  }
}

final coursRepositoryProvider = Provider<CoursRepository>(
  (ref) => ApiCoursRepository(ref.watch(dioProvider)),
);
