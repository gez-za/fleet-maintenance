import 'package:flutter/material.dart';

/// Correspond à l'ENUM PostgreSQL : vehicule_categorie
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
    VehicleCategorie.SCOLAIRE   => Colors.yellow.shade700,
    VehicleCategorie.SERVICE    => Colors.blue,
    VehicleCategorie.MISSION    => Colors.green,
    VehicleCategorie.UTILITAIRE => Colors.orange,
  };

  IconData get icon => switch (this) {
    VehicleCategorie.SCOLAIRE   => Icons.directions_bus_outlined,
    VehicleCategorie.SERVICE    => Icons.directions_car_outlined,
    VehicleCategorie.MISSION    => Icons.explore_outlined,
    VehicleCategorie.UTILITAIRE => Icons.local_shipping_outlined,
  };

  /// Désérialisation depuis la valeur PostgreSQL (insensible à la casse)
  static VehicleCategorie fromString(String value) {
    return VehicleCategorie.values.firstWhere(
          (e) => e.name == value.toUpperCase(),
      orElse: () => VehicleCategorie.SERVICE,
    );
  }
}

/// Correspond à l'ENUM PostgreSQL : vehicule_statut
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
    VehicleStatut.DISPONIBLE   => Colors.green,
    VehicleStatut.EN_MISSION   => Colors.blue,
    VehicleStatut.EN_PANNE     => Colors.red,
    VehicleStatut.EN_ATELIER   => Colors.orange,
    VehicleStatut.HORS_SERVICE => Colors.grey,
  };

  IconData get icon => switch (this) {
    VehicleStatut.DISPONIBLE   => Icons.check_circle_outline,
    VehicleStatut.EN_MISSION   => Icons.directions_outlined,
    VehicleStatut.EN_PANNE     => Icons.warning_amber_outlined,
    VehicleStatut.EN_ATELIER   => Icons.build_outlined,
    VehicleStatut.HORS_SERVICE => Icons.cancel_outlined,
  };

  /// Indique si le véhicule peut être affecté à une mission
  bool get isAssignable => this == VehicleStatut.DISPONIBLE;

  /// Désérialisation depuis la valeur PostgreSQL (insensible à la casse)
  static VehicleStatut fromString(String value) {
    return VehicleStatut.values.firstWhere(
          (e) => e.name == value.toUpperCase(),
      orElse: () => VehicleStatut.DISPONIBLE,
    );
  }
}