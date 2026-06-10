import '../../../core/models/demande_enums.dart';
import '../../../core/models/user.dart';
import '../../vehicles/models/vehicle.dart';

class Demande {
  final String id;
  final DemandeType type;
  final String? vehicleId;
  final Vehicle? vehicle;
  final String motif;
  final DemandePriority priority;
  final DemandeStatus status;
  final String? justificatif;
  final Map<String, dynamic> details;
  final String requesterId;
  final User? requester;
  final String? validatorId;
  final User? validator;
  final String? rejectionReason;
  final DateTime createdAt;
  final DateTime? validatedAt;

  const Demande({
    required this.id,
    required this.type,
    this.vehicleId,
    this.vehicle,
    required this.motif,
    required this.priority,
    required this.status,
    this.justificatif,
    this.details = const {},
    required this.requesterId,
    this.requester,
    this.validatorId,
    this.validator,
    this.rejectionReason,
    required this.createdAt,
    this.validatedAt,
  });

  factory Demande.fromJson(Map<String, dynamic> json) => Demande(
    id: json['id'].toString(),
    type: DemandeType.values.firstWhere(
      (e) => e.name == json['type'],
      orElse: () => DemandeType.AUTRE,
    ),
    vehicleId: json['vehicule_id']?.toString(),
    vehicle: json['vehicule'] != null ? Vehicle.fromJson(json['vehicule']) : null,
    motif: json['motif'] ?? '',
    priority: DemandePriority.values.firstWhere(
      (e) => e.name == json['priorite'] || e.name == json['priority'],
      orElse: () => DemandePriority.NORMALE,
    ),
    status: DemandeStatus.values.firstWhere(
      (e) => e.name == json['statut'] || e.name == json['status'],
      orElse: () => DemandeStatus.EN_ATTENTE,
    ),
    justificatif: json['justificatif'],
    details: json['details'] is Map<String, dynamic> ? json['details'] : {},
    requesterId: json['demandeur_id']?.toString() ?? '',
    requester: json['demandeur'] != null ? User.fromJson(json['demandeur']) : null,
    validatorId: json['validateur_id']?.toString(),
    validator: json['validateur'] != null ? User.fromJson(json['validateur']) : null,
    rejectionReason: json['motif_rejet'],
    createdAt: json['created_at'] != null 
        ? DateTime.parse(json['created_at']) 
        : DateTime.now(),
    validatedAt: json['validated_at'] != null ? DateTime.parse(json['validated_at']) : null,
  );

  Map<String, dynamic> toJson() => {
    'type': type.name,
    'vehicule_id': vehicleId,
    'motif': motif,
    'priorite': priority.name,
    'details': details,
  };
}

class Depense {
  final String id;
  final String? demandeId;
  final Demande? demande;
  final String label;
  final double amount;
  final String? justificatif;
  final DateTime date;
  final String? vehicleId;
  final Vehicle? vehicle;

  const Depense({
    required this.id,
    this.demandeId,
    this.demande,
    required this.label,
    required this.amount,
    this.justificatif,
    required this.date,
    this.vehicleId,
    this.vehicle,
  });

  factory Depense.fromJson(Map<String, dynamic> json) => Depense(
    id: json['id'].toString(),
    demandeId: json['demande_id']?.toString(),
    demande: json['demande'] != null ? Demande.fromJson(json['demande']) : null,
    label: json['libelle'] ?? json['label'] ?? '',
    amount: (json['montant'] as num?)?.toDouble() ?? 0.0,
    justificatif: json['justificatif'],
    date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
    vehicleId: json['vehicule_id']?.toString(),
    vehicle: json['vehicule'] != null ? Vehicle.fromJson(json['vehicule']) : null,
  );
}
