import 'package:equatable/equatable.dart';

class CatalogueItem extends Equatable {
  final String id;
  final String fournisseurId;
  final String designation;
  final double prixHT;
  final String delaiLivraison;

  const CatalogueItem({
    required this.id,
    required this.fournisseurId,
    required this.designation,
    required this.prixHT,
    required this.delaiLivraison,
  });

  factory CatalogueItem.fromJson(Map<String, dynamic> json) {
    return CatalogueItem(
      id: json['id'] ?? '',
      fournisseurId: json['fournisseur_id'] ?? '',
      designation: json['designation'] ?? '',
      prixHT: (json['prix_ht'] ?? 0).toDouble(),
      delaiLivraison: json['delai_livraison'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'designation': designation,
      'prix_ht': prixHT,
      'delai_livraison': delaiLivraison,
    };
  }

  @override
  List<Object?> get props => [id, fournisseurId, designation, prixHT, delaiLivraison];
}
