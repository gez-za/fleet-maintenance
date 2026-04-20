import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/models/user.dart';
import '../../../../core/services/api_service.dart';

// ─── State ────────────────────────────────────────────────────
class AuthState {
  final bool isLoading;
  final User? user;
  final String? error;

  AuthState({this.isLoading = false, this.user, this.error});

  // Helper pour vérifier si authentifié
  bool get isAuthenticated => user != null;
}

// ─── Providers ────────────────────────────────────────────────
final apiServiceProvider = Provider((ref) => ApiService());
final secureStorageProvider = Provider((ref) => const FlutterSecureStorage());

/// Utilisation de NotifierProvider (plus moderne et stable)
final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});

// ─── Notifier ────────────────────────────────────────────────
class AuthNotifier extends Notifier<AuthState> {
  late final ApiService _api;
  late final FlutterSecureStorage _storage;
  final _firebase = firebase.FirebaseAuth.instance;

  @override
  AuthState build() {
    _api = ref.watch(apiServiceProvider);
    _storage = ref.watch(secureStorageProvider);
    
    // Initialisation asynchrone sans bloquer le build
    _init();
    
    return AuthState();
  }

  /// Initialisation : restaurer l'utilisateur s'il existe
  Future<void> _init() async {
    try {
      final data = await _storage.read(key: ApiConstants.userDataKey);
      if (data != null && _firebase.currentUser != null) {
        state = AuthState(user: User.fromJson(jsonDecode(data)));
      }
    } catch (e) {
      // Ignorer l'erreur d'init
    }
  }

  /// Login : Firebase -> Backend -> Local Storage
  Future<void> login(String email, String password) async {
    state = AuthState(isLoading: true);
    try {
      // 1. Firebase Login
      final cred = await _firebase.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      final idToken = await cred.user?.getIdToken();

      // 2. Backend Login
      final response = await _api.post(ApiEndpoints.login, data: {'idToken': idToken});
      final user = User.fromJson(response.data['data']['user']);

      // 3. Save & Update State
      await _storage.write(key: ApiConstants.userDataKey, value: jsonEncode(user.toJson()));
      state = AuthState(user: user);
    } catch (e) {
      state = AuthState(error: e.toString());
    }
  }

  /// Register
  Future<void> register(String name, String email, String password, String confirm) async {
    state = AuthState(isLoading: true);
    try {
      await _api.post(ApiEndpoints.register, data: {
        'name': name,
        'email': email.trim(),
        'password': password,
        'confirmPassword': confirm,
      });
      state = AuthState(); // Retour à l'état initial pour que l'user se loggue
    } catch (e) {
      state = AuthState(error: e.toString());
    }
  }

  /// Logout
  Future<void> logout() async {
    await _firebase.signOut();
    await _storage.delete(key: ApiConstants.userDataKey);
    state = AuthState();
  }
}
