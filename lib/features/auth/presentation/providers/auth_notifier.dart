import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http_parser/http_parser.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/models/user.dart';
import '../../../../core/services/api_service.dart';

// ─── State ────────────────────────────────────────────────────
class AuthState {
  final bool isLoading;
  final User? user;
  final String? error;
  final bool needsProfile; 
  final bool hasSession; // True if a user has logged in once on this device

  AuthState({
    this.isLoading = false, 
    this.user, 
    this.error,
    this.needsProfile = false,
    this.hasSession = false,
  });

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    bool? isLoading,
    User? user,
    String? error,
    bool? needsProfile,
    bool? hasSession,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      error: error ?? this.error,
      needsProfile: needsProfile ?? this.needsProfile,
      hasSession: hasSession ?? this.hasSession,
    );
  }
}

// ─── Providers ────────────────────────────────────────────────
final apiServiceProvider = Provider((ref) => ApiService());
final secureStorageProvider = Provider((ref) => const FlutterSecureStorage());

final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});

// ─── Notifier ────────────────────────────────────────────────
class AuthNotifier extends Notifier<AuthState> {
  late final ApiService _api;
  late final FlutterSecureStorage _storage;

  @override
  AuthState build() {
    _api = ref.watch(apiServiceProvider);
    _storage = ref.watch(secureStorageProvider);
    
    // On lance l'init mais on retourne un état de chargement initial
    Future.microtask(() => _init());
    
    return AuthState(isLoading: true);
  }

  Future<void> _init() async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      final hasSession = await _storage.read(key: 'has_session') == 'true';

      if (token != null) {
        // Validation active du token avec /auth/me
        final response = await _api.get(ApiEndpoints.me);
        final user = User.fromJson(response.data['data']);
        
        // Mise à jour locale au cas où les infos ont changé
        await _storage.write(key: ApiConstants.userDataKey, value: jsonEncode(user.toJson()));
        
        state = AuthState(
          isLoading: false,
          user: user, 
          hasSession: true, 
        );
      } else {
        state = AuthState(
          isLoading: false,
          hasSession: hasSession, 
        );
      }
    } catch (e) {
      // Si erreur (token expiré par ex), on nettoie mais on garde l'info de session existante
      final hasSession = await _storage.read(key: 'has_session') == 'true';
      
      await _storage.delete(key: 'jwt_token');
      await _storage.delete(key: ApiConstants.userDataKey);
      
      state = AuthState(
        isLoading: false,
        hasSession: hasSession,
      );
    }
  }

  /// Vérification si un email existe
  Future<bool> checkEmail(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _api.post(ApiEndpoints.checkEmail, data: {
        'email': email.trim(),
      });
      state = state.copyWith(isLoading: false);
      return response.data['success'] ?? true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Demande de réinitialisation de mot de passe
  Future<bool> forgotPassword(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _api.post(ApiEndpoints.forgotPassword, data: {
        'email': email.trim(),
      });
      state = state.copyWith(isLoading: false);
      return response.data['success'] ?? true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Réinitialisation effective du mot de passe
  Future<bool> resetPassword({
    required String email,
    required String token,
    required String newPassword,
    required String confirmPassword,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _api.post(ApiEndpoints.resetPassword, data: {
        'email': email.trim(),
        'token': token.trim(),
        'password': newPassword,
        'confirmPassword': confirmPassword,
      });
      
      if (response.data['success'] == true) {
        // Optionnel: sauvegarder le nouveau mot de passe
        await saveCredentials(email, newPassword);
      }
      
      state = state.copyWith(isLoading: false);
      return response.data['success'] ?? true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Sauvegarde sécurisée des credentials
  Future<void> saveCredentials(String email, String password) async {
    await _storage.write(key: 'saved_pass_${email.trim().toLowerCase()}', value: password);
    // On garde trace du dernier email pour faciliter le remplissage
    await _storage.write(key: 'last_email', value: email.trim());
  }

  /// Récupération du mot de passe sauvegardé
  Future<String?> getSavedPassword(String email) async {
    return await _storage.read(key: 'saved_pass_${email.trim().toLowerCase()}');
  }

  /// Récupération du dernier email utilisé
  Future<String?> getLastEmail() async {
    return await _storage.read(key: 'last_email');
  }

  /// Login direct avec le Backend
  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _api.post(ApiEndpoints.login, data: {
        'email': email.trim(),
        'password': password,
      });

      final user = User.fromJson(response.data['data']['user']);
      final token = response.data['data']['token'];

      // Sauvegarde du token et des infos user
      await _storage.write(key: 'jwt_token', value: token);
      await _storage.write(key: ApiConstants.userDataKey, value: jsonEncode(user.toJson()));
      await _storage.write(key: 'has_session', value: 'true');
      
      // Sauvegarde des credentials pour la prochaine fois
      await saveCredentials(email, password);
      
      state = state.copyWith(isLoading: false, user: user, hasSession: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Register avec les nouveaux champs obligatoires
  Future<void> register({
    required String nom,
    required String prenom,
    required String email,
    required String password,
    required String confirmPassword,
    required UserRole role,
    String? telephone,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _api.post(ApiEndpoints.register, data: {
        'nom': nom,
        'prenom': prenom,
        'email': email.trim(),
        'password': password,
        'confirmPassword': confirmPassword,
        'role': role.name,
        'telephone': telephone,
      });

      final user = User.fromJson(response.data['data']['user']);
      final token = response.data['data']['token'];

      await _storage.write(key: 'jwt_token', value: token);
      await _storage.write(key: ApiConstants.userDataKey, value: jsonEncode(user.toJson()));
      await _storage.write(key: 'has_session', value: 'true');

      // Sauvegarde des credentials à l'inscription
      await saveCredentials(email, password);

      state = state.copyWith(isLoading: false, user: user, needsProfile: false, hasSession: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Update Profile + Role + Role-specific info + Photo
  Future<void> updateProfile({
    required String nom,
    required String prenom,
    required UserRole role,
    String? telephone,
    String? adresse,
    String? photoPath, // Chemin local de l'image sélectionnée (mobile)
    Uint8List? photoBytes, // Bytes de l'image (web ou mobile)
    String? photoName, // Nom du fichier
    String? matricule,
    String? specialite,
    String? numeroPermis,
    String? categoriePermis,
    String?  dateExpirationPermis,
    int?  kmCumule
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final currentUser = state.user;
      final Map<String, dynamic> data = {
        'nom': nom,
        'prenom': prenom,
        'telephone': telephone,
        'adresse': adresse,
      };

      // 🔹 On ne renvoie le rôle que si l'utilisateur est ADMIN
      // (Le backend rejette désormais les changements de rôle via /profiles pour les autres)
      if (currentUser?.isAdmin ?? false) {
        data['role'] = role.name;
      }

      // 🔹 Données spécifiques au rôle
      if (role == UserRole.TECHNICIEN) {
        data['matricule'] = matricule;
        data['specialite'] = specialite;
      } else if (role == UserRole.CHAUFFEUR) {
        data['numero_permis'] = numeroPermis;
        data['categorie_permis'] = categoriePermis;
      }

      // 🔹 Gestion upload image
      dynamic payload = data;

      if (photoBytes != null) {
        // Déterminer le type MIME
        final ext = photoName?.split('.').last.toLowerCase() ?? 'jpg';
        final mimeType = ext == 'png' ? 'image/png' : 'image/jpeg';

        payload = FormData.fromMap({
          ...data,
          'photo': MultipartFile.fromBytes(
            photoBytes,
            filename: photoName ?? 'profile_${state.user?.uuid ?? "user"}.jpg',
            contentType: MediaType.parse(mimeType),
          ),
        });
      } else if (photoPath != null && photoPath.isNotEmpty) {
        payload = FormData.fromMap({
          ...data,
          'photo': await MultipartFile.fromFile(
            photoPath,
            filename: 'profile_${state.user?.uuid ?? "user"}.jpg',
          ),
        });
      }

      // 🔹 Appel API vers le nouvel endpoint explicit
      final response = await _api.put(ApiEndpoints.profiles, data: payload);
      final responseData = response.data['data'];

      // ⚠️ Sécurisation parsing (le backend renvoie l'objet profile mis à jour)
      final updatedProfile = UserProfile.fromJson(
        responseData['profile'] ?? responseData,
      );

      final updatedRole = UserRole.fromString(
        responseData['role'] ?? role.name,
      );

      final roleInfo = responseData['role_info'];

      // 🔹 Mise à jour utilisateur
      if (state.user != null) {
        final updatedUser = User(
          uuid: state.user!.uuid,
          email: state.user!.email,
          role: updatedRole,
          isActive: state.user!.isActive,
          profile: updatedProfile,
          roleInfo: roleInfo is Map<String, dynamic> ? roleInfo : null,
        );

        // 🔹 Sauvegarde locale
        await _storage.write(
          key: ApiConstants.userDataKey,
          value: jsonEncode(updatedUser.toJson()),
        );

        state = state.copyWith(
          isLoading: false,
          user: updatedUser,
          needsProfile: false,
        );
      }
    } catch (e, stack) {
      debugPrint('Error updating profile: $e');
      debugPrint('Stack: $stack');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Logout
  Future<void> logout() async {
    await _storage.delete(key: 'jwt_token');
    await _storage.delete(key: ApiConstants.userDataKey);
    // On garde 'has_session' pour permettre de savoir si l'user a déjà été là
    state = AuthState(
      hasSession: state.hasSession,
    );
  }

  /// Clear session entirely (wipe everything)
  Future<void> clearAllData() async {
    await _storage.deleteAll();
    state = AuthState();
  }
}
