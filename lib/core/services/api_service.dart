/// ============================================================
/// AutoPark IUC - Service HTTP (Dio)
/// ============================================================
/// Client HTTP centralisé avec intercepteurs pour :
/// - Ajout automatique du token d'auth
/// - Gestion des erreurs réseau
/// - Logging des requêtes

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../core/constants/api_constants.dart';
import '../../core/constants/api_endpoints.dart';

import 'firebase_service.dart';

class ApiService {
  late final Dio _dio;

  /// Injection du FirebaseAuthService pour récupérer le token.
  final FirebaseAuthService _firebaseAuthService;

  ApiService(this._firebaseAuthService) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(_buildAuthInterceptor());

    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
      ));
    }
  }

  // ─── Intercepteur d'authentification ────────────────────────

  /// Ajoute automatiquement le Bearer token Firebase à chaque requête.
  InterceptorsWrapper _buildAuthInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Certaines routes sont publiques (login, register)
        final isPublicRoute = options.path == ApiEndpoints.login ||
            options.path == ApiEndpoints.register;

        if (!isPublicRoute) {
          final token = await _firebaseAuthService.getIdToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
        }

        handler.next(options);
      },
      onError: (error, handler) {
        debugPrint('[ApiService] Erreur : ${error.message}');
        handler.next(error);
      },
    );
  }

  // ─── Méthodes HTTP ───────────────────────────────────────────

  Future<Response> post(String path, {Map<String, dynamic>? data}) async {
    try {
      return await _dio.post(path, data: data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response> get(String path) async {
    try {
      return await _dio.get(path);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ─── Gestion des erreurs Dio ─────────────────────────────────

  Exception _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return Exception(
          'Impossible de joindre le serveur. Vérifiez votre connexion.');
    }

    final response = e.response;
    if (response != null) {
      final message = response.data?['message'] ?? 'Une erreur est survenue.';
      return Exception(message);
    }

    return Exception('Une erreur inattendue est survenue.');
  }
}