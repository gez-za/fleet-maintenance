// ============================================================
// AutoPark IUC — Modèle utilisateur (Aligné avec Express Backend)
// ============================================================

import 'dart:convert';
import 'package:flutter/material.dart';

enum UserRole {
  ADMIN,
  DIRECTEUR,
  CHEF_ATELIER,
  TECHNICIEN,
  CHAUFFEUR;

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (e) => e.name == value.toUpperCase(),
      orElse: () => UserRole.CHAUFFEUR,
    );
  }

  String get label => switch (this) {
    UserRole.ADMIN         => 'Administrateur',
    UserRole.CHAUFFEUR     => 'Chauffeur',
    UserRole.TECHNICIEN    => 'Technicien',
    UserRole.DIRECTEUR     => 'Directeur',
    UserRole.CHEF_ATELIER  => 'Chef d\'Atelier',
  };

  bool get isAdmin => this == UserRole.ADMIN;

  IconData get icon => switch (this) {
    UserRole.ADMIN         => Icons.admin_panel_settings_outlined,
    UserRole.CHAUFFEUR     => Icons.directions_car_outlined,
    UserRole.TECHNICIEN    => Icons.build_outlined,
    UserRole.DIRECTEUR     => Icons.person_pin_outlined,
    UserRole.CHEF_ATELIER  => Icons.engineering_outlined,
  };
}

class UserProfile {
  final String id;
  final String nom;
  final String prenom;
  final String? telephone;
  final String? adresse;
  final String? photoUrl;

  const UserProfile({
    required this.id,
    required this.nom,
    required this.prenom,
    this.telephone,
    this.adresse,
    this.photoUrl,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    id: json['id'] as String,
    nom: json['nom'] as String? ?? '',
    prenom: json['prenom'] as String? ?? '',
    telephone: json['telephone'] as String?,
    adresse: json['adresse'] as String?,
    photoUrl: (json['photo_url'] ?? json['photoUrl']) as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'nom': nom,
    'prenom': prenom,
    if (telephone != null) 'telephone': telephone,
    if (adresse != null) 'adresse': adresse,
    if (photoUrl != null) 'photo_url': photoUrl,
  };
}

class User {
  final String uuid;
  final String name;
  final String email;
  final UserRole role;
  final bool isActive;
  final UserProfile? profile;
  final Map<String, dynamic>? roleInfo; // Pour les infos spécifiques (matricule, permis, etc.)

  const User({
    required this.uuid,
    required this.name,
    required this.email,
    required this.role,
    this.isActive = true,
    this.profile,
    this.roleInfo,
  });

  bool get isAdmin => role.isAdmin;

  bool get isProfileComplete {
    final p = profile;
    if (p == null) return false;
    // On considère complet si le téléphone et l'adresse sont remplis
    return p.telephone != null && p.telephone!.isNotEmpty &&
           p.adresse != null && p.adresse!.isNotEmpty;
  }

  factory User.fromJson(Map<String, dynamic> json) => User(
    uuid: json['uuid'] as String,
    name: json['name'] as String? ?? '',
    email: json['email'] as String,
    role: UserRole.fromString(json['role'] as String? ?? 'CHAUFFEUR'),
    isActive: json['is_active'] as bool? ?? true,
    profile: json['profile'] != null 
        ? UserProfile.fromJson(json['profile'] as Map<String, dynamic>) 
        : null,
    roleInfo: json['role_info'] as Map<String, dynamic>?,
  );

  Map<String, dynamic> toJson() => {
    'uuid': uuid,
    'name': name,
    'email': email,
    'role': role.name,
    'is_active': isActive,
    if (profile != null) 'profile': profile!.toJson(),
    if (roleInfo != null) 'role_info': roleInfo,
  };

  String toStorageString() => jsonEncode(toJson());
  static User fromStorageString(String s) => User.fromJson(jsonDecode(s));

  @override
  String toString() => 'User($email | ${role.label})';
}
