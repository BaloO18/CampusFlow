import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract interface class StockageJeton {
  Future<String?> lire();
  Future<void> ecrire(String jeton);
  Future<void> effacer();
}

class StockageJetonSecurise implements StockageJeton {
  StockageJetonSecurise([this._stockage = const FlutterSecureStorage()]);

  static const _cle = 'jeton';
  final FlutterSecureStorage _stockage;

  @override
  Future<String?> lire() => _stockage.read(key: _cle);

  @override
  Future<void> ecrire(String jeton) => _stockage.write(key: _cle, value: jeton);

  @override
  Future<void> effacer() => _stockage.delete(key: _cle);
}

class StockageJetonMemoire implements StockageJeton {
  StockageJetonMemoire([this.jeton]);

  String? jeton;

  @override
  Future<String?> lire() async => jeton;

  @override
  Future<void> ecrire(String jeton) async => this.jeton = jeton;

  @override
  Future<void> effacer() async => jeton = null;
}

final stockageJetonProvider = Provider<StockageJeton>(
  (ref) => StockageJetonSecurise(),
);
