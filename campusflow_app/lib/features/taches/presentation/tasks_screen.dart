import 'package:campusflow_models/campusflow_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/layout/disposition.dart';
import '../../../core/router.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/dates.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/section_header.dart';
import '../../auth/application/auth_notifier.dart';
import '../application/filtres.dart';
import '../application/taches_notifier.dart';
import 'task_detail_screen.dart';
import 'task_form_screen.dart';
import 'widgets/reminder_banner.dart';
import 'widgets/summary_card.dart';
import 'widgets/task_card.dart';
import 'widgets/week_strip.dart';

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  DateTime? _jour;
  String? _selection;

  bool get _etendu => Disposition.etendueDe(context);

  List<Task> _duJour(List<Task> taches) {
    final jour = _jour;
    if (jour == null) return taches;
    return [
      for (final t in taches)
        if (Dates.memeJour(t.echeance, jour)) t,
    ];
  }

  List<(String, List<Task>)> _grouper(List<Task> taches) {
    final groupes = <String, List<Task>>{};
    for (final t in taches) {
      final cle = t.enRetard() ? 'En retard' : Dates.groupe(t.echeance);
      groupes.putIfAbsent(cle, () => []).add(t);
    }
    return [for (final e in groupes.entries) (e.key, e.value)];
  }

  Future<void> _ouvrir(Task task) async {
    if (_etendu) {
      setState(() => _selection = task.id);
      return;
    }
    await context.push(Routes.tache(task.id));
  }

  Future<void> _nouvelle() async {
    final id = await ouvrirFormulaire(context);
    if (id != null && _etendu) setState(() => _selection = id);
  }

  @override
  Widget build(BuildContext context) {
    final filtre = ref.watch(filtreProvider);
    final groupes = _grouper(_duJour(ref.watch(tachesFiltreesProvider)));
    final selection = _selection;

    final lignes = <WidgetBuilder>[
      (_) => const _Salutation(),
      (_) => const Padding(
        padding: EdgeInsets.fromLTRB(
          AppTokens.s4,
          AppTokens.s2,
          AppTokens.s4,
          0,
        ),
        child: SummaryCard(),
      ),
      (_) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppTokens.s4),
        child: ReminderBanner(onTap: _ouvrir),
      ),
      (_) => const SectionHeader(
        'Mes 7 prochains jours',
        padding: EdgeInsets.fromLTRB(
          AppTokens.s5,
          AppTokens.s5,
          AppTokens.s5,
          AppTokens.s2,
        ),
      ),
      (_) => WeekStrip(
        selected: _jour,
        onSelected: (j) => setState(() => _jour = j),
      ),
      (_) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(
          AppTokens.s4,
          AppTokens.s4,
          AppTokens.s4,
          0,
        ),
        child: Row(
          children: [
            for (final f in Filtre.values)
              Padding(
                padding: const EdgeInsets.only(right: AppTokens.s2),
                child: ChoiceChip(
                  label: Text(
                    '${f.label} (${ref.watch(tachesDuFiltreProvider(f)).length})',
                  ),
                  selected: filtre == f,
                  showCheckmark: false,
                  onSelected: (_) =>
                      ref.read(filtreProvider.notifier).choisir(f),
                ),
              ),
          ],
        ),
      ),
      if (groupes.isEmpty)
        (_) => EmptyState(
          icon: filtre == Filtre.faites
              ? Icons.inventory_2_outlined
              : Icons.celebration_outlined,
          title: filtre == Filtre.faites
              ? 'Aucune tâche terminée'
              : 'Rien à rendre',
          message: filtre == Filtre.faites
              ? 'Vos tâches faites apparaîtront ici.'
              : 'Profitez-en pour prendre de l’avance.',
        ),
      for (final (titre, taches) in groupes) ...[
        (_) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTokens.s4),
          child: SectionHeader(
            titre,
            trailing: '${taches.length} tâche${taches.length > 1 ? 's' : ''}',
          ),
        ),
        for (final task in taches)
          (_) => Padding(
            padding: const EdgeInsets.fromLTRB(
              AppTokens.s4,
              0,
              AppTokens.s4,
              AppTokens.s2,
            ),
            child: TaskCard(
              task: task,
              selected: _etendu && task.id == selection,
              onTap: () => _ouvrir(task),
            ),
          ),
      ],
    ];

    final liste = ListView.builder(
      padding: const EdgeInsets.only(bottom: 112),
      itemCount: lignes.length,
      itemBuilder: (context, i) => lignes[i](context),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Échéances'),
        actions: [
          _BoutonProfil(onTap: () => context.go(Routes.profil)),
          const SizedBox(width: AppTokens.s2),
        ],
      ),
      floatingActionButtonLocation: _etendu
          ? FloatingActionButtonLocation.startFloat
          : FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _nouvelle,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nouvelle tâche'),
      ),
      body: !_etendu
          ? liste
          : Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(width: 440, child: liste),
                const VerticalDivider(width: 1),
                Expanded(
                  child:
                      selection != null &&
                          ref.watch(tacheProvider(selection)) != null
                      ? TaskDetailView(
                          key: ValueKey(selection),
                          taskId: selection,
                          embedded: true,
                          onDeleted: () => setState(() => _selection = null),
                        )
                      : const EmptyState(
                          icon: Icons.touch_app_outlined,
                          title: 'Sélectionnez une échéance',
                          message: 'Son détail s’affichera ici.',
                        ),
                ),
              ],
            ),
    );
  }
}

class _Salutation extends ConsumerWidget {
  const _Salutation();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nom = ref.watch(authProvider)?.nom ?? '';
    return PageTitle(
      subtitle: Dates.jourComplet(DateTime.now()),
      title: 'Bonjour $nom 👋',
    );
  }
}

class _BoutonProfil extends ConsumerWidget {
  const _BoutonProfil({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final nom = ref.watch(authProvider)?.nom ?? '';
    return Semantics(
      button: true,
      label: 'Ouvrir le profil',
      excludeSemantics: true,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppTokens.s1),
          child: CircleAvatar(
            radius: 20,
            backgroundColor: scheme.primary,
            foregroundColor: scheme.onPrimary,
            child: Text(
              nom.isEmpty ? '?' : nom.characters.first,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ),
    );
  }
}
