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
  CHAUFFEUR,
  CHEF_CHAUFFEUR;

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
    UserRole.CHEF_CHAUFFEUR => 'Chef Chauffeur',
  };

  bool get isAdmin => this == UserRole.ADMIN;

  IconData get icon => switch (this) {
    UserRole.ADMIN         => Icons.admin_panel_settings_outlined,
    UserRole.CHAUFFEUR     => Icons.directions_car_outlined,
    UserRole.TECHNICIEN    => Icons.build_outlined,
    UserRole.DIRECTEUR     => Icons.person_pin_outlined,
    UserRole.CHEF_ATELIER  => Icons.engineering_outlined,
    UserRole.CHEF_CHAUFFEUR => Icons.badge_outlined,
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
    id: (json['id'] ?? json['uuid'])?.toString() ?? '',
    nom: json['nom']?.toString() ?? '',
    prenom: json['prenom']?.toString() ?? '',
    telephone: json['telephone']?.toString(),
    adresse: json['adresse']?.toString(),
    photoUrl: (json['photo_url'] ?? json['photoUrl'])?.toString(),
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
  final String email;
  final UserRole role;
  final bool isActive;
  final UserProfile? profile;
  final Map<String, dynamic>? roleInfo; // Pour les infos spécifiques (matricule, permis, etc.)

  const User({
    required this.uuid,
    required this.email,
    required this.role,
    this.isActive = true,
    this.profile,
    this.roleInfo,
  });

  bool get isAdmin => role.isAdmin;

  String get displayName {
    if (profile != null) {
      final fullName = '${profile!.prenom} ${profile!.nom}'.trim();
      return fullName.isNotEmpty ? fullName : email.split('@')[0];
    }
    return email.split('@')[0];
  }

  bool get isProfileComplete {
    final p = profile;
    if (p == null) return false;
    // On considère complet si le téléphone et l'adresse sont remplis
    return p.telephone != null && p.telephone!.isNotEmpty &&
           p.adresse != null && p.adresse!.isNotEmpty;
  }

  factory User.fromJson(Map<String, dynamic> json) {
    // Le profil peut être soit dans un objet 'profile' imbriqué,
    // soit à la racine de l'objet utilisateur (données "à plat").
    UserProfile? userProfile;
    if (json['profile'] != null) {
      userProfile = UserProfile.fromJson(json['profile'] as Map<String, dynamic>);
    } else if (json.containsKey('nom') || json.containsKey('prenom')) {
      userProfile = UserProfile.fromJson(json);
    }

    return User(
      uuid: (json['uuid'] ?? json['id'])?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: UserRole.fromString(json['role'] as String? ?? 'CHAUFFEUR'),
      isActive: (json['is_active'] ?? json['isActive']) as bool? ?? true,
      profile: userProfile,
      roleInfo: json['role_info'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
    'uuid': uuid,
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
