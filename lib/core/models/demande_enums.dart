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
  CREEE,
  VALIDEE_ATELIER,
  VALIDEE_DIRECTION,
  BON_GENERE,
  DECAISSEE,
  REJETEE,
  ANNULEE,
  TERMINEE;

  String get label => switch (this) {
    DemandeStatus.CREEE            => 'Créée',
    DemandeStatus.VALIDEE_ATELIER   => 'Validée Atelier',
    DemandeStatus.VALIDEE_DIRECTION => 'Validée Direction',
    DemandeStatus.BON_GENERE       => 'Bon Généré',
    DemandeStatus.DECAISSEE        => 'Déccaissée',
    DemandeStatus.REJETEE          => 'Rejetée',
    DemandeStatus.ANNULEE          => 'Annulée',
    DemandeStatus.TERMINEE         => 'Terminée',
  };

  Color get color => switch (this) {
    DemandeStatus.CREEE            => Colors.orange,
    DemandeStatus.VALIDEE_ATELIER   => Colors.blue,
    DemandeStatus.VALIDEE_DIRECTION => Colors.indigo,
    DemandeStatus.BON_GENERE       => Colors.purple,
    DemandeStatus.DECAISSEE        => Colors.teal,
    DemandeStatus.REJETEE          => Colors.red,
    DemandeStatus.ANNULEE          => Colors.blueGrey,
    DemandeStatus.TERMINEE         => Colors.green,
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
