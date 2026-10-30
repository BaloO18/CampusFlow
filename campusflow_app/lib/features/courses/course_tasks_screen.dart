import 'package:campusflow_models/campusflow_models.dart';
import 'package:flutter/material.dart';

import '../../core/state/campus_state.dart';
import '../../core/theme/app_tokens.dart';
import '../../shared/widgets/async_content.dart';
import '../tasks/task_detail_screen.dart';
import '../tasks/task_form_screen.dart';
import '../tasks/widgets/task_card.dart';

class CourseTasksScreen extends StatelessWidget {
  const CourseTasksScreen({super.key, required this.cours});

  final Course cours;

  @override
  Widget build(BuildContext context) {
    final taches = CampusScope.of(context).tachesDuCours(cours.id);
    final aFaire = taches.where((t) => !t.terminee).length;
    final couleur = Color(cours.couleur);
    final text = Theme.of(context).textTheme;
    const blanc = Colors.white;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        tooltip: 'Nouvelle tâche dans ${cours.nom}',
        onPressed: () => ouvrirFormulaire(context, coursId: cours.id),
        child: const Icon(Icons.add_rounded),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 180,
            backgroundColor: couleur.darken(0.2),
            foregroundColor: blanc,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsetsDirectional.only(
                start: 56,
                bottom: AppTokens.s4,
              ),
              title: Text(
                cours.nom,
                style: text.titleLarge?.copyWith(color: blanc),
              ),
              background: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [couleur, couleur.darken(0.4)],
                  ),
                ),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(56, 0, 16, 56),
                    child: Text(
                      '${taches.length} tâche${taches.length > 1 ? 's' : ''} · $aFaire à faire',
                      style: text.bodyMedium?.copyWith(
                        color: blanc.withValues(alpha: 0.9),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (taches.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(
                icon: Icons.task_alt_rounded,
                title: 'Aucune tâche pour ce cours',
                message: 'Ajoutez-en une avec le bouton +.',
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppTokens.s4,
                AppTokens.s4,
                AppTokens.s4,
                112,
              ),
              sliver: SliverList.separated(
                itemCount: taches.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppTokens.s2),
                itemBuilder: (context, i) => TaskCard(
                  task: taches[i],
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => TaskDetailScreen(taskId: taches[i].id),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
