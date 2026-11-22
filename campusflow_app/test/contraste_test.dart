import 'dart:math';

import 'package:campusflow/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

double contraste(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  return (max(la, lb) + 0.05) / (min(la, lb) + 0.05);
}

String hex(Color c) =>
    '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';

void main() {
  for (final luminosite in Brightness.values) {
    test('contraste du texte ≥ 4,5:1 en thème ${luminosite.name}', () {
      final theme = AppTheme.build(luminosite);
      final s = theme.colorScheme;
      final paires = {
        'onPrimary / primary': (s.onPrimary, s.primary),
        'onSurface / fond': (s.onSurface, theme.scaffoldBackgroundColor),
        'onSurface / carte': (s.onSurface, theme.cardTheme.color!),
        'onSurfaceVariant / carte': (s.onSurfaceVariant, theme.cardTheme.color!),
        'error / carte': (s.error, theme.cardTheme.color!),
      };
      for (final MapEntry(key: nom, value: (texte, fond)) in paires.entries) {
        final ratio = contraste(texte, fond);
        debugPrint(
          '${luminosite.name} $nom : ${hex(texte)} sur ${hex(fond)} = '
          '${ratio.toStringAsFixed(2)}:1',
        );
        expect(ratio, greaterThanOrEqualTo(4.5), reason: nom);
      }
    });
  }
}
