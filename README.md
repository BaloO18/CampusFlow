# CampusFlow

Application mobile Flutter de suivi des cours, échéances et tâches d'un étudiant, connectée à une API avec authentification.

## Prérequis

- Flutter 3.35 ou plus récent (Dart 3.9+) : https://docs.flutter.dev/get-started/install
- `flutter doctor` sans erreur
- Node.js 18 ou plus récent, pour l'API simulée (json-server)
- Un appareil cible : émulateur Android, téléphone Android (débogage USB activé), simulateur iOS ou Chrome

## 1. Lancer l'API

```sh
cd api
npm install
npm start
```

L'API écoute sur http://localhost:3000. Toutes les routes demandent un jeton, sauf `POST /login`.

## 2. Lancer l'application

Dans un second terminal :

```sh
cd campusflow_app
flutter pub get
flutter run
```

L'application trouve l'API toute seule sur l'émulateur Android (`10.0.2.2:3000`), sur Chrome et sur le simulateur iOS (`localhost:3000`). Sur un vrai téléphone, l'ordinateur et le téléphone doivent être sur le même Wi-Fi, et on donne l'adresse de l'ordinateur :

```sh
flutter run --dart-define=API_URL=http://192.168.1.20:3000
```

Pour choisir l'appareil :

```sh
flutter devices
flutter run -d chrome
flutter run -d <id_de_l_appareil>
```

## Connexion de démonstration

| Email | Mot de passe |
| --- | --- |
| `amina@campus.bf` (pré-rempli) | `1234` |
| `steve@campus.bf` | `1234` |

Les données sont dans `api/db.json`. Le jeton reçu est rangé dans le stockage sécurisé du téléphone. Si l'API répond 401, l'application revient à l'écran de connexion.

## Lancer les tests

```sh
cd campusflow_models
dart pub get
dart test

cd ../campusflow_app
flutter test
```

Les tests de l'application n'ont pas besoin de l'API : ils utilisent les dépôts en mémoire (`FakeTaskRepository`, `FakeAuthRepository`, `FakeCoursRepository`).

## Organisation

```
CampusFlow/
├── docs/                         Séances 1 et 2 : décision, persona, parcours, wireframes, design system
├── api/                          db.json et serveur json-server avec /login
├── campusflow_models/            Package Dart : Task, Course, User, fromJson, dépôt simulé, tests
└── campusflow_app/               Application Flutter
    ├── assets/images/            Logo
    ├── lib/
    │   ├── main.dart             ProviderScope
    │   ├── app.dart              MaterialApp.router
    │   ├── core/                 Client Dio, routes go_router, stockage du jeton, thème
    │   ├── shared/widgets/       Composants réutilisables
    │   └── features/
    │       ├── auth/             Connexion
    │       ├── taches/           Échéances, détail, formulaire
    │       ├── cours/            Cours et tâches d'un cours
    │       ├── profil/           Profil et préférences
    │       └── home/             Barre de navigation (ShellRoute)
    └── test/
```

Chaque fonctionnalité est découpée en `domain/` (contrats), `data/` (implémentations API et en mémoire), `application/` (Notifiers Riverpod) et `presentation/` (écrans).

## Adresses de l'application

`/login`, `/taches`, `/taches/nouvelle`, `/taches/:id`, `/taches/:id/modifier`, `/cours`, `/cours/:id`, `/profil`
