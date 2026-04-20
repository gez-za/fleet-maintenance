// ============================================================
// AutoPark IUC — Modèle utilisateur
// ============================================================

import 'dart:convert';

enum UserRole {
  admin,
  chauffeur,
  technicien,
  directeur,
  chefChauffeur,
  responsableAtelier;

  static UserRole fromString(String value) {
    const map = {
      'admin':               UserRole.admin,
      'chauffeur':           UserRole.chauffeur,
      'technicien':          UserRole.technicien,
      'directeur':           UserRole.directeur,
      'chef_chauffeur':      UserRole.chefChauffeur,
      'responsable_atelier': UserRole.responsableAtelier,
    };
    return map[value] ?? UserRole.chauffeur;
  }

  String get label => switch (this) {
    UserRole.admin              => 'Administrateur',
    UserRole.chauffeur          => 'Chauffeur',
    UserRole.technicien         => 'Technicien',
    UserRole.directeur          => 'Directeur',
    UserRole.chefChauffeur      => 'Chef Chauffeur',
    UserRole.responsableAtelier => 'Responsable Atelier',
  };

  bool get isAdmin => this == UserRole.admin;
}

class User {
  final String   uid;
  final String   name;
  final String   email;
  final UserRole role;
  final String?  photoUrl; // Optionnel — avatar profil

  const User({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.photoUrl,
  });

  bool get isAdmin => role.isAdmin;

  factory User.fromJson(Map<String, dynamic> json) => User(
    uid:      json['uid']      as String,
    name:     json['name']     as String,
    email:    json['email']    as String,
    role:     UserRole.fromString(json['role'] as String? ?? 'chauffeur'),
    photoUrl: json['photoUrl'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'uid':      uid,
    'name':     name,
    'email':    email,
    'role':     role.name,
    if (photoUrl != null) 'photoUrl': photoUrl,
  };

  String toStorageString()                   => jsonEncode(toJson());
  static User fromStorageString(String s) => User.fromJson(jsonDecode(s));

  @override
  String toString() => 'AppUser($email | ${role.label})';
}