import '../utils/json.dart';

class User {
  final String id;
  final String nom;
  final String email;
  final String? formation;

  final bool rappelsActives;

  const User({
    required this.id,
    required this.nom,
    required this.email,
    this.formation,
    this.rappelsActives = true,
  });

  User copyWith({
    String? nom,
    String? email,
    String? formation,
    bool? rappelsActives,
  }) => User(
    id: id,
    nom: nom ?? this.nom,
    email: email ?? this.email,
    formation: formation ?? this.formation,
    rappelsActives: rappelsActives ?? this.rappelsActives,
  );

  factory User.fromJson(JsonMap json) => User(
    id: champ<String>(json, 'id'),
    nom: champ<String>(json, 'nom'),
    email: champ<String>(json, 'email'),
    formation: champFacultatif<String>(json, 'formation'),
    rappelsActives: champFacultatif<bool>(json, 'rappelsActives') ?? true,
  );

  JsonMap toJson() => {
    'id': id,
    'nom': nom,
    'email': email,
    if (formation != null) 'formation': formation,
    'rappelsActives': rappelsActives,
  };

  @override
  bool operator ==(Object other) =>
      other is User &&
      other.id == id &&
      other.nom == nom &&
      other.email == email &&
      other.formation == formation &&
      other.rappelsActives == rappelsActives;

  @override
  int get hashCode => Object.hash(id, nom, email, formation, rappelsActives);
}
