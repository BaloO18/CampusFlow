import 'package:campusflow_models/campusflow_models.dart';
import 'package:test/test.dart';

void main() {
  final echeance = DateTime(2026, 10, 30, 17);
  final task = Task(
    id: 't1',
    titre: 'Projet Flutter',
    coursId: 'c1',
    echeance: echeance,
  );

  group('copyWith', () {
    test('crée une copie modifiée sans toucher l’original', () {
      final faite = task.copyWith(terminee: true);
      expect(faite.terminee, isTrue);
      expect(faite.titre, 'Projet Flutter');
      expect(task.terminee, isFalse);
    });

    test('peut retirer la description', () {
      final avec = task.copyWith(description: 'Écrans');
      expect(avec.description, 'Écrans');
      expect(avec.copyWith(sansDescription: true).description, isNull);
    });
  });

  group('fromJson', () {
    test('lit une tâche complète et fait l’aller-retour', () {
      final t = Task.fromJson({
        'id': 't2',
        'titre': 'Rendu TP Dart',
        'coursId': 'c2',
        'echeance': '2026-10-29T23:59:00.000',
        'description': 'Modèles',
        'rappelMinutes': 60,
      });
      expect(t.titre, 'Rendu TP Dart');
      expect(t.rappel, const Duration(hours: 1));
      expect(t.terminee, isFalse);
      expect(Task.fromJson(t.toJson()), t);
    });

    test('lit Course et User', () {
      final c = Course.fromJson({'id': 'c1', 'nom': 'Mobile'});
      expect(c.couleur, 0xFFEC3013);
      final u = User.fromJson(utilisateurJson);
      expect(u.nom, 'Amina');
      expect(User.fromJson(u.toJson()), u);
    });
  });

  group('erreur attendue', () {
    test('fromJson refuse un titre manquant', () {
      expect(
        () => Task.fromJson({
          'id': 'x',
          'coursId': 'c1',
          'echeance': '2026-10-29',
        }),
        throwsFormatException,
      );
    });

    test('le dépôt simulé échoue quand le réseau est coupé', () async {
      final repo = FakeCampusRepository(latence: Duration.zero, echouer: true);
      await expectLater(repo.chargerTaches(), throwsA(isA<NetworkException>()));
    });

    test('la connexion refuse un email invalide', () async {
      final repo = FakeCampusRepository(latence: Duration.zero);
      await expectLater(
        repo.connexion(email: 'amina', motDePasse: 'secret'),
        throwsA(isA<AuthException>()),
      );
    });
  });

  test('résumé sans « ! » quand la description est absente', () {
    expect(task.resume(), 'Projet Flutter : Aucune');
  });

  test('le dépôt simulé charge les données avec Future.delayed', () async {
    final repo = FakeCampusRepository(
      latence: const Duration(milliseconds: 10),
    );
    final taches = await repo.chargerTaches();
    expect(taches, hasLength(6));
    final nouvelle = await repo.enregistrerTache(
      Task(id: '', titre: 'QCM', coursId: 'c3', echeance: echeance),
    );
    expect(nouvelle.id, isNotEmpty);
    expect(await repo.chargerTaches(), hasLength(7));
  });
}
