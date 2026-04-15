/// ============================================================
/// AutoPark IUC - AuthNotifier (Riverpod)
/// ============================================================
/// Gère l'état d'authentification global de l'application.
/// Expose : AuthState → { loading, user, error }
/// Utilisé par toutes les pages pour réagir à l'état auth.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../../core/services/api_service.dart';
import '../../../../core/services/firebase_service.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

// ─── State ────────────────────────────────────────────────────

/// État immutable de l'authentification.
class AuthState {
  final bool isLoading;
  final UserEntity? user;
  final String? errorMessage;
  final bool isAuthenticated;

  const AuthState({
    this.isLoading = false,
    this.user,
    this.errorMessage,
    this.isAuthenticated = false,
  });

  const AuthState.initial() : this();

  const AuthState.loading() : this(isLoading: true);

  AuthState.authenticated(UserEntity user)
      : this(user: user, isAuthenticated: true);

  AuthState.error(String message) : this(errorMessage: message);

  AuthState copyWith({
    bool? isLoading,
    UserEntity? user,
    String? errorMessage,
    bool? isAuthenticated,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

// ─── Providers ────────────────────────────────────────────────

final firebaseAuthServiceProvider = Provider<FirebaseAuthService>((ref) {
  return FirebaseAuthService();
});

final apiServiceProvider = Provider<ApiService>((ref) {
  final firebaseAuthService = ref.watch(firebaseAuthServiceProvider);
  return ApiService(firebaseAuthService);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    apiService: ref.watch(apiServiceProvider),
    firebaseAuthService: ref.watch(firebaseAuthServiceProvider),
  );
});

final authNotifierProvider =
StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});

// ─── Notifier ────────────────────────────────────────────────

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AuthState.initial()) {
    _restoreSession();
  }

  // ─── Restauration de session au démarrage ────────────────────

  /// Tente de restaurer la session utilisateur depuis le stockage local.
  Future<void> _restoreSession() async {
    state = const AuthState.loading();
    try {
      final user = await _repository.getCurrentUser();
      if (user != null) {
        state = AuthState.authenticated(user);
      } else {
        state = const AuthState.initial();
      }
    } catch (_) {
      state = const AuthState.initial();
    }
  }

  // ─── Register ────────────────────────────────────────────────

  /// Inscrit un nouvel utilisateur.
  /// En cas de succès, ne connecte PAS automatiquement (l'utilisateur doit login).
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    state = const AuthState.loading();
    try {
      await _repository.register(
        name: name,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
      );
      state = const AuthState.initial();
      return true;
    } on FirebaseAuthException catch (e) {
      state = AuthState.error(FirebaseAuthService.mapFirebaseAuthError(e));
      return false;
    } catch (e) {
      state = AuthState.error(e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }

  // ─── Login ───────────────────────────────────────────────────

  /// Connecte l'utilisateur et met à jour l'état global.
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = const AuthState.loading();
    try {
      final user = await _repository.login(email: email, password: password);
      state = AuthState.authenticated(user);
      return true;
    } on FirebaseAuthException catch (e) {
      state = AuthState.error(FirebaseAuthService.mapFirebaseAuthError(e));
      return false;
    } catch (e) {
      state = AuthState.error(e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }

  // ─── Logout ──────────────────────────────────────────────────

  Future<void> logout() async {
    await _repository.logout();
    state = const AuthState.initial();
  }

  /// Efface le message d'erreur (après affichage).
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}