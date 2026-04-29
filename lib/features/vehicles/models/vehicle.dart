import 'package:flutter/material.dart';

// ============================================================
// ENUM : vehicule_categorie  (PostgreSQL)
// ============================================================

enum VehicleCategorie {
  SCOLAIRE,
  SERVICE,
  MISSION,
  UTILITAIRE;

  String get label => switch (this) {
    VehicleCategorie.SCOLAIRE   => 'Scolaire',
    VehicleCategorie.SERVICE    => 'Service',
    VehicleCategorie.MISSION    => 'Mission',
    VehicleCategorie.UTILITAIRE => 'Utilitaire',
  };

  Color get color => switch (this) {
    VehicleCategorie.SCOLAIRE   => const Color(0xFFF59E0B),
    VehicleCategorie.SERVICE    => const Color(0xFF3570F4),
    VehicleCategorie.MISSION    => const Color(0xFF0D9488),
    VehicleCategorie.UTILITAIRE => const Color(0xFFf97316),
  };

  IconData get icon => switch (this) {
    VehicleCategorie.SCOLAIRE   => Icons.directions_bus_outlined,
    VehicleCategorie.SERVICE    => Icons.directions_car_outlined,
    VehicleCategorie.MISSION    => Icons.explore_outlined,
    VehicleCategorie.UTILITAIRE => Icons.local_shipping_outlined,
  };

  static VehicleCategorie fromString(String? value) =>
      VehicleCategorie.values.firstWhere(
            (e) => e.name == value?.toUpperCase(),
        orElse: () => VehicleCategorie.SERVICE,
      );
}

// ============================================================
// ENUM : vehicule_statut  (PostgreSQL)
// ============================================================

enum VehicleStatut {
  DISPONIBLE,
  EN_MISSION,
  EN_PANNE,
  EN_ATELIER,
  HORS_SERVICE;

  String get label => switch (this) {
    VehicleStatut.DISPONIBLE   => 'Disponible',
    VehicleStatut.EN_MISSION   => 'En Mission',
    VehicleStatut.EN_PANNE     => 'En Panne',
    VehicleStatut.EN_ATELIER   => 'En Atelier',
    VehicleStatut.HORS_SERVICE => 'Hors Service',
  };

  Color get color => switch (this) {
    VehicleStatut.DISPONIBLE   => const Color(0xFF0D9488),
    VehicleStatut.EN_MISSION   => const Color(0xFF3570F4),
    VehicleStatut.EN_PANNE     => const Color(0xFFE11D48),
    VehicleStatut.EN_ATELIER   => const Color(0xFFF59E0B),
    VehicleStatut.HORS_SERVICE => const Color(0xFF64748B),
  };

  IconData get icon => switch (this) {
    VehicleStatut.DISPONIBLE   => Icons.check_circle_outline,
    VehicleStatut.EN_MISSION   => Icons.local_shipping_outlined,
    VehicleStatut.EN_PANNE     => Icons.error_outline,
    VehicleStatut.EN_ATELIER   => Icons.build_circle_outlined,
    VehicleStatut.HORS_SERVICE => Icons.block_flipped,
  };

  /// Vrai uniquement si le véhicule peut être affecté à une mission
  bool get isAssignable => this == VehicleStatut.DISPONIBLE;

  static VehicleStatut fromString(String? value) =>
      VehicleStatut.values.firstWhere(
            (e) => e.name == value?.toUpperCase(),
        orElse: () => VehicleStatut.DISPONIBLE,
      );
}

// ============================================================
// CLASSE : Vehicle  — reflète exactement la table `vehicules`
// ============================================================

class Vehicle {
  final String           id;
  final String           immatriculation;  // immatriculation
  final String           marque;           // marque
  final String           modele;           // modele
  final int              annee;            // annee  (SMALLINT)
  final String?          image;            // image  (TEXT NOT NULL dans le schéma)
  final String?          numeroChassis;    // numero_chassis  (UNIQUE)
  final VehicleCategorie categorie;        // categorie  (ENUM vehicule_categorie)
  final VehicleStatut    statut;           // statut    (ENUM vehicule_statut)
  final int              kmActuel;         // km_actuel  (INTEGER DEFAULT 0)
  final DateTime?        createdAt;
  final DateTime?        updatedAt;

  const Vehicle({
    required this.id,
    required this.immatriculation,
    required this.marque,
    required this.modele,
    required this.annee,
    this.image,
    this.numeroChassis,
    required this.categorie,
    required this.statut,
    this.kmActuel = 0,
    this.createdAt,
    this.updatedAt,
  });

  // ----------------------------------------------------------
  // Désérialisation depuis l'API (clés = colonnes PostgreSQL)
  // ----------------------------------------------------------
  factory Vehicle.fromJson(Map<String, dynamic> json) => Vehicle(
    id:              json['id']?.toString() ?? '',
    immatriculation: json['immatriculation'] ?? '',
    marque:          json['marque']          ?? '',
    modele:          json['modele']          ?? '',
    annee:           (json['annee']   as num?)?.toInt() ?? 0,
    image:           json['image'],
    numeroChassis:   json['numero_chassis'],
    categorie:       VehicleCategorie.fromString(json['categorie']),
    statut:          VehicleStatut.fromString(json['statut']),
    kmActuel:        (json['km_actuel'] as num?)?.toInt() ?? 0,
    createdAt:       json['created_at'] != null
        ? DateTime.tryParse(json['created_at'])
        : null,
    updatedAt:       json['updated_at'] != null
        ? DateTime.tryParse(json['updated_at'])
        : null,
  );

  // ----------------------------------------------------------
  // Sérialisation vers l'API (clés = colonnes PostgreSQL)
  // ----------------------------------------------------------
  Map<String, dynamic> toJson() => {
    'id':              id,
    'immatriculation': immatriculation,
    'marque':          marque,
    'modele':          modele,
    'annee':           annee,
    'image':           image,
    'numero_chassis':  numeroChassis,
    'categorie':       categorie.name,  // ex: "SERVICE"
    'statut':          statut.name,     // ex: "DISPONIBLE"
    'km_actuel':       kmActuel,
  };

  // ----------------------------------------------------------
  // copyWith — utile pour les mises à jour partielles
  // ----------------------------------------------------------
  Vehicle copyWith({
    String?           id,
    String?           immatriculation,
    String?           marque,
    String?           modele,
    int?              annee,
    String?           image,
    String?           numeroChassis,
    VehicleCategorie? categorie,
    VehicleStatut?    statut,
    int?              kmActuel,
    DateTime?         createdAt,
    DateTime?         updatedAt,
  }) =>
      Vehicle(
        id:              id              ?? this.id,
        immatriculation: immatriculation ?? this.immatriculation,
        marque:          marque          ?? this.marque,
        modele:          modele          ?? this.modele,
        annee:           annee           ?? this.annee,
        image:           image           ?? this.image,
        numeroChassis:   numeroChassis   ?? this.numeroChassis,
        categorie:       categorie       ?? this.categorie,
        statut:          statut          ?? this.statut,
        kmActuel:        kmActuel        ?? this.kmActuel,
        createdAt:       createdAt       ?? this.createdAt,
        updatedAt:       updatedAt       ?? this.updatedAt,
      );

  @override
  String toString() =>
      'Vehicle($immatriculation · $marque $modele · $annee · ${statut.label})';
}