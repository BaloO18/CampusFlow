import 'package:campusflow_models/campusflow_models.dart';

abstract interface class CoursRepository {
  Future<List<Course>> lister();
}
