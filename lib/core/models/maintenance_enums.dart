import 'package:flutter/material.dart';

enum PanneCriticite {
  MINEURE,
  MAJEURE,
  BLOQUANTE;

  String get label => switch (this) {
    PanneCriticite.MINEURE  => 'Mineure',
    PanneCriticite.MAJEURE  => 'Majeure',
    PanneCriticite.BLOQUANTE => 'Bloquante',
  };

  Color get color => switch (this) {
    PanneCriticite.MINEURE  => Colors.blue,
    PanneCriticite.MAJEURE  => Colors.orange,
    PanneCriticite.BLOQUANTE => Colors.red,
  };
}

enum PanneStatus {
  DECLAREE,
  VALIDEE,
  EN_DIAGNOSTIC,
  EN_REPARATION,
  CLOTUREE;

  String get label => switch (this) {
    PanneStatus.DECLAREE      => 'Déclarée',
    PanneStatus.VALIDEE       => 'Validée',
    PanneStatus.EN_DIAGNOSTIC => 'En Diagnostic',
    PanneStatus.EN_REPARATION => 'En Réparation',
    PanneStatus.CLOTUREE      => 'Clôturée',
  };
}

enum WorkOrderStatus {
  CREE,
  EN_COURS,
  TERMINE,
  ANNULE;

  String get label => switch (this) {
    WorkOrderStatus.CREE     => 'Créé',
    WorkOrderStatus.EN_COURS => 'En cours',
    WorkOrderStatus.TERMINE  => 'Terminé',
    WorkOrderStatus.ANNULE   => 'Annulé',
  };

  Color get color => switch (this) {
    WorkOrderStatus.CREE     => Colors.grey,
    WorkOrderStatus.EN_COURS => Colors.blue,
    WorkOrderStatus.TERMINE  => Colors.green,
    WorkOrderStatus.ANNULE   => Colors.red,
  };
}
