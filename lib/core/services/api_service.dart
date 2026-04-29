import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/api_constants.dart';

/// Client HTTP simplifié et robuste pour l'API Express
class ApiService {
  late final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl.endsWith('/')
            ? ApiConstants.baseUrl
            : '${ApiConstants.baseUrl}/',
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Intercepteur JWT + logs debug
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'jwt_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        if (kDebugMode) {
          print('🌐 API Request: ${options.method} ${options.uri}');
          if (options.data != null) print('📦 Body: ${options.data}');
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        if (kDebugMode) {
          print('✅ API Response [${response.statusCode}]: ${response.data}');
        }
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        final message = _extractErrorMessage(e);
        if (kDebugMode) {
          print('❌ API Error [${e.response?.statusCode}]: $message');
        }
        return handler.next(e.copyWith(error: message));
      },
    ));
  }

  // ── GET ───────────────────────────────────────────────────────────────────

  Future<Response> get(String path, {Map<String, dynamic>? query}) async {
    try {
      return await _dio.get(path, queryParameters: query);
    } on DioException catch (e) {
      throw e.error ?? 'Erreur réseau';
    }
  }

  // ── POST ──────────────────────────────────────────────────────────────────

  Future<Response> post(String path, {dynamic data}) async {
    try {
      return await _dio.post(path, data: data);
    } on DioException catch (e) {
      throw e.error ?? 'Erreur réseau';
    }
  }

  // ── PUT ───────────────────────────────────────────────────────────────────

  Future<Response> put(String path, {dynamic data}) async {
    try {
      return await _dio.put(path, data: data);
    } on DioException catch (e) {
      throw e.error ?? 'Erreur réseau';
    }
  }

  // ── DELETE ────────────────────────────────────────────────────────────────

  Future<Response> delete(String path, {dynamic data}) async {
    try {
      return await _dio.delete(path, data: data);
    } on DioException catch (e) {
      throw e.error ?? 'Erreur réseau';
    }
  }

  // ── Extraction du message d'erreur backend ────────────────────────────────

  String _extractErrorMessage(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      return 'Impossible de contacter le serveur (Vérifiez votre connexion).';
    }

    final responseData = e.response?.data;
    if (responseData is Map) {
      if (responseData.containsKey('errors') &&
          responseData['errors'] is List) {
        final List errors = responseData['errors'];
        if (errors.isNotEmpty) {
          return '${responseData['message'] ?? 'Erreur'}: ${errors.join(", ")}';
        }
      }
      if (responseData.containsKey('message')) {
        return responseData['message'];
      }
    }

    return 'Une erreur inattendue est survenue (${e.response?.statusCode ?? '??'})';
  }
}