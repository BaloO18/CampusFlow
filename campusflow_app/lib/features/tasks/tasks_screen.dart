import 'package:campusflow_models/campusflow_models.dart';
import 'package:flutter/material.dart';

import '../../core/state/campus_state.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/dates.dart';
import '../../shared/widgets/async_content.dart';
import '../../shared/widgets/section_header.dart';
import 'task_detail_screen.dart';
import 'task_form_screen.dart';
import 'widgets/reminder_banner.dart';
import 'widgets/summary_card.dart';
import 'widgets/task_card.dart';
import 'widgets/week_strip.dart';

enum Filtre {
  semaine('Cette semaine'),
  aFaire('À faire'),
  terminees('Terminées');

  const Filtre(this.label);
  final String label;
}

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key, this.etendu = false, this.onOpenProfile});

  final bool etendu;
  final VoidCallback? onOpenProfile;

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  Filtre _filtre = Filtre.semaine;
  DateTime? _jour;
  String? _selection;

  bool get _etendu => widget.etendu;

  List<Task> _filtrer(List<Task> taches) {
    final jour = _jour;
    Iterable<Task> liste = switch (_filtre) {
      Filtre.semaine => taches.where(
        (t) => !t.terminee && Dates.cetteSemaine(t.echeance),
      ),
      Filtre.aFaire => taches.where((t) => !t.terminee),
      Filtre.terminees => taches.where((t) => t.terminee),
    };
    if (jour != null) {
      liste = liste.where((t) => Dates.memeJour(t.echeance, jour));
    }
    final tri = liste.toList()
      ..sort((a, b) => a.echeance.compareTo(b.echeance));
    return _filtre == Filtre.terminees ? tri.reversed.toList() : tri;
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
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TaskDetailScreen(taskId: task.id),
      ),
    );
  }

  Future<void> _nouvelle() async {
    final id = await ouvrirFormulaire(context);
    if (id != null && _etendu) setState(() => _selection = id);
  }

  @override
  Widget build(BuildContext context) {
    final state = CampusScope.of(context);
    final groupes = _grouper(_filtrer(state.taches));
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
                  label: Text(f.label),
                  selected: _filtre == f,
                  showCheckmark: false,
                  onSelected: (_) => setState(() => _filtre = f),
                ),
              ),
          ],
        ),
      ),
      if (groupes.isEmpty)
        (_) => EmptyState(
          icon: _filtre == Filtre.terminees
              ? Icons.inventory_2_outlined
              : Icons.celebration_outlined,
          title: _filtre == Filtre.terminees
              ? 'Aucune tâche terminée'
              : 'Rien à rendre',
          message: _filtre == Filtre.terminees
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

    final liste = AsyncContent(
      child: RefreshIndicator(
        onRefresh: state.charger,
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 112),
          itemCount: lignes.length,
          itemBuilder: (context, i) => lignes[i](context),
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Échéances'),
        actions: [
          IconButton(
            tooltip: 'Actualiser',
            onPressed: state.chargement ? null : state.charger,
            icon: const Icon(Icons.refresh_rounded),
          ),
          _BoutonProfil(onTap: widget.onOpenProfile),
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
                  child: selection != null && state.tache(selection) != null
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

class _Salutation extends StatelessWidget {
  const _Salutation();

  @override
  Widget build(BuildContext context) {
    final nom = CampusScope.of(context).utilisateur?.nom ?? '';
    return PageTitle(
      subtitle: Dates.jourComplet(DateTime.now()),
      title: 'Bonjour $nom 👋',
    );
  }
}

class _BoutonProfil extends StatelessWidget {
  const _BoutonProfil({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final nom = CampusScope.of(context).utilisateur?.nom ?? '';
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
