import 'package:campusflow_models/campusflow_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'taches_notifier.dart';

enum Filtre {
  aFaire('À faire'),
  enRetard('En retard'),
  faites('Faites');

  const Filtre(this.label);
  final String label;
}

class FiltreNotifier extends Notifier<Filtre> {
  @override
  Filtre build() => Filtre.aFaire;

  void choisir(Filtre filtre) => state = filtre;
}

final filtreProvider = NotifierProvider<FiltreNotifier, Filtre>(
  FiltreNotifier.new,
);

List<Task> _parEcheance(Iterable<Task> taches) =>
    taches.toList()..sort((a, b) => a.echeance.compareTo(b.echeance));

final tachesAFaireProvider = Provider<List<Task>>(
  (ref) =>
      _parEcheance(ref.watch(listeTachesProvider).where((t) => !t.terminee)),
);

final tachesEnRetardProvider = Provider<List<Task>>(
  (ref) =>
      _parEcheance(ref.watch(listeTachesProvider).where((t) => t.enRetard())),
);

final tachesFaitesProvider = Provider<List<Task>>(
  (ref) => _parEcheance(
    ref.watch(listeTachesProvider).where((t) => t.terminee),
  ).reversed.toList(),
);

final tachesDuFiltreProvider = Provider.family<List<Task>, Filtre>(
  (ref, filtre) => switch (filtre) {
    Filtre.aFaire => ref.watch(tachesAFaireProvider),
    Filtre.enRetard => ref.watch(tachesEnRetardProvider),
    Filtre.faites => ref.watch(tachesFaitesProvider),
  },
);

final tachesFiltreesProvider = Provider<List<Task>>(
  (ref) => ref.watch(tachesDuFiltreProvider(ref.watch(filtreProvider))),
);
