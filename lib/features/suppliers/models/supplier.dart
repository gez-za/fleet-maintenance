import 'package:equatable/equatable.dart';

class Supplier extends Equatable {
  final String id;
  final String nom;
  final String contact;
  final String? telephone;
  final String? email;
  final String? adresse;

  const Supplier({
    required this.id,
    required this.nom,
    required this.contact,
    this.telephone,
    this.email,
    this.adresse,
  });

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      id: json['id'] ?? '',
      nom: json['nom'] ?? '',
      contact: json['contact'] ?? '',
      telephone: json['telephone'],
      email: json['email'],
      adresse: json['adresse'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nom': nom,
      'contact': contact,
      'telephone': telephone,
      'email': email,
      'adresse': adresse,
    };
  }

  @override
  List<Object?> get props => [id, nom, contact, telephone, email, adresse];
}
