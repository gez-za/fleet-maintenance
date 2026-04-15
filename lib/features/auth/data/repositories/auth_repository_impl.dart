/// ============================================================
/// AutoPark IUC - Implémentation du Repository Auth (Data Layer)
/// ============================================================
/// Orchestre :
///   1. Firebase Auth (connexion/déconnexion)
///   2. API Express (register, login avec token, profil)
///   3. Stockage local (persistance de session)

import 'dart:convert';
import 'package:fleet_maintenance_app/core/constants/api_endpoints.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/firebase_service.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/model/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiService _apiService;
  final FirebaseAuthService _firebaseAuthService;
  final FlutterSecureStorage _secureStorage;

  AuthRepositoryImpl({
    required ApiService apiService,
    required FirebaseAuthService firebaseAuthService,
    FlutterSecureStorage? secureStorage,
  })  : _apiService = apiService,
        _firebaseAuthService = firebaseAuthService,
        _secureStorage = secureStorage ?? const FlutterSecureStorage();

  // ─── Register ────────────────────────────────────────────────

  /// Inscription : envoie les données au backend Express.
  /// Le backend crée l'utilisateur Firebase et attribue le rôle "chauffeur".
  ///
  /// ⚠️ Aucun rôle n'est envoyé dans le body — le backend l'impose.
  @override
  Future<UserEntity> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    final response = await _apiService.post(
      ApiEndpoints.register,
      data: {
        'name': name,
        'email': email,
        'password': password,
        'confirmPassword': confirmPassword,
        // ⛔ Pas de champ 'role' — jamais envoyé côté client
      },
    );

    final userData = response.data['data']['user'] as Map<String, dynamic>;
    final user = UserModel.fromJson(userData);

    debugPrint('[AuthRepository] Inscription réussie : ${user.email}');
    return user.toEntity();
  }

  // ─── Login ───────────────────────────────────────────────────

  /// Connexion en deux étapes :
  /// 1. Firebase Auth → ID Token
  /// 2. Backend Express → profil complet avec rôle
  @override
  Future<UserEntity> login({
    required String email,
    required String password,
  }) async {
    // Étape 1 : Connexion Firebase — récupère l'ID Token
    final idToken = await _firebaseAuthService.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    debugPrint('[AuthRepository] Firebase login OK, envoi token au backend...');

    // Étape 2 : Envoi du token au backend Express — reçoit le profil avec rôle
    final response = await _apiService.post(
      ApiEndpoints.login,
      data: {'idToken': idToken},
    );

    final userData = response.data['data']['user'] as Map<String, dynamic>;
    final user = UserModel.fromJson(userData);

    // Persistance locale sécurisée de la session
    await _saveUserLocally(user);

    debugPrint('[AuthRepository] Login complet : ${user.email} | Rôle : ${user.role.label}');
    return user.toEntity();
  }

  // ─── Logout ──────────────────────────────────────────────────

  @override
  Future<void> logout() async {
    await _firebaseAuthService.signOut();
    await _clearLocalUser();
    debugPrint('[AuthRepository] Utilisateur déconnecté.');
  }

  // ─── GetCurrentUser ──────────────────────────────────────────

  /// Récupère l'utilisateur depuis le stockage local sécurisé.
  /// Utilisé pour restaurer la session au démarrage de l'app.
  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      // Vérifie si Firebase Auth a encore une session active
      if (!_firebaseAuthService.isLoggedIn) return null;

      final userJson = await _secureStorage.read(key: ApiConstants.userDataKey);
      if (userJson == null) return null;

      final userData = jsonDecode(userJson) as Map<String, dynamic>;
      return UserModel.fromJson(userData).toEntity();
    } catch (e) {
      debugPrint('[AuthRepository] Erreur lecture session locale : $e');
      return null;
    }
  }

  // ─── Helpers privés ──────────────────────────────────────────

  Future<void> _saveUserLocally(UserModel user) async {
    await _secureStorage.write(
      key: ApiConstants.userDataKey,
      value: jsonEncode(user.toJson()),
    );
  }

  Future<void> _clearLocalUser() async {
    await _secureStorage.delete(key: ApiConstants.userDataKey);
  }
}