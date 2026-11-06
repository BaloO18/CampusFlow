import 'package:campusflow_models/campusflow_models.dart';
import 'package:flutter/material.dart';

import '../../core/state/campus_state.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/dates.dart';
import '../../shared/widgets/section_header.dart';

Future<String?> ouvrirFormulaire(
  BuildContext context, {
  Task? task,
  String? coursId,
}) => Navigator.of(context).push<String>(
  MaterialPageRoute(
    fullscreenDialog: true,
    builder: (_) => TaskFormScreen(task: task, coursId: coursId),
  ),
);

class TaskFormScreen extends StatefulWidget {
  const TaskFormScreen({super.key, this.task, this.coursId});

  final Task? task;
  final String? coursId;

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  static const _rappels = <Duration?>[
    null,
    Duration(hours: 1),
    Duration(hours: 3),
    Duration(days: 1),
    Duration(days: 2),
  ];

  final _form = GlobalKey<FormState>();
  late final _titre = TextEditingController(text: widget.task?.titre);
  late final _description = TextEditingController(
    text: widget.task?.description,
  );
  String? _coursId;
  late DateTime _echeance;
  Duration? _rappel;
  bool _initialise = false;
  bool _envoi = false;

  bool get _edition => widget.task != null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialise) return;
    _initialise = true;
    final state = CampusScope.of(context);
    final task = widget.task;
    final demain = DateTime.now().add(const Duration(days: 1));
    _coursId =
        task?.coursId ??
        widget.coursId ??
        (state.cours.isEmpty ? null : state.cours.first.id);
    _echeance =
        task?.echeance ?? DateTime(demain.year, demain.month, demain.day, 17);
    _rappel = task != null
        ? task.rappel
        : (state.utilisateur?.rappelsActives ?? true)
        ? const Duration(days: 1)
        : null;
  }

  @override
  void dispose() {
    _titre.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _choisirDate() async {
    final jour = await showDatePicker(
      context: context,
      initialDate: _echeance,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
      helpText: 'Date d’échéance',
    );
    if (jour == null) return;
    setState(() {
      _echeance = DateTime(
        jour.year,
        jour.month,
        jour.day,
        _echeance.hour,
        _echeance.minute,
      );
    });
  }

  Future<void> _choisirHeure() async {
    final heure = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_echeance),
      helpText: 'Heure d’échéance',
    );
    if (heure == null) return;
    setState(() {
      _echeance = DateTime(
        _echeance.year,
        _echeance.month,
        _echeance.day,
        heure.hour,
        heure.minute,
      );
    });
  }

  Future<void> _enregistrer() async {
    final coursId = _coursId;
    if (!(_form.currentState?.validate() ?? false)) return;
    if (coursId == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Choisissez un cours')));
      return;
    }
    setState(() => _envoi = true);
    final description = _description.text.trim();
    final base =
        widget.task ??
        Task(id: '', titre: '', coursId: coursId, echeance: _echeance);
    final task = base.copyWith(
      titre: _titre.text.trim(),
      coursId: coursId,
      echeance: _echeance,
      description: description.isEmpty ? null : description,
      sansDescription: description.isEmpty,
      rappel: _rappel,
      sansRappel: _rappel == null,
    );
    final messenger = ScaffoldMessenger.of(context);
    try {
      final sauvee = await CampusScope.of(context).enregistrer(task);
      if (!mounted) return;
      Navigator.of(context).pop(sauvee.id);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(_edition ? 'Tâche modifiée' : 'Tâche ajoutée'),
          ),
        );
    } catch (e) {
      if (!mounted) return;
      setState(() => _envoi = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Échec de l’enregistrement : $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cours = CampusScope.of(context).cours;
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_edition ? 'Modifier la tâche' : 'Nouvelle tâche'),
        leading: IconButton(
          tooltip: 'Fermer',
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Form(
        key: _form,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppTokens.s4,
                  AppTokens.s2,
                  AppTokens.s4,
                  AppTokens.s6,
                ),
                children: [
                  TextFormField(
                    controller: _titre,
                    autofocus: !_edition,
                    style: text.titleLarge,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Titre',
                      hintText: 'Ex. Rendu TP Dart',
                    ),
                    validator: (v) => (v ?? '').trim().isEmpty
                        ? 'Le titre est obligatoire'
                        : null,
                  ),
                  const SectionHeader('Cours'),
                  Wrap(
                    spacing: AppTokens.s2,
                    runSpacing: AppTokens.s2,
                    children: [
                      for (final c in cours)
                        ChoiceChip(
                          avatar: CircleAvatar(
                            backgroundColor: _coursId == c.id
                                ? scheme.onPrimary
                                : Color(c.couleur),
                            radius: 6,
                          ),
                          label: Text(c.nom),
                          selected: _coursId == c.id,
                          showCheckmark: false,
                          onSelected: (_) => setState(() => _coursId = c.id),
                        ),
                    ],
                  ),
                  const SectionHeader('Échéance'),
                  Row(
                    children: [
                      Expanded(
                        child: _Selecteur(
                          icon: Icons.calendar_month_rounded,
                          label: 'Date',
                          value: Dates.courte(_echeance),
                          onTap: _choisirDate,
                        ),
                      ),
                      const SizedBox(width: AppTokens.s3),
                      Expanded(
                        child: _Selecteur(
                          icon: Icons.schedule_rounded,
                          label: 'Heure',
                          value: Dates.heure(_echeance),
                          onTap: _choisirHeure,
                        ),
                      ),
                    ],
                  ),
                  const SectionHeader('Rappel'),
                  Wrap(
                    spacing: AppTokens.s2,
                    runSpacing: AppTokens.s2,
                    children: [
                      for (final r in _rappels)
                        ChoiceChip(
                          avatar: r == null
                              ? null
                              : Icon(
                                  Icons.notifications_rounded,
                                  size: 16,
                                  color: _rappel == r ? scheme.onPrimary : null,
                                ),
                          label: Text(Dates.rappel(r)),
                          selected: _rappel == r,
                          showCheckmark: false,
                          onSelected: (_) => setState(() => _rappel = r),
                        ),
                    ],
                  ),
                  const SectionHeader('Description'),
                  TextFormField(
                    controller: _description,
                    minLines: 3,
                    maxLines: 6,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      hintText: 'Facultative : consignes, liens, notes…',
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
                  child: FilledButton(
                    onPressed: _envoi ? null : _enregistrer,
                    child: _envoi
                        ? const SizedBox.square(
                            dimension: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              semanticsLabel: 'Enregistrement',
                            ),
                          )
                        : const Text('Enregistrer'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Selecteur extends StatelessWidget {
  const _Selecteur({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Semantics(
      button: true,
      label: '$label : $value',
      excludeSemantics: true,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppTokens.s4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 18, color: scheme.primary),
                    const SizedBox(width: AppTokens.s2),
                    Text(
                      label,
                      style: text.labelMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTokens.s2),
                Text(value, style: text.titleMedium),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
