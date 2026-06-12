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
  EN_DIAGNOSTIC,
  VALIDEE,
  EN_COURS,
  CLOTUREE;

  String get label => switch (this) {
    PanneStatus.DECLAREE      => 'Déclarée',
    PanneStatus.EN_DIAGNOSTIC => 'En Diagnostic',
    PanneStatus.VALIDEE       => 'Validée',
    PanneStatus.EN_COURS      => 'En Cours',
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
