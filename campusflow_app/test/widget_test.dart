import 'package:campusflow/app.dart';
import 'package:campusflow_models/campusflow_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> seConnecter(
  WidgetTester tester, {
  Size taille = const Size(400, 860),
}) async {
  tester.view.physicalSize = taille;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    CampusFlowApp(repository: FakeCampusRepository(latence: Duration.zero)),
  );
  await tester.enterText(find.byType(TextFormField).at(1), 'secret');
  await tester.tap(find.text('Se connecter'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('connexion puis liste de la semaine', (tester) async {
    await seConnecter(tester);
    expect(find.text('CETTE SEMAINE'), findsOneWidget);
    expect(find.text('Rendu TP Dart'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('échéances : AppBar, ListView et ListTile', (tester) async {
    await seConnecter(tester);
    expect(find.byType(AppBar), findsOneWidget);
    expect(find.byType(ListView), findsOneWidget);
    expect(find.byType(ListTile), findsWidgets);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets('ajouter une tâche en 3 appuis', (tester) async {
    await seConnecter(tester);
    await tester.tap(find.text('Nouvelle tâche'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'QCM Flutter');
    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();
    expect(find.text('QCM Flutter'), findsOneWidget);
    expect(find.text('Tâche ajoutée'), findsOneWidget);
  });

  testWidgets('formulaire : le titre est obligatoire', (tester) async {
    await seConnecter(tester);
    await tester.tap(find.text('Nouvelle tâche'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();
    expect(find.text('Le titre est obligatoire'), findsOneWidget);
  });

  testWidgets('détail puis marquer comme fait', (tester) async {
    await seConnecter(tester);
    await tester.tap(find.text('Rendu TP Dart'));
    await tester.pumpAndSettle();
    expect(find.text('Échéance'), findsOneWidget);
    await tester.tap(find.text('Marquer comme fait'));
    await tester.pumpAndSettle();
    expect(find.text('Marquer comme à faire'), findsOneWidget);
  });

  testWidgets('étendu : rail de navigation et liste + détail', (tester) async {
    await seConnecter(tester, taille: const Size(1200, 860));
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.text('Sélectionnez une échéance'), findsOneWidget);
    await tester.tap(find.text('Rendu TP Dart'));
    await tester.pumpAndSettle();
    expect(find.text('Marquer comme fait'), findsOneWidget);
  });

  testWidgets('tablette : le détail passe à côté dès 840 dp', (tester) async {
    await seConnecter(tester, taille: const Size(840, 860));
    expect(find.text('Sélectionnez une échéance'), findsOneWidget);
  });

  testWidgets('sous 840 dp : une seule colonne', (tester) async {
    await seConnecter(tester, taille: const Size(839, 860));
    expect(find.text('Sélectionnez une échéance'), findsNothing);
  });
}
