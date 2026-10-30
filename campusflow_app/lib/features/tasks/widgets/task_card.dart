import 'package:campusflow_models/campusflow_models.dart';
import 'package:flutter/material.dart';

import '../../../core/state/campus_state.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/dates.dart';
import '../../../shared/widgets/course_avatar.dart';

Future<void> basculerTache(BuildContext context, Task task) async {
  final state = CampusScope.of(context);
  final messenger = ScaffoldMessenger.of(context);
  await state.basculer(task);
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(task.terminee ? 'Tâche rouverte' : 'Tâche terminée 🎉'),
        action: SnackBarAction(
          label: 'Annuler',
          onPressed: () {
            final actuelle = state.tache(task.id);
            if (actuelle != null) state.basculer(actuelle);
          },
        ),
      ),
    );
}

class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
    this.selected = false,
  });

  final Task task;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final state = CampusScope.of(context);
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final cours = state.coursDe(task.coursId);
    final retard = task.enRetard();
    final quand =
        '${Dates.relatif(task.echeance)} · ${Dates.heure(task.echeance)}';

    return Dismissible(
      key: ValueKey('swipe-${task.id}'),
      direction: DismissDirection.startToEnd,
      confirmDismiss: (_) async {
        await basculerTache(context, task);
        return false;
      },
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: AppTokens.s6),
        decoration: BoxDecoration(
          color: scheme.primary,
          borderRadius: BorderRadius.circular(AppTokens.radiusL),
        ),
        child: Row(
          children: [
            Icon(
              task.terminee ? Icons.undo_rounded : Icons.check_rounded,
              color: scheme.onPrimary,
            ),
            const SizedBox(width: AppTokens.s2),
            Text(
              task.terminee ? 'Rouvrir' : 'Terminer',
              style: text.titleSmall?.copyWith(color: scheme.onPrimary),
            ),
          ],
        ),
      ),
      child: Card(
        color: selected
            ? Color.alphaBlend(
                scheme.primary.withValues(alpha: 0.10),
                Theme.of(context).cardTheme.color ?? scheme.surface,
              )
            : null,
        shape: selected
            ? RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTokens.radiusL),
                side: BorderSide(color: scheme.primary, width: 1.5),
              )
            : null,
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: onTap,
                child: Semantics(
                  button: true,
                  selected: selected,
                  excludeSemantics: true,
                  label:
                      '${task.titre}, ${cours?.nom ?? ''}, échéance $quand'
                      '${retard ? ', en retard' : ''}'
                      '${task.terminee ? ', terminée' : ''}',
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppTokens.s4,
                      AppTokens.s4,
                      AppTokens.s1,
                      AppTokens.s4,
                    ),
                    child: Row(
                      children: [
                        CourseAvatar(course: cours),
                        const SizedBox(width: AppTokens.s3),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                task.titre,
                                style: text.titleMedium?.copyWith(
                                  decoration: task.terminee
                                      ? TextDecoration.lineThrough
                                      : null,
                                  color: task.terminee
                                      ? scheme.onSurfaceVariant
                                      : null,
                                ),
                              ),
                              const SizedBox(height: AppTokens.s1),
                              Wrap(
                                spacing: AppTokens.s2,
                                runSpacing: AppTokens.s1,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  _Meta(
                                    icon: Icons.schedule_rounded,
                                    label: quand,
                                    color: retard ? scheme.error : null,
                                  ),
                                  Text(
                                    cours?.nom ?? 'Sans cours',
                                    style: text.bodySmall?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                    ),
                                  ),
                                  if (retard) _Badge('En retard', scheme.error),
                                  if (task.rappel != null && !task.terminee)
                                    Icon(
                                      Icons.notifications_active_outlined,
                                      size: 14,
                                      color: scheme.onSurfaceVariant,
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            IconButton(
              tooltip: task.terminee
                  ? 'Marquer comme à faire'
                  : 'Marquer comme fait',
              onPressed: () => basculerTache(context, task),
              icon: Icon(
                task.terminee
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: task.terminee ? scheme.primary : scheme.outline,
                size: 28,
              ),
            ),
            const SizedBox(width: AppTokens.s1),
          ],
        ),
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.label, this.color});

  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: c),
        const SizedBox(width: 3),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: c, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge(this.label, this.color);

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      label,
      style: Theme.of(context).textTheme.labelSmall
          ?.copyWith(color: color, fontWeight: FontWeight.w700),
    ),
  );
}
