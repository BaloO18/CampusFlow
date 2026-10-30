import 'package:campusflow_models/campusflow_models.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_tokens.dart';

class CourseAvatar extends StatelessWidget {
  const CourseAvatar({super.key, required this.course, this.size = 44});

  final Course? course;
  final double size;

  @override
  Widget build(BuildContext context) {
    final couleur = Color(course?.couleur ?? AppTokens.seed.toARGB32());
    final nom = course?.nom ?? '?';
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: couleur.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(size * 0.32),
        ),
        child: Text(
          nom.characters.first.toUpperCase(),
          style: TextStyle(
            color: couleur,
            fontWeight: FontWeight.w800,
            fontSize: size * 0.42,
          ),
        ),
      ),
    );
  }
}
