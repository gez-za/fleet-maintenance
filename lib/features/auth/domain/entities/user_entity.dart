/// ============================================================
/// AutoPark IUC - Entité Utilisateur (Domain Layer)
/// ============================================================
/// Modèle immutable représentant un utilisateur dans le domaine.

import 'package:equatable/equatable.dart';

/// Rôles disponibles dans AutoPark.
enum UserRole {
  admin,
  chauffeur,
  technicien,
  directeur,
  chefChauffeur,
  responsableAtelier,
}

extension UserRoleExtension on UserRole {
  /// Conversion depuis la chaîne reçue du backend.
  static UserRole fromString(String role) {
    const map = {
      'admin': UserRole.admin,
      'chauffeur': UserRole.chauffeur,
      'technicien': UserRole.technicien,
      'directeur': UserRole.directeur,
      'chef_chauffeur': UserRole.chefChauffeur,
      'responsable_atelier': UserRole.responsableAtelier,
    };
    return map[role] ?? UserRole.chauffeur;
  }

  /// Label lisible pour l'affichage UI.
  String get label {
    const labels = {
      UserRole.admin: 'Administrateur',
      UserRole.chauffeur: 'Chauffeur',
      UserRole.technicien: 'Technicien',
      UserRole.directeur: 'Directeur',
      UserRole.chefChauffeur: 'Chef Chauffeur',
      UserRole.responsableAtelier: 'Responsable Atelier',
    };
    return labels[this] ?? 'Inconnu';
  }
}

/// Entité utilisateur du domaine.
/// Immuable, sans logique de sérialisation (séparée dans le data layer).
class UserEntity extends Equatable {
  final String uid;
  final String name;
  final String email;
  final UserRole role;

  const UserEntity({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
  });

  /// Vérifie si l'utilisateur a un rôle spécifique.
  bool hasRole(UserRole targetRole) => role == targetRole;

  /// Vérifie si l'utilisateur est admin.
  bool get isAdmin => role == UserRole.admin;

  @override
  List<Object?> get props => [uid, name, email, role];

  @override
  String toString() =>
      'UserEntity(uid: $uid, name: $name, email: $email, role: ${role.label})';
}