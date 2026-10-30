import 'package:flutter/material.dart';

import '../../core/state/campus_state.dart';
import '../../core/theme/app_tokens.dart';
import '../../shared/widgets/section_header.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const _themes = [
    (ThemeMode.system, 'Système', Icons.brightness_auto_rounded),
    (ThemeMode.light, 'Clair', Icons.light_mode_rounded),
    (ThemeMode.dark, 'Sombre', Icons.dark_mode_rounded),
  ];

  void _choisirTheme(BuildContext context) {
    final state = CampusScope.of(context);
    showModalBottomSheet<void>(
      context: context,
      builder: (c) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: AppTokens.s2),
              child: Text(
                'Thème',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
            for (final (mode, label, icon) in _themes)
              ListTile(
                leading: Icon(icon),
                title: Text(label),
                trailing: state.modeTheme == mode
                    ? const Icon(Icons.check_rounded)
                    : null,
                selected: state.modeTheme == mode,
                onTap: () {
                  state.changerTheme(mode);
                  Navigator.pop(c);
                },
              ),
            const SizedBox(height: AppTokens.s2),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = CampusScope.of(context);
    final user = state.utilisateur;
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final nom = user?.nom ?? '';
    final aFaire = state.taches.where((t) => !t.terminee).length;
    final retard = state.taches.where((t) => t.enRetard()).length;
    final faites = state.taches.where((t) => t.terminee).length;
    final theme = _themes.firstWhere((t) => t.$1 == state.modeTheme).$2;
    const blanc = Colors.white;

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [scheme.primary, scheme.primary.darken(0.35)],
              ),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(AppTokens.radiusL + 8),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppTokens.s6,
                  AppTokens.s6,
                  AppTokens.s6,
                  AppTokens.s8,
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: blanc,
                      child: Text(
                        nom.isEmpty ? '?' : nom.characters.first,
                        style: text.headlineMedium?.copyWith(
                          color: scheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppTokens.s3),
                    Text(
                      nom,
                      style: text.headlineSmall?.copyWith(color: blanc),
                    ),
                    Text(
                      user?.email ?? '',
                      style: text.bodyMedium?.copyWith(
                        color: blanc.withValues(alpha: 0.9),
                      ),
                    ),
                    if (user?.formation case final f?) ...[
                      const SizedBox(height: AppTokens.s3),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTokens.s3,
                          vertical: AppTokens.s1 + 2,
                        ),
                        decoration: BoxDecoration(
                          color: blanc.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          f,
                          style: text.labelLarge?.copyWith(color: blanc),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppTokens.s4,
              AppTokens.s4,
              AppTokens.s4,
              0,
            ),
            child: Row(
              children: [
                _Stat(valeur: aFaire, label: 'À faire', color: scheme.primary),
                const SizedBox(width: AppTokens.s3),
                _Stat(valeur: retard, label: 'En retard', color: scheme.error),
                const SizedBox(width: AppTokens.s3),
                _Stat(
                  valeur: faites,
                  label: 'Terminées',
                  color: const Color(0xFF2E7D32),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTokens.s4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SectionHeader('Préférences'),
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      SwitchListTile(
                        secondary: const _IconeTuile(
                          Icons.notifications_rounded,
                        ),
                        title: const Text('Rappels'),
                        subtitle: const Text('Avant chaque échéance'),
                        value: user?.rappelsActives ?? false,
                        onChanged: state.activerRappels,
                      ),
                      const Divider(indent: 72),
                      ListTile(
                        leading: const _IconeTuile(Icons.palette_rounded),
                        title: const Text('Thème'),
                        subtitle: Text(theme),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => _choisirTheme(context),
                      ),
                    ],
                  ),
                ),
                const SectionHeader('Compte'),
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      const ListTile(
                        leading: _IconeTuile(Icons.info_outline_rounded),
                        title: Text('À propos'),
                        subtitle: Text('CampusFlow 1.0'),
                      ),
                      const Divider(indent: 72),
                      ListTile(
                        leading: _IconeTuile(
                          Icons.logout_rounded,
                          color: scheme.error,
                        ),
                        title: Text(
                          'Déconnexion',
                          style: TextStyle(
                            color: scheme.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onTap: state.deconnexion,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppTokens.s8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.valeur, required this.label, required this.color});

  final int valeur;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Expanded(
      child: MergeSemantics(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppTokens.s4,
              horizontal: AppTokens.s2,
            ),
            child: Column(
              children: [
                Text(
                  '$valeur',
                  style: text.headlineMedium?.copyWith(color: color),
                ),
                Text(
                  label,
                  style: text.labelMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IconeTuile extends StatelessWidget {
  const _IconeTuile(this.icon, {this.color});

  final IconData icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.primary;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppTokens.radiusS),
      ),
      child: Icon(icon, color: c, size: 22),
    );
  }
}
