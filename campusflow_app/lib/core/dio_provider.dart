import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/application/auth_notifier.dart';
import 'stockage_jeton.dart';

const _apiUrl = String.fromEnvironment('API_URL');

String adresseApiParDefaut() {
  if (_apiUrl.isNotEmpty) return _apiUrl;
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    return 'http://10.0.2.2:3000';
  }
  return 'http://localhost:3000';
}

class JetonInterceptor extends Interceptor {
  JetonInterceptor({required this.lireJeton, required this.surExpiration});

  final Future<String?> Function() lireJeton;
  final void Function() surExpiration;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final jeton = await lireJeton();
    if (jeton != null) options.headers['Authorization'] = 'Bearer $jeton';
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final versLogin = err.requestOptions.path == '/login';
    if (err.response?.statusCode == 401 && !versLogin) surExpiration();
    handler.next(err);
  }
}

final adresseApiProvider = Provider<String>((ref) => adresseApiParDefaut());

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ref.watch(adresseApiProvider),
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
    ),
  );
  dio.interceptors.add(
    JetonInterceptor(
      lireJeton: ref.read(stockageJetonProvider).lire,
      surExpiration: () => ref.read(authProvider.notifier).expirer(),
    ),
  );
  ref.onDispose(dio.close);
  return dio;
});
