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

  AuthState({
    this.isLoading = false, 
    this.user, 
    this.error,
    this.needsProfile = false,
  });

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    bool? isLoading,
    User? user,
    String? error,
    bool? needsProfile,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      error: error ?? this.error,
      needsProfile: needsProfile ?? this.needsProfile,
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
    
    _init();
    
    return AuthState();
  }

  Future<void> _init() async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      final data = await _storage.read(key: ApiConstants.userDataKey);
      
      if (token != null && data != null) {
        state = AuthState(user: User.fromJson(jsonDecode(data)));
      }
    } catch (e) {
      // Ignorer l'erreur d'init
    }
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

      // Sauvegarde
      await _storage.write(key: 'jwt_token', value: token);
      await _storage.write(key: ApiConstants.userDataKey, value: jsonEncode(user.toJson()));
      
      state = state.copyWith(isLoading: false, user: user);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Register
  Future<void> register(String name, String email, String password, String confirm) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _api.post(ApiEndpoints.register, data: {
        'name': name,
        'email': email.trim(),
        'password': password,
        'confirmPassword': confirm,
      });

      final user = User.fromJson(response.data['data']['user']);
      final token = response.data['data']['token'];

      await _storage.write(key: 'jwt_token', value: token);
      await _storage.write(key: ApiConstants.userDataKey, value: jsonEncode(user.toJson()));

      state = state.copyWith(isLoading: false, user: user, needsProfile: true);
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
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final Map<String, dynamic> data = {
        'nom': nom,
        'prenom': prenom,
        'role': role.name,
        'telephone': telephone,
        'adresse': adresse,
      };

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

      // 🔹 Appel API
      final response = await _api.put('profile', data: payload);
      final responseData = response.data['data'];

      // ⚠️ Sécurisation parsing (sans changer logique)
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
          name: state.user!.name,
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
    state = AuthState();
  }
}
