import '../../../core/models/maintenance_enums.dart';
import '../../../core/models/user.dart';
import '../../faults/models/fault.dart';

class WorkOrder {
  final String id;
  final String faultId;
  final Fault? fault;
  final String description;
  final WorkOrderStatus status;
  final String technicianId;
  final User? technician;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<dynamic>? parts; 
  final DateTime createdAt;
  final DateTime? updatedAt;

  const WorkOrder({
    required this.id,
    required this.faultId,
    this.fault,
    required this.description,
    required this.status,
    required this.technicianId,
    this.technician,
    this.startDate,
    this.endDate,
    this.parts,
    required this.createdAt,
    this.updatedAt,
  });

  factory WorkOrder.fromJson(Map<String, dynamic> json) => WorkOrder(
    id: json['id'].toString(),
    faultId: json['panne_id']?.toString() ?? json['faultId']?.toString() ?? '',
    fault: json['panne'] != null ? Fault.fromJson(json['panne']) : null,
    description: json['description'] ?? '',
    status: WorkOrderStatus.values.firstWhere(
      (e) => e.name == json['statut'] || e.name == json['status'],
      orElse: () => WorkOrderStatus.CREE,
    ),
    technicianId: json['technicien_id']?.toString() ?? json['technicianId']?.toString() ?? '',
    technician: json['technicien'] != null ? User.fromJson(json['technicien']) : null,
    startDate: json['date_debut'] != null ? DateTime.parse(json['date_debut']) : null,
    endDate: json['date_fin'] != null ? DateTime.parse(json['date_fin']) : null,
    parts: json['pieces'] ?? json['parts'],
    createdAt: json['created_at'] != null 
        ? DateTime.parse(json['created_at']) 
        : DateTime.now(),
    updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'panne_id': faultId,
    'description': description,
    'statut': status.name,
    'technicien_id': technicianId,
    'date_debut': startDate?.toIso8601String(),
    'date_fin': endDate?.toIso8601String(),
    'pieces': parts,
  };

  WorkOrder copyWith({
    String? id,
    String? faultId,
    Fault? fault,
    String? description,
    WorkOrderStatus? status,
    String? technicianId,
    User? technician,
    DateTime? startDate,
    DateTime? endDate,
    List<dynamic>? parts,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WorkOrder(
      id: id ?? this.id,
      faultId: faultId ?? this.faultId,
      fault: fault ?? this.fault,
      description: description ?? this.description,
      status: status ?? this.status,
      technicianId: technicianId ?? this.technicianId,
      technician: technician ?? this.technician,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      parts: parts ?? this.parts,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
