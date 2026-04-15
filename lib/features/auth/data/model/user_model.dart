/// ============================================================
/// AutoPark IUC - Modèle Utilisateur (Data Layer)
/// ============================================================
/// Gère la sérialisation/désérialisation JSON ↔ UserEntity.
/// Reçoit les données du backend Express.

import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.name,
    required super.email,
    required super.role,
  });

  /// Désérialisation depuis la réponse JSON du backend.
  /// Structure attendue : { uid, name, email, role }
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: UserRoleExtension.fromString(json['role'] as String? ?? 'chauffeur'),
    );
  }

  /// Sérialisation vers JSON (pour le stockage local).
  Map<String, dynamic> toJson() => {
    'uid': uid,
    'name': name,
    'email': email,
    'role': role.name,
  };

  /// Conversion vers l'entité domaine.
  UserEntity toEntity() => UserEntity(
    uid: uid,
    name: name,
    email: email,
    role: role,
  );
}