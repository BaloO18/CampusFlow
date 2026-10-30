import 'package:campusflow_models/campusflow_models.dart';
import 'package:flutter/material.dart';

import '../../../core/state/campus_state.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/dates.dart';

class ReminderBanner extends StatelessWidget {
  const ReminderBanner({super.key, required this.onTap});

  final ValueChanged<Task> onTap;

  @override
  Widget build(BuildContext context) {
    final state = CampusScope.of(context);
    if (!(state.utilisateur?.rappelsActives ?? false)) {
      return const SizedBox.shrink();
    }
    final maintenant = DateTime.now();
    final rappels = state.taches.where((t) {
      final quand = t.dateRappel;
      return !t.terminee &&
          quand != null &&
          quand.isBefore(maintenant) &&
          t.echeance.isAfter(maintenant);
    }).toList()..sort((a, b) => a.echeance.compareTo(b.echeance));
    if (rappels.isEmpty) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: AppTokens.s4),
      child: Card(
        color: scheme.tertiaryContainer,
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            for (final t in rappels)
              ListTile(
                leading: Icon(
                  Icons.notifications_active_rounded,
                  color: scheme.onTertiaryContainer,
                ),
                title: Text('Rappel : ${t.titre}'),
                subtitle: Text(
                  '${Dates.restant(t.echeance)} · ${Dates.heure(t.echeance)}',
                ),
                textColor: scheme.onTertiaryContainer,
                trailing: Icon(
                  Icons.chevron_right_rounded,
                  color: scheme.onTertiaryContainer,
                ),
                onTap: () => onTap(t),
              ),
          ],
        ),
      ),
    );
  }
}
