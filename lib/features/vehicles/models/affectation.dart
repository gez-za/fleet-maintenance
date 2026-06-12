class AffectationChauffeur {
  final String id;
  final String chauffeurId;
  final String nomComplet;
  final String? numeroPermis;
  final String? categoriePermis;
  final DateTime dateDebut;
  final DateTime? dateFin;
  final bool actif;

  const AffectationChauffeur({
    required this.id,
    required this.chauffeurId,
    required this.nomComplet,
    this.numeroPermis,
    this.categoriePermis,
    required this.dateDebut,
    this.dateFin,
    this.actif = true,
  });

  factory AffectationChauffeur.fromJson(Map<String, dynamic> json) {
    return AffectationChauffeur(
      id: json['id'].toString(),
      chauffeurId: json['chauffeur_id']?.toString() ?? '',
      nomComplet: json['chauffeur_nom_complet'] ?? 
                 (json['nom_complet'] ?? 
                 '${json['chauffeur_nom'] ?? ''} ${json['chauffeur_prenom'] ?? ''}'.trim()),
      numeroPermis: json['numero_permis'],
      categoriePermis: json['categorie_permis'],
      dateDebut: json['date_debut'] != null 
          ? DateTime.parse(json['date_debut']) 
          : DateTime.now(),
      dateFin: json['date_fin'] != null ? DateTime.parse(json['date_fin']) : null,
      actif: json['actif'] ?? (json['date_fin'] == null),
    );
  }
}
