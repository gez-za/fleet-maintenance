/// ============================================================
/// AutoPark IUC - Repository d'authentification (Interface)
/// ============================================================
/// Contrat abstrait du domaine.
/// Le data layer implémente cette interface (séparation des couches).

import '../entities/user_entity.dart';

abstract class AuthRepository {
  /// Inscrit un nouvel utilisateur via le backend Express.
  /// Le rôle est attribué par le backend — jamais par le client.
  ///
  /// Retourne [UserEntity] en cas de succès.
  /// Lance [Exception] en cas d'erreur.
  Future<UserEntity> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  });

  /// Connecte l'utilisateur via Firebase Auth puis le backend.
  /// Flux : Firebase login → ID Token → backend → profil complet avec rôle.
  Future<UserEntity> login({
    required String email,
    required String password,
  });

  /// Déconnecte l'utilisateur (Firebase + nettoyage local).
  Future<void> logout();

  /// Récupère le profil de l'utilisateur actuellement connecté.
  Future<UserEntity?> getCurrentUser();
}