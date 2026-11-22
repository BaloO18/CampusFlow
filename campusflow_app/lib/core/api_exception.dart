import 'package:dio/dio.dart';

class ApiException implements Exception {
  const ApiException(this.message, {this.statut});

  factory ApiException.depuis(DioException e) {
    final donnees = e.response?.data;
    final message = donnees is Map && donnees['message'] is String
        ? donnees['message'] as String
        : switch (e.type) {
            DioExceptionType.connectionTimeout ||
            DioExceptionType.receiveTimeout ||
            DioExceptionType.sendTimeout =>
              'Le serveur met trop de temps à répondre',
            DioExceptionType.connectionError => 'Serveur injoignable',
            _ => 'Erreur réseau (${e.response?.statusCode ?? e.type.name})',
          };
    return ApiException(message, statut: e.response?.statusCode);
  }

  final String message;
  final int? statut;

  bool get nonAuthentifie => statut == 401;

  @override
  String toString() => message;
}

Future<T> appelApi<T>(Future<T> Function() appel) async {
  try {
    return await appel();
  } on DioException catch (e) {
    throw ApiException.depuis(e);
  }
}
