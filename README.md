# CampusFlow

Application mobile Flutter de suivi des échéances académiques.

## Prérequis

- Flutter 3.35 ou plus récent (Dart 3.9+) : https://docs.flutter.dev/get-started/install
- `flutter doctor` sans erreur
- Un appareil cible : téléphone Android (débogage USB activé), émulateur Android, simulateur iOS ou Chrome

## Lancer l'application

```sh
cd campusflow_app
flutter pub get
flutter run
```

Pour choisir l'appareil :

```sh
flutter devices
flutter run -d chrome
flutter run -d <id_de_l_appareil>
```

## Connexion de démonstration

| Champ | Valeur |
| --- | --- |
| Email | `amina@campus.bf` (pré-rempli) |
| Mot de passe | n'importe quelle valeur de 4 caractères ou plus, par exemple `1234` |

Les données sont simulées en mémoire et réinitialisées à chaque lancement.

## Lancer les tests

```sh
cd campusflow_models
dart pub get
dart test

cd ../campusflow_app
flutter test
```

## Organisation du code

```
campusflow/
├── campusflow_models/            Package Dart pur
│   ├── lib/src/models/           Task, Course, User
│   ├── lib/src/data/             Interface du dépôt, dépôt simulé, données de démo, exceptions
│   ├── lib/src/utils/            Lecture JSON
│   └── test/
└── campusflow_app/               Application Flutter
    ├── lib/
    │   ├── main.dart
    │   ├── app.dart
    │   ├── core/
    │   │   ├── state/            État de l'application
    │   │   ├── theme/            Design system : tokens et thème Material 3
    │   │   └── utils/            Formatage des dates
    │   ├── shared/widgets/       Composants réutilisables
    │   └── features/
    │       ├── auth/             Connexion
    │       ├── home/             Navigation principale
    │       ├── tasks/            Échéances, détail, nouvelle tâche
    │       ├── courses/          Cours et tâches d'un cours
    │       └── profile/          Profil et préférences
    └── test/
```
