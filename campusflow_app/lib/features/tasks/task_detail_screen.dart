import 'package:campusflow_models/campusflow_models.dart';
import 'package:flutter/material.dart';

import '../../core/state/campus_state.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/dates.dart';
import 'task_form_screen.dart';
import 'widgets/task_card.dart';

class TaskDetailScreen extends StatelessWidget {
  const TaskDetailScreen({super.key, required this.taskId});

  final String taskId;

  @override
  Widget build(BuildContext context) {
    final existe = CampusScope.of(context).tache(taskId) != null;
    return Scaffold(
      appBar: existe ? null : AppBar(),
      body: existe
          ? TaskDetailView(
              taskId: taskId,
              onDeleted: () => Navigator.of(context).pop(),
            )
          : const SizedBox.shrink(),
    );
  }
}

class TaskDetailView extends StatelessWidget {
  const TaskDetailView({
    super.key,
    required this.taskId,
    this.embedded = false,
    this.onDeleted,
  });

  final String taskId;
  final bool embedded;
  final VoidCallback? onDeleted;

  Future<void> _supprimer(BuildContext context) async {
    final state = CampusScope.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        icon: const Icon(Icons.delete_outline_rounded),
        title: const Text('Supprimer la tâche ?'),
        content: const Text('Cette action est définitive.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (ok ?? false) {
      await state.supprimer(taskId);
      onDeleted?.call();
    }
  }

  List<Widget> _actions(BuildContext context, Task task) => [
    IconButton(
      tooltip: 'Modifier',
      icon: const Icon(Icons.edit_rounded),
      onPressed: () => ouvrirFormulaire(context, task: task),
    ),
    IconButton(
      tooltip: 'Supprimer',
      icon: const Icon(Icons.delete_outline_rounded),
      onPressed: () => _supprimer(context),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final state = CampusScope.of(context);
    final task = state.tache(taskId);
    if (task == null) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final cours = state.coursDe(task.coursId);
    final couleur = Color(cours?.couleur ?? AppTokens.seed.toARGB32());
    final retard = task.enRetard();
    const blanc = Colors.white;

    final statut = Wrap(
      spacing: AppTokens.s2,
      runSpacing: AppTokens.s2,
      children: [
        _Pastille(
          label: cours?.nom ?? 'Sans cours',
          icon: Icons.school_rounded,
        ),
        _Pastille(
          label: task.terminee
              ? 'Terminée'
              : retard
              ? 'En retard'
              : Dates.restant(task.echeance),
          icon: task.terminee
              ? Icons.check_circle_rounded
              : retard
              ? Icons.warning_amber_rounded
              : Icons.hourglass_bottom_rounded,
        ),
      ],
    );

    final degrade = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [couleur, couleur.darken(0.4)],
    );

    final entete = embedded
        ? SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(AppTokens.s4),
              padding: const EdgeInsets.all(AppTokens.s5),
              decoration: BoxDecoration(
                gradient: degrade,
                borderRadius: BorderRadius.circular(AppTokens.radiusL),
              ),
              child: IconTheme(
                data: const IconThemeData(color: blanc),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: statut),
                        ..._actions(context, task),
                      ],
                    ),
                    const SizedBox(height: AppTokens.s3),
                    Semantics(
                      header: true,
                      child: Text(
                        task.titre,
                        style: text.headlineSmall?.copyWith(color: blanc),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        : SliverAppBar(
            pinned: true,
            expandedHeight: 220,
            backgroundColor: couleur.darken(0.2),
            foregroundColor: blanc,
            iconTheme: const IconThemeData(color: blanc),
            actions: _actions(context, task),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsetsDirectional.only(
                start: 56,
                end: AppTokens.s4,
                bottom: AppTokens.s4,
              ),
              expandedTitleScale: 1.6,
              title: Text(
                task.titre,
                style: text.titleLarge?.copyWith(color: blanc),
              ),
              background: DecoratedBox(
                decoration: BoxDecoration(gradient: degrade),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppTokens.s5,
                      0,
                      AppTokens.s5,
                      76,
                    ),
                    child: statut,
                  ),
                ),
              ),
            ),
          );

    return Column(
      children: [
        Expanded(
          child: CustomScrollView(
            slivers: [
              entete,
              SliverPadding(
                padding: const EdgeInsets.all(AppTokens.s4),
                sliver: SliverList.list(
                  children: [
                    Card(
                      child: Column(
                        children: [
                          _Info(
                            icon: Icons.event_rounded,
                            label: 'Échéance',
                            value: Dates.longue(task.echeance),
                            color: retard ? scheme.error : couleur,
                          ),
                          const Divider(indent: 72),
                          _Info(
                            icon: Icons.notifications_rounded,
                            label: 'Rappel',
                            value: Dates.rappel(task.rappel),
                            color: couleur,
                          ),
                          const Divider(indent: 72),
                          _Info(
                            icon: Icons.school_rounded,
                            label: 'Cours',
                            value: cours?.nom ?? 'Sans cours',
                            color: couleur,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppTokens.s4),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppTokens.s5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Description', style: text.titleMedium),
                            const SizedBox(height: AppTokens.s2),
                            Text(
                              task.description ?? 'Aucune description.',
                              style: text.bodyLarge?.copyWith(
                                height: 1.45,
                                color: task.description == null
                                    ? scheme.onSurfaceVariant
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Material(
          color: Theme.of(context).cardTheme.color,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(AppTokens.s4),
              child: task.terminee
                  ? OutlinedButton.icon(
                      onPressed: () => basculerTache(context, task),
                      icon: const Icon(Icons.undo_rounded),
                      label: const Text('Marquer comme à faire'),
                    )
                  : FilledButton.icon(
                      onPressed: () => basculerTache(context, task),
                      icon: const Icon(Icons.check_rounded),
                      label: const Text('Marquer comme fait'),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Pastille extends StatelessWidget {
  const _Pastille({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(
      horizontal: AppTokens.s3,
      vertical: AppTokens.s1 + 2,
    ),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(100),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.white),
        const SizedBox(width: AppTokens.s1 + 2),
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge
              ?.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ],
    ),
  );
}

class _Info extends StatelessWidget {
  const _Info({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return MergeSemantics(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTokens.s4,
          vertical: AppTokens.s3,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppTokens.radiusS),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: AppTokens.s4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: text.labelMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  Text(value, style: text.titleMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
