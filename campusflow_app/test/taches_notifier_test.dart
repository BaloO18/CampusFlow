import 'package:campusflow/features/auth/application/auth_notifier.dart';
import 'package:campusflow/features/taches/application/filtres.dart';
import 'package:campusflow/features/taches/application/taches_notifier.dart';
import 'package:campusflow/features/taches/data/fake_task_repository.dart';
import 'package:campusflow_models/campusflow_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support.dart';

Future<ProviderContainer> conteneur({FakeTaskRepository? taches}) async {
  final container = ProviderContainer(
    overrides: surcharges(taches: taches),
    retry: (_, _) => null,
  );
  addTearDown(container.dispose);
  container.listen(tachesProvider, (_, _) {});
  await container
      .read(authProvider.notifier)
      .connexion('amina@campus.bf', '1234');
  await container.read(tachesProvider.future);
  return container;
}

Task _nouvelle(String titre, DateTime echeance) =>
    Task(id: '', titre: titre, coursId: 'c1', echeance: echeance);

void main() {
  test('build charge les tâches depuis le repository', () async {
    final container = await conteneur();
    expect(container.read(tachesProvider).value, hasLength(6));
  });

  test('ajouter et basculer assignent une nouvelle liste', () async {
    final container = await conteneur();
    final taches = container.read(tachesProvider.notifier);
    final avant = container.read(listeTachesProvider);

    final creee = await taches.ajouter(_nouvelle('QCM', DateTime(2030)));
    final apres = container.read(listeTachesProvider);
    expect(identical(avant, apres), isFalse);
    expect(apres, hasLength(avant.length + 1));

    await taches.basculer(creee.id);
    expect(container.read(tacheProvider(creee.id))?.terminee, isTrue);
  });

  test('basculer revient en arrière si le serveur échoue', () async {
    final repo = FakeTaskRepository(latence: Duration.zero);
    final container = await conteneur(taches: repo);
    repo.echouer = true;
    await expectLater(
      container.read(tachesProvider.notifier).basculer('t1'),
      throwsA(anything),
    );
    expect(container.read(tacheProvider('t1'))?.terminee, isFalse);
  });

  test('un serveur coupé met l’état en erreur', () async {
    final container = ProviderContainer(
      overrides: surcharges(
        taches: FakeTaskRepository(latence: Duration.zero, echouer: true),
      ),
      retry: (_, _) => null,
    );
    addTearDown(container.dispose);
    container.listen(tachesProvider, (_, _) {});
    await container.read(authProvider.notifier).connexion('a@b.bf', '1234');
    await expectLater(container.read(tachesProvider.future), throwsA(anything));
    expect(container.read(tachesProvider).hasError, isTrue);
  });

  test('les trois filtres dérivés suivent l’état', () async {
    final container = await conteneur();
    final taches = container.read(tachesProvider.notifier);
    final faitesAvant = container.read(tachesFaitesProvider).length;
    final retard = await taches.ajouter(_nouvelle('Oubli', DateTime(2020)));
    expect(container.read(tachesEnRetardProvider), contains(retard));
    expect(container.read(tachesAFaireProvider), contains(retard));

    await taches.basculer(retard.id);
    expect(container.read(tachesEnRetardProvider), isEmpty);
    expect(container.read(tachesFaitesProvider), hasLength(faitesAvant + 1));

    container.read(filtreProvider.notifier).choisir(Filtre.faites);
    expect(
      container.read(tachesFiltreesProvider),
      container.read(tachesFaitesProvider),
    );
  });

  test('supprimer retire la tâche de tous les fournisseurs dérivés', () async {
    final container = await conteneur();
    final duCours = container.read(tachesDuCoursProvider('c2'));
    expect(duCours, isNotEmpty);
    for (final t in duCours) {
      await container.read(tachesProvider.notifier).supprimer(t.id);
    }
    expect(container.read(tachesDuCoursProvider('c2')), isEmpty);
  });
}
