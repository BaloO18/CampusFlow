typedef JsonMap = Map<String, dynamic>;

T champ<T>(JsonMap json, String cle) {
  final valeur = json[cle];
  if (valeur is T) return valeur;
  throw FormatException('Champ « $cle » manquant ou invalide : $valeur');
}

T? champFacultatif<T>(JsonMap json, String cle) {
  final valeur = json[cle];
  if (valeur == null || valeur is T) return valeur as T?;
  throw FormatException('Champ « $cle » invalide : $valeur');
}

DateTime date(JsonMap json, String cle) {
  final texte = champ<String>(json, cle);
  final d = DateTime.tryParse(texte);
  if (d == null) throw FormatException('Date « $cle » invalide : $texte');
  return d;
}
