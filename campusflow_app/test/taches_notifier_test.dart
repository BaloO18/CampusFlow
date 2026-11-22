import 'package:campusflow/features/taches/application/filtres.dart';
import 'package:campusflow/features/taches/application/taches_notifier.dart';
import 'package:campusflow_models/campusflow_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ajouter et basculer assignent une nouvelle liste', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final taches = container.read(tachesProvider.notifier);
    final avant = container.read(tachesProvider);

    final nouvelle = taches.ajouter(
      Task(id: '', titre: 'QCM', coursId: 'c1', echeance: DateTime(2030)),
    );
    final apres = container.read(tachesProvider);
    expect(identical(avant, apres), isFalse);
    expect(apres, hasLength(avant.length + 1));
    expect(avant.any((t) => t.titre == 'QCM'), isFalse);

    taches.basculer(nouvelle.id);
    expect(container.read(tacheProvider(nouvelle.id))?.terminee, isTrue);
  });

  test('les trois filtres dérivés suivent l’état', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final taches = container.read(tachesProvider.notifier);
    final faitesAvant = container.read(tachesFaitesProvider).length;
    final retard = taches.ajouter(
      Task(id: '', titre: 'Oubli', coursId: 'c1', echeance: DateTime(2020)),
    );
    expect(container.read(tachesEnRetardProvider), contains(retard));
    expect(container.read(tachesAFaireProvider), contains(retard));

    taches.basculer(retard.id);
    expect(container.read(tachesEnRetardProvider), isEmpty);
    expect(container.read(tachesFaitesProvider), hasLength(faitesAvant + 1));

    container.read(filtreProvider.notifier).choisir(Filtre.faites);
    expect(
      container.read(tachesFiltreesProvider),
      container.read(tachesFaitesProvider),
    );
  });

  test('supprimer retire la tâche de tous les fournisseurs dérivés', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    expect(container.read(tachesDuCoursProvider('c2')), isNotEmpty);
    for (final t in container.read(tachesDuCoursProvider('c2'))) {
      container.read(tachesProvider.notifier).supprimer(t.id);
    }
    expect(container.read(tachesDuCoursProvider('c2')), isEmpty);
  });
}
