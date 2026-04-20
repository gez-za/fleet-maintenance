import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../constants/api_constants.dart';

/// Client HTTP simplifié et robuste
class ApiService {
  late final Dio _dio;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl.endsWith('/') 
            ? ApiConstants.baseUrl 
            : '${ApiConstants.baseUrl}/',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Intercepteur pour le token et les logs
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final user = _auth.currentUser;
        if (user != null) {
          final token = await user.getIdToken();
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
        // On renvoie une nouvelle erreur avec le message simplifié
        return handler.next(e.copyWith(error: message));
      },
    ));
  }

  // GET
  Future<Response> get(String path, {Map<String, dynamic>? query}) async {
    try {
      return await _dio.get(path, queryParameters: query);
    } on DioException catch (e) {
      throw e.error ?? 'Erreur réseau';
    }
  }

  // POST
  Future<Response> post(String path, {dynamic data}) async {
    try {
      return await _dio.post(path, data: data);
    } on DioException catch (e) {
      throw e.error ?? 'Erreur réseau';
    }
  }

  /// Extrait le message d'erreur du backend ou de Dio
  String _extractErrorMessage(DioException e) {
    if (e.type == DioExceptionType.connectionError || e.type == DioExceptionType.connectionTimeout) {
      return 'Impossible de contacter le serveur (Vérifiez votre connexion).';
    }
    
    final responseData = e.response?.data;
    if (responseData is Map && responseData.containsKey('message')) {
      return responseData['message'];
    }
    
    if (responseData is Map && responseData.containsKey('error')) {
      return responseData['error'];
    }

    return 'Une erreur inattendue est survenue (${e.response?.statusCode ?? '??'})';
  }
}
