import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/layout/disposition.dart';
import '../../../core/router.dart';
import '../../../core/theme/app_tokens.dart';

class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.location, required this.child});

  final String location;
  final Widget child;

  static const _destinations = [
    (
      Routes.taches,
      Icons.event_note_outlined,
      Icons.event_note_rounded,
      'Échéances',
    ),
    (Routes.cours, Icons.school_outlined, Icons.school_rounded, 'Cours'),
    (
      Routes.profil,
      Icons.person_outline_rounded,
      Icons.person_rounded,
      'Profil',
    ),
  ];

  int get _index {
    final i = _destinations.indexWhere((d) => location.startsWith(d.$1));
    return i == -1 ? 0 : i;
  }

  void _aller(BuildContext context, int i) => context.go(_destinations[i].$1);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, contraintes) {
        final largeur = contraintes.maxWidth;
        final page = Disposition(
          etendue: largeur >= AppTokens.expanded,
          child: child,
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
                onDestinationSelected: (i) => _aller(context, i),
                destinations: [
                  for (final (_, icone, iconeActive, libelle) in _destinations)
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
                onDestinationSelected: (i) => _aller(context, i),
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
                  for (final (_, icone, iconeActive, libelle) in _destinations)
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
