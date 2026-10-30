import 'package:flutter/material.dart';

abstract final class AppTokens {
  static const seed = Color(0xFFEC3013);

  static const s1 = 4.0;
  static const s2 = 8.0;
  static const s3 = 12.0;
  static const s4 = 16.0;
  static const s5 = 20.0;
  static const s6 = 24.0;
  static const s8 = 32.0;

  static const radiusS = 12.0;
  static const radiusM = 16.0;
  static const radiusL = 24.0;

  static const touchTarget = 48.0;

  static const medium = 600.0;
  static const expanded = 840.0;
}

extension ColorShade on Color {
  Color darken([double amount = 0.25]) =>
      Color.lerp(this, Colors.black, amount) ?? this;
}
