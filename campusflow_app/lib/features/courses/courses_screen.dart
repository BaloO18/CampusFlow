import 'package:campusflow_models/campusflow_models.dart';
import 'package:flutter/material.dart';

import '../../core/state/campus_state.dart';
import '../../core/theme/app_tokens.dart';
import '../../shared/widgets/async_content.dart';
import '../../shared/widgets/course_avatar.dart';
import '../../shared/widgets/section_header.dart';
import 'course_tasks_screen.dart';

class CoursesScreen extends StatelessWidget {
  const CoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = CampusScope.of(context);
    final echelle = MediaQuery.textScalerOf(context).scale(16) / 16;
    return Scaffold(
      body: AsyncContent(
        child: CustomScrollView(
          slivers: [
            SliverSafeArea(
              bottom: false,
              sliver: SliverToBoxAdapter(
                child: PageTitle(
                  title: 'Mes cours',
                  subtitle: '${state.cours.length} cours ce semestre',
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(AppTokens.s4),
              sliver: SliverGrid.builder(
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 220,
                  mainAxisExtent: 170 * echelle.clamp(1.0, 2.2),
                  crossAxisSpacing: AppTokens.s3,
                  mainAxisSpacing: AppTokens.s3,
                ),
                itemCount: state.cours.length,
                itemBuilder: (context, i) => _CarteCours(cours: state.cours[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CarteCours extends StatelessWidget {
  const _CarteCours({required this.cours});

  final Course cours;

  @override
  Widget build(BuildContext context) {
    final state = CampusScope.of(context);
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final couleur = Color(cours.couleur);
    final taches = state.tachesDuCours(cours.id);
    final aFaire = taches.where((t) => !t.terminee).length;
    final faites = taches.length - aFaire;

    return Semantics(
      button: true,
      label: '${cours.nom}, $aFaire tâche${aFaire > 1 ? 's' : ''} à faire',
      excludeSemantics: true,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => CourseTasksScreen(cours: cours),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppTokens.s4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CourseAvatar(course: cours),
                    const Spacer(),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: scheme.onSurfaceVariant,
                      size: 20,
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  cours.nom,
                  style: text.titleMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  aFaire == 0 ? 'À jour ✓' : '$aFaire à faire',
                  style: text.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppTokens.s3),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: taches.isEmpty ? 0 : faites / taches.length,
                    minHeight: 6,
                    color: couleur,
                    backgroundColor: couleur.withValues(alpha: 0.15),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
