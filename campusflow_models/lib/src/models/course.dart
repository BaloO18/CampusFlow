import '../utils/json.dart';

class Course {
  final String id;
  final String nom;
  final String? enseignant;

  final int couleur;

  const Course({
    required this.id,
    required this.nom,
    this.enseignant,
    this.couleur = 0xFFEC3013,
  });

  Course copyWith({String? nom, String? enseignant, int? couleur}) => Course(
    id: id,
    nom: nom ?? this.nom,
    enseignant: enseignant ?? this.enseignant,
    couleur: couleur ?? this.couleur,
  );

  factory Course.fromJson(JsonMap json) => Course(
    id: champ<String>(json, 'id'),
    nom: champ<String>(json, 'nom'),
    enseignant: champFacultatif<String>(json, 'enseignant'),
    couleur: champFacultatif<int>(json, 'couleur') ?? 0xFFEC3013,
  );

  JsonMap toJson() => {
    'id': id,
    'nom': nom,
    if (enseignant != null) 'enseignant': enseignant,
    'couleur': couleur,
  };

  @override
  bool operator ==(Object other) =>
      other is Course &&
      other.id == id &&
      other.nom == nom &&
      other.enseignant == enseignant &&
      other.couleur == couleur;

  @override
  int get hashCode => Object.hash(id, nom, enseignant, couleur);
}
