import 'package:flutter/material.dart';

import '../../core/state/campus_state.dart';
import '../../core/theme/app_tokens.dart';

class AsyncContent extends StatelessWidget {
  const AsyncContent({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final state = CampusScope.of(context);
    final erreur = state.erreur;
    if (state.chargement && state.taches.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(semanticsLabel: 'Chargement'),
      );
    }
    if (erreur != null && state.taches.isEmpty) {
      return EmptyState(
        icon: Icons.cloud_off_rounded,
        title: 'Impossible de charger les échéances',
        message: '$erreur',
        action: FilledButton.icon(
          onPressed: state.charger,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Réessayer'),
        ),
      );
    }
    return child;
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.s8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppTokens.s5),
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 36, color: scheme.primary),
            ),
            const SizedBox(height: AppTokens.s4),
            Text(title, style: text.titleMedium, textAlign: TextAlign.center),
            if (message case final m?) ...[
              const SizedBox(height: AppTokens.s1),
              Text(
                m,
                textAlign: TextAlign.center,
                style: text.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
            if (action case final a?) ...[
              const SizedBox(height: AppTokens.s5),
              SizedBox(width: 220, child: a),
            ],
          ],
        ),
      ),
    );
  }
}
