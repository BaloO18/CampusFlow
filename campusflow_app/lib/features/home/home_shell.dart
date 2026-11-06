import 'package:flutter/material.dart';

import '../../core/theme/app_tokens.dart';
import '../courses/courses_screen.dart';
import '../profile/profile_screen.dart';
import '../tasks/tasks_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _destinations = [
    (Icons.event_note_outlined, Icons.event_note_rounded, 'Échéances'),
    (Icons.school_outlined, Icons.school_rounded, 'Cours'),
    (Icons.person_outline_rounded, Icons.person_rounded, 'Profil'),
  ];

  void _aller(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, contraintes) {
        final largeur = contraintes.maxWidth;
        final page = IndexedStack(
          index: _index,
          children: [
            TasksScreen(
              etendu: largeur >= AppTokens.expanded,
              onOpenProfile: () => _aller(2),
            ),
            const CoursesScreen(),
            const ProfileScreen(),
          ],
        );

        if (largeur < AppTokens.medium) {
          return Scaffold(
            body: page,
            bottomNavigationBar: DecoratedBox(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color:
                        Theme.of(context).dividerTheme.color ??
                        Colors.transparent,
                  ),
                ),
              ),
              child: NavigationBar(
                selectedIndex: _index,
                onDestinationSelected: _aller,
                destinations: [
                  for (final (icone, iconeActive, libelle) in _destinations)
                    NavigationDestination(
                      icon: Icon(icone),
                      selectedIcon: Icon(iconeActive),
                      label: libelle,
                    ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          body: Row(
            children: [
              NavigationRail(
                selectedIndex: _index,
                onDestinationSelected: _aller,
                labelType: NavigationRailLabelType.all,
                groupAlignment: -0.85,
                leading: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppTokens.s4),
                  child: Icon(
                    Icons.event_available_rounded,
                    size: 32,
                    color: Theme.of(context).colorScheme.primary,
                    semanticLabel: 'CampusFlow',
                  ),
                ),
                destinations: [
                  for (final (icone, iconeActive, libelle) in _destinations)
                    NavigationRailDestination(
                      icon: Icon(icone),
                      selectedIcon: Icon(iconeActive),
                      label: Text(libelle),
                    ),
                ],
              ),
              const VerticalDivider(width: 1),
              Expanded(child: page),
            ],
          ),
        );
      },
    );
  }
}
