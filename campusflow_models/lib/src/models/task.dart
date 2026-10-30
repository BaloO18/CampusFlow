import '../utils/json.dart';

class Task {
  final String id;
  final String titre;
  final String coursId;
  final DateTime echeance;

  final String? description;

  final Duration? rappel;

  final bool terminee;

  const Task({
    required this.id,
    required this.titre,
    required this.coursId,
    required this.echeance,
    this.description,
    this.rappel,
    this.terminee = false,
  });

  Task copyWith({
    String? titre,
    String? coursId,
    DateTime? echeance,
    String? description,
    bool sansDescription = false,
    Duration? rappel,
    bool sansRappel = false,
    bool? terminee,
  }) => Task(
    id: id,
    titre: titre ?? this.titre,
    coursId: coursId ?? this.coursId,
    echeance: echeance ?? this.echeance,
    description: sansDescription ? null : description ?? this.description,
    rappel: sansRappel ? null : rappel ?? this.rappel,
    terminee: terminee ?? this.terminee,
  );

  bool enRetard([DateTime? maintenant]) =>
      !terminee && echeance.isBefore(maintenant ?? DateTime.now());

  DateTime? get dateRappel => switch (rappel) {
    final r? => echeance.subtract(r),
    null => null,
  };

  String resume() => '$titre : ${(description ?? 'Aucune').trim()}';

  factory Task.fromJson(JsonMap json) {
    final minutes = champFacultatif<int>(json, 'rappelMinutes');
    return Task(
      id: champ<String>(json, 'id'),
      titre: champ<String>(json, 'titre'),
      coursId: champ<String>(json, 'coursId'),
      echeance: date(json, 'echeance'),
      description: champFacultatif<String>(json, 'description'),
      rappel: minutes == null ? null : Duration(minutes: minutes),
      terminee: champFacultatif<bool>(json, 'terminee') ?? false,
    );
  }

  JsonMap toJson() => {
    'id': id,
    'titre': titre,
    'coursId': coursId,
    'echeance': echeance.toIso8601String(),
    if (description != null) 'description': description,
    if (rappel != null) 'rappelMinutes': rappel?.inMinutes,
    'terminee': terminee,
  };

  @override
  bool operator ==(Object other) =>
      other is Task &&
      other.id == id &&
      other.titre == titre &&
      other.coursId == coursId &&
      other.echeance == echeance &&
      other.description == description &&
      other.rappel == rappel &&
      other.terminee == terminee;

  @override
  int get hashCode =>
      Object.hash(id, titre, coursId, echeance, description, rappel, terminee);

  @override
  String toString() => 'Task($titre, $echeance, terminee: $terminee)';
}
