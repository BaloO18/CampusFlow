import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/login_screen.dart';
import '../features/courses/course_tasks_screen.dart';
import '../features/courses/courses_screen.dart';
import '../features/home/home_shell.dart';
import '../features/profile/profile_screen.dart';
import '../features/tasks/task_detail_screen.dart';
import '../features/tasks/task_form_screen.dart';
import '../features/tasks/tasks_screen.dart';
import 'state/campus_state.dart';

abstract final class Routes {
  static const login = '/login';
  static const taches = '/taches';
  static const nouvelle = '/taches/nouvelle';
  static const cours = '/cours';
  static const profil = '/profil';

  static String tache(String id) => '/taches/$id';
  static String modifier(String id) => '/taches/$id/modifier';
  static String coursDetail(String id) => '/cours/$id';
}

GoRouter creerRouter(CampusState etat) {
  final racine = GlobalKey<NavigatorState>();
  final connexion = ValueNotifier(etat.utilisateur != null);
  etat.addListener(() => connexion.value = etat.utilisateur != null);
  return GoRouter(
    navigatorKey: racine,
    initialLocation: Routes.taches,
    refreshListenable: connexion,
    redirect: (context, state) {
      final connecte = connexion.value;
      final surLogin = state.matchedLocation == Routes.login;
      if (!connecte) return surLogin ? null : Routes.login;
      if (surLogin) return Routes.taches;
      return null;
    },
    routes: [
      GoRoute(path: Routes.login, builder: (_, _) => const LoginScreen()),
      ShellRoute(
        builder: (_, state, child) =>
            HomeShell(location: state.matchedLocation, child: child),
        routes: [
          GoRoute(
            path: Routes.taches,
            builder: (_, _) => const TasksScreen(),
            routes: [
              GoRoute(
                path: 'nouvelle',
                parentNavigatorKey: racine,
                pageBuilder: (_, state) => MaterialPage(
                  fullscreenDialog: true,
                  child: TaskFormScreen(
                    coursId: state.uri.queryParameters['cours'],
                  ),
                ),
              ),
              GoRoute(
                path: ':id',
                parentNavigatorKey: racine,
                builder: (_, state) =>
                    TaskDetailScreen(taskId: state.pathParameters['id']!),
                routes: [
                  GoRoute(
                    path: 'modifier',
                    parentNavigatorKey: racine,
                    pageBuilder: (context, state) => MaterialPage(
                      fullscreenDialog: true,
                      child: TaskFormScreen(
                        task: CampusScope.of(
                          context,
                        ).tache(state.pathParameters['id']!),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: Routes.cours,
            builder: (_, _) => const CoursesScreen(),
            routes: [
              GoRoute(
                path: ':id',
                parentNavigatorKey: racine,
                builder: (_, state) =>
                    CourseTasksScreen(coursId: state.pathParameters['id']!),
              ),
            ],
          ),
          GoRoute(
            path: Routes.profil,
            builder: (_, _) => const ProfileScreen(),
          ),
        ],
      ),
    ],
  );
}
