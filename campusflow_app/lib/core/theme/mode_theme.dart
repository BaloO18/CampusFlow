import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ModeThemeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.system;

  void choisir(ThemeMode mode) => state = mode;
}

final modeThemeProvider = NotifierProvider<ModeThemeNotifier, ThemeMode>(
  ModeThemeNotifier.new,
);
