import 'package:campusflow_models/campusflow_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

import 'core/router.dart';
import 'core/state/campus_state.dart';
import 'core/theme/app_theme.dart';

class CampusFlowApp extends StatefulWidget {
  const CampusFlowApp({super.key, this.repository});

  final CampusRepository? repository;

  @override
  State<CampusFlowApp> createState() => _CampusFlowAppState();
}

class _CampusFlowAppState extends State<CampusFlowApp> {
  late final CampusState _state = CampusState(
    widget.repository ?? FakeCampusRepository(),
  );
  late final GoRouter _router = creerRouter(_state);

  @override
  void dispose() {
    _router.dispose();
    _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CampusScope(
      notifier: _state,
      child: ListenableBuilder(
        listenable: _state,
        builder: (context, _) => MaterialApp.router(
          title: 'CampusFlow',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.build(Brightness.light),
          darkTheme: AppTheme.build(Brightness.dark),
          themeMode: _state.modeTheme,
          locale: const Locale('fr'),
          supportedLocales: const [Locale('fr')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          routerConfig: _router,
        ),
      ),
    );
  }
}
