abstract final class Dates {
  static const _jours = [
    'lundi',
    'mardi',
    'mercredi',
    'jeudi',
    'vendredi',
    'samedi',
    'dimanche',
  ];
  static const _joursCourts = [
    'lun.',
    'mar.',
    'mer.',
    'jeu.',
    'ven.',
    'sam.',
    'dim.',
  ];
  static const _mois = [
    'janvier',
    'février',
    'mars',
    'avril',
    'mai',
    'juin',
    'juillet',
    'août',
    'septembre',
    'octobre',
    'novembre',
    'décembre',
  ];

  static DateTime jour(DateTime d) => DateTime(d.year, d.month, d.day);

  static bool memeJour(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static int ecartJours(DateTime d, DateTime maintenant) =>
      (jour(d).difference(jour(maintenant)).inHours / 24).round();

  static String capitaliser(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  static String heure(DateTime d) => d.minute == 0
      ? '${d.hour} h'
      : '${d.hour} h ${d.minute.toString().padLeft(2, '0')}';

  static String jourCourt(DateTime d) => _joursCourts[d.weekday - 1];

  static String relatif(DateTime d, [DateTime? maintenant]) {
    final ecart = ecartJours(d, maintenant ?? DateTime.now());
    return switch (ecart) {
      0 => "aujourd'hui",
      1 => 'demain',
      -1 => 'hier',
      > 1 && < 7 => _joursCourts[d.weekday - 1],
      _ => '${d.day} ${_mois[d.month - 1].substring(0, 3)}.',
    };
  }

  static String jourComplet(DateTime d) =>
      capitaliser('${_jours[d.weekday - 1]} ${d.day} ${_mois[d.month - 1]}');

  static String longue(DateTime d) => '${jourComplet(d)}, ${heure(d)}';

  static String courte(DateTime d) =>
      '${capitaliser(_joursCourts[d.weekday - 1])} ${d.day} ${_mois[d.month - 1].substring(0, 3)}.';

  static String groupe(DateTime d, [DateTime? maintenant]) =>
      switch (ecartJours(d, maintenant ?? DateTime.now())) {
        0 => "Aujourd'hui",
        1 => 'Demain',
        -1 => 'Hier',
        _ => jourComplet(d),
      };

  static bool cetteSemaine(DateTime d, [DateTime? maintenant]) =>
      ecartJours(d, maintenant ?? DateTime.now()) < 7;

  static String rappel(Duration? r) => switch (r) {
    null => 'Aucun',
    Duration(inMinutes: < 60) => '${r.inMinutes} min avant',
    Duration(inHours: < 24) => '${r.inHours} h avant',
    Duration(inDays: 1) => '1 jour avant',
    _ => '${r.inDays} jours avant',
  };

  static String restant(DateTime d, [DateTime? maintenant]) {
    final diff = d.difference(maintenant ?? DateTime.now());
    if (diff.isNegative) return 'En retard';
    if (diff.inHours < 1) return 'Dans ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Dans ${diff.inHours} h';
    return diff.inDays == 1 ? 'Dans 1 jour' : 'Dans ${diff.inDays} jours';
  }
}
