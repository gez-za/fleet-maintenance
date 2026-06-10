import 'package:flutter/material.dart';

enum DemandeType {
  CARBURANT,
  PIECE,
  MAINTENANCE,
  AUTRE;

  String get label => switch (this) {
    DemandeType.CARBURANT   => 'Carburant',
    DemandeType.PIECE       => 'Pièce / Rechange',
    DemandeType.MAINTENANCE => 'Maintenance',
    DemandeType.AUTRE       => 'Autre',
  };

  IconData get icon => switch (this) {
    DemandeType.CARBURANT   => Icons.local_gas_station_rounded,
    DemandeType.PIECE       => Icons.settings_input_component_rounded,
    DemandeType.MAINTENANCE => Icons.build_rounded,
    DemandeType.AUTRE       => Icons.more_horiz_rounded,
  };
}

enum DemandeStatus {
  BROUILLON,
  EN_ATTENTE,
  VALIDEE,
  REJETEE,
  ANNULEE,
  CLOTUREE;

  String get label => switch (this) {
    DemandeStatus.BROUILLON   => 'Brouillon',
    DemandeStatus.EN_ATTENTE  => 'En attente',
    DemandeStatus.VALIDEE     => 'Validée',
    DemandeStatus.REJETEE     => 'Rejetée',
    DemandeStatus.ANNULEE     => 'Annulée',
    DemandeStatus.CLOTUREE    => 'Clôturée',
  };

  Color get color => switch (this) {
    DemandeStatus.BROUILLON   => Colors.grey,
    DemandeStatus.EN_ATTENTE  => Colors.orange,
    DemandeStatus.VALIDEE     => Colors.green,
    DemandeStatus.REJETEE     => Colors.red,
    DemandeStatus.ANNULEE     => Colors.blueGrey,
    DemandeStatus.CLOTUREE    => Colors.blue,
  };
}

enum DemandePriority {
  BASSE,
  NORMALE,
  HAUTE,
  URGENTE;

  String get label => switch (this) {
    DemandePriority.BASSE   => 'Basse',
    DemandePriority.NORMALE => 'Normale',
    DemandePriority.HAUTE   => 'Haute',
    DemandePriority.URGENTE => 'Urgente',
  };

  Color get color => switch (this) {
    DemandePriority.BASSE   => Colors.green,
    DemandePriority.NORMALE => Colors.blue,
    DemandePriority.HAUTE   => Colors.orange,
    DemandePriority.URGENTE => Colors.red,
  };
}
