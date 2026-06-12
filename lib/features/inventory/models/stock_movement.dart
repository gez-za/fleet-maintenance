import 'package:equatable/equatable.dart';
import '../../../core/utils/parser_utils.dart';

enum MovementType { ENTREE, SORTIE, AJUSTEMENT }

class StockMovement extends Equatable {
  final String id;
  final String materielId;
  final String? materielDesignation;
  final MovementType type;
  final double quantite;
  final String motif;
  final String? otId;
  final DateTime createdAt;
  final String? userName;

  const StockMovement({
    required this.id,
    required this.materielId,
    this.materielDesignation,
    required this.type,
    required this.quantite,
    required this.motif,
    this.otId,
    required this.createdAt,
    this.userName,
  });

  factory StockMovement.fromJson(Map<String, dynamic> json) {
    return StockMovement(
      id: json['id'] ?? '',
      materielId: json['materiel_id'] ?? '',
      materielDesignation: json['materiel']?['designation'] ?? json['materiel_designation'],
      type: _parseType(json['type']),
      quantite: ParserUtils.parseDouble(json['quantite']) ?? 0.0,
      motif: json['motif'] ?? '',
      otId: json['ot_id'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      userName: json['operateur'] != null 
          ? '${json['operateur']['prenom'] ?? ""} ${json['operateur']['nom'] ?? ""}'.trim()
          : (json['user']?['nom'] ?? json['user_name']),
    );
  }

  static MovementType _parseType(String? type) {
    switch (type) {
      case 'ENTREE': return MovementType.ENTREE;
      case 'SORTIE': return MovementType.SORTIE;
      case 'AJUSTEMENT': return MovementType.AJUSTEMENT;
      default: return MovementType.ENTREE;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'materiel_id': materielId,
      'type': type.name,
      'quantite': quantite,
      'motif': motif,
      'ot_id': otId,
    };
  }

  @override
  List<Object?> get props => [id, materielId, type, quantite, motif, otId, createdAt, userName];
}
