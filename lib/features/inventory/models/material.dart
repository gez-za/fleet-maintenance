import 'package:equatable/equatable.dart';

class MaterialModel extends Equatable {
  final String id;
  final String reference;
  final String designation;
  final String categorie;
  final double quantiteStock;
  final double seuilAlerte;

  const MaterialModel({
    required this.id,
    required this.reference,
    required this.designation,
    required this.categorie,
    required this.quantiteStock,
    required this.seuilAlerte,
  });

  bool get isLowStock => quantiteStock <= seuilAlerte;

  factory MaterialModel.fromJson(Map<String, dynamic> json) {
    return MaterialModel(
      id: json['id'] ?? '',
      reference: json['reference'] ?? '',
      designation: json['designation'] ?? '',
      categorie: json['categorie'] ?? '',
      quantiteStock: (json['quantite_stock'] ?? 0).toDouble(),
      seuilAlerte: (json['seuil_alerte'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reference': reference,
      'designation': designation,
      'categorie': categorie,
      'quantite_stock': quantiteStock,
      'seuil_alerte': seuilAlerte,
    };
  }

  @override
  List<Object?> get props => [id, reference, designation, categorie, quantiteStock, seuilAlerte];
}
