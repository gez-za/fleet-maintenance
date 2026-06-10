import '../../../core/models/maintenance_enums.dart';
import '../../../core/models/user.dart';
import '../../vehicles/models/vehicle.dart';

class Fault {
  final String id;
  final String vehicleId;
  final Vehicle? vehicle;
  final String description;
  final PanneCriticite criticality;
  final PanneStatus status;
  final String? photo;
  final double? latitude;
  final double? longitude;
  final String? addressApprox;
  final String reporterId;
  final User? reporter;
  final String? technicianId;
  final User? technician;
  final String? diagnostic;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Fault({
    required this.id,
    required this.vehicleId,
    this.vehicle,
    required this.description,
    required this.criticality,
    required this.status,
    this.photo,
    this.latitude,
    this.longitude,
    this.addressApprox,
    required this.reporterId,
    this.reporter,
    this.technicianId,
    this.technician,
    this.diagnostic,
    required this.createdAt,
    this.updatedAt,
  });

  factory Fault.fromJson(Map<String, dynamic> json) => Fault(
    id: json['id'].toString(),
    vehicleId: json['vehicule_id']?.toString() ?? json['vehicleId']?.toString() ?? '',
    vehicle: json['vehicule'] != null ? Vehicle.fromJson(json['vehicule']) : null,
    description: json['description'] ?? '',
    criticality: PanneCriticite.values.firstWhere(
      (e) => e.name == json['criticite'] || e.name == json['criticality'],
      orElse: () => PanneCriticite.MINEURE,
    ),
    status: PanneStatus.values.firstWhere(
      (e) => e.name == json['statut'] || e.name == json['status'],
      orElse: () => PanneStatus.DECLAREE,
    ),
    photo: json['photo'],
    latitude: (json['gps_latitude'] as num?)?.toDouble() ?? (json['latitude'] as num?)?.toDouble(),
    longitude: (json['gps_longitude'] as num?)?.toDouble() ?? (json['longitude'] as num?)?.toDouble(),
    addressApprox: json['adresse_approx'] ?? json['addressApprox'],
    reporterId: json['declarant_id']?.toString() ?? json['reporterId']?.toString() ?? '',
    reporter: json['declarant'] != null ? User.fromJson(json['declarant']) : null,
    technicianId: json['technicien_id']?.toString() ?? json['technicianId']?.toString(),
    technician: json['technicien'] != null ? User.fromJson(json['technicien']) : null,
    diagnostic: json['diagnostic'],
    createdAt: json['created_at'] != null 
        ? DateTime.parse(json['created_at']) 
        : DateTime.now(),
    updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'vehicule_id': vehicleId,
    'description': description,
    'criticite': criticality.name,
    'statut': status.name,
    'photo': photo,
    'gps_latitude': latitude,
    'gps_longitude': longitude,
    'adresse_approx': addressApprox,
    'declarant_id': reporterId,
    'technicien_id': technicianId,
    'diagnostic': diagnostic,
  };

  Fault copyWith({
    String? id,
    String? vehicleId,
    Vehicle? vehicle,
    String? description,
    PanneCriticite? criticality,
    PanneStatus? status,
    String? photo,
    double? latitude,
    double? longitude,
    String? addressApprox,
    String? reporterId,
    User? reporter,
    String? technicianId,
    User? technician,
    String? diagnostic,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Fault(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      vehicle: vehicle ?? this.vehicle,
      description: description ?? this.description,
      criticality: criticality ?? this.criticality,
      status: status ?? this.status,
      photo: photo ?? this.photo,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      addressApprox: addressApprox ?? this.addressApprox,
      reporterId: reporterId ?? this.reporterId,
      reporter: reporter ?? this.reporter,
      technicianId: technicianId ?? this.technicianId,
      technician: technician ?? this.technician,
      diagnostic: diagnostic ?? this.diagnostic,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
