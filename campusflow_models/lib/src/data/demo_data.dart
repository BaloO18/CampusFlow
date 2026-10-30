import '../utils/json.dart';

const JsonMap utilisateurJson = {
  'id': 'u1',
  'nom': 'Amina',
  'email': 'amina@campus.bf',
  'formation': 'Master 1 Informatique',
  'rappelsActives': true,
};

const List<JsonMap> coursJson = [
  {
    'id': 'c1',
    'nom': 'Mobile',
    'enseignant': 'Programmation mobile',
    'couleur': 0xFFEC3013,
  },
  {
    'id': 'c2',
    'nom': 'Dart',
    'enseignant': 'Langage Dart',
    'couleur': 0xFF1565C0,
  },
  {
    'id': 'c3',
    'nom': 'UX',
    'enseignant': 'Conception UX/UI',
    'couleur': 0xFF6A1B9A,
  },
  {'id': 'c4', 'nom': 'Bases de données', 'couleur': 0xFF2E7D32},
  {'id': 'c5', 'nom': 'Réseaux', 'couleur': 0xFF00838F},
  {'id': 'c6', 'nom': 'Anglais', 'couleur': 0xFF8D6E00},
];

List<JsonMap> tachesJson(DateTime m) {
  final jour = DateTime(m.year, m.month, m.day);
  DateTime prochain(int weekday, int heure) {
    var ecart = (weekday - jour.weekday) % 7;
    if (ecart == 0) ecart = 7;
    return jour.add(Duration(days: ecart, hours: heure));
  }

  String iso(DateTime d) => d.toIso8601String();
  return [
    {
      'id': 't1',
      'titre': 'Rendu TP Dart',
      'coursId': 'c2',
      'echeance': iso(
        jour.add(const Duration(days: 1, hours: 23, minutes: 59)),
      ),
      'description':
          'Modèles Task, Course, User avec copyWith et fromJson. '
          'Trois tests avec dart test.',
      'rappelMinutes': 24 * 60,
    },
    {
      'id': 't2',
      'titre': 'Projet Flutter',
      'coursId': 'c1',
      'echeance': iso(prochain(DateTime.friday, 17)),
      'description':
          'Prototype CampusFlow : écrans Échéances, Détail et '
          'Nouvelle tâche.',
      'rappelMinutes': 3 * 60,
    },
    {
      'id': 't3',
      'titre': 'Examen UX',
      'coursId': 'c3',
      'echeance': iso(prochain(DateTime.monday, 8)),
      'description': 'Persona, job story, parcours utilisateur, wireframes.',
      'rappelMinutes': 24 * 60,
    },
    {
      'id': 't4',
      'titre': 'Dossier de conception v1',
      'coursId': 'c1',
      'echeance': iso(jour.add(const Duration(days: 10, hours: 12))),
    },
    {
      'id': 't5',
      'titre': 'Lecture : null safety',
      'coursId': 'c2',
      'echeance': iso(
        jour.subtract(const Duration(days: 2)).add(const Duration(hours: 18)),
      ),
      'terminee': true,
    },
    {
      'id': 't6',
      'titre': 'TP SQL jointures',
      'coursId': 'c4',
      'echeance': iso(jour.add(const Duration(days: 3, hours: 10))),
      'rappelMinutes': 60,
    },
  ];
}
