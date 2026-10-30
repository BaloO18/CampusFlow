import 'package:flutter/material.dart';

import '../../../core/state/campus_state.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/dates.dart';

class SummaryCard extends StatelessWidget {
  const SummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final state = CampusScope.of(context);
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final semaine =
        state.taches
            .where((t) => !t.terminee && Dates.cetteSemaine(t.echeance))
            .toList()
          ..sort((a, b) => a.echeance.compareTo(b.echeance));
    final total = state.taches.length;
    final faites = state.taches.where((t) => t.terminee).length;
    final prochaine = semaine.where((t) => !t.enRetard()).firstOrNull;
    const blanc = Colors.white;

    return Container(
      padding: const EdgeInsets.all(AppTokens.s5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTokens.radiusL),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [scheme.primary, scheme.primary.darken(0.35)],
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.30),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'CETTE SEMAINE',
                  style: text.labelMedium?.copyWith(
                    color: blanc.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              Icon(
                Icons.local_fire_department_rounded,
                color: blanc.withValues(alpha: 0.9),
              ),
            ],
          ),
          const SizedBox(height: AppTokens.s1),
          Text(
            semaine.isEmpty
                ? 'Rien à rendre'
                : '${semaine.length} échéance${semaine.length > 1 ? 's' : ''}',
            style: text.headlineMedium?.copyWith(color: blanc),
          ),
          if (prochaine != null) ...[
            const SizedBox(height: AppTokens.s1),
            Text(
              'Prochaine : ${prochaine.titre} · ${Dates.relatif(prochaine.echeance)} ${Dates.heure(prochaine.echeance)}',
              style: text.bodyMedium?.copyWith(
                color: blanc.withValues(alpha: 0.92),
              ),
            ),
          ],
          const SizedBox(height: AppTokens.s4),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: total == 0 ? 0 : faites / total,
                    minHeight: 8,
                    color: blanc,
                    backgroundColor: blanc.withValues(alpha: 0.25),
                    semanticsLabel: 'Progression',
                  ),
                ),
              ),
              const SizedBox(width: AppTokens.s3),
              Text(
                '$faites/$total faites',
                style: text.labelLarge?.copyWith(
                  color: blanc,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
