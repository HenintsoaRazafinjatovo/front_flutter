import 'type_evenement.dart';
import 'package:flutter/material.dart';

class Evenement {
  final int? idEvenement;
  final DateTime dateEvenement;
  final String? description;
  final String? titre;
  final TypeEvenement typeEvenement;

  // Nouveau champ pour les détails (inventaire ou livraison)
  final Map<String, dynamic>? details;

  Evenement({
    this.idEvenement,
    required this.dateEvenement,
    this.description,
    this.titre,
    required this.typeEvenement,
    this.details,
  });

  // Méthode corrigée pour récupérer le type depuis un string
  static TypeEvenement getTypeFromString(String typeStr) {
    try {
      return TypeEvenement.values.firstWhere(
        (t) => t.description.toLowerCase() == typeStr.toLowerCase(),
      );
    } catch (_) {
      // Si le type n'est pas trouvé, créer un type générique
      return TypeEvenement(
        description: typeStr, 
        color: Colors.grey, 
        emoji: '📌'
      );
    }
  }

  // Convertir JSON API en objet Evenement
  factory Evenement.fromJson(Map<String, dynamic> json) {
    return Evenement(
      idEvenement: json['id_evenement'],
      dateEvenement: DateTime.parse(json['date_evenement']),
      description: json['description'],
      titre: json['titre'],
      typeEvenement: TypeEvenement.fromJson(json['type'] is Map 
           ? json['type']
           : {'description': json['type']}), // au cas où type est juste un string
      details: json['details'], // peut contenir {"inventaire": {...}} ou {"livraison": {...}}
    );
  }

  // Convertir objet Evenement en JSON
  Map<String, dynamic> toJson() {
    return {
      'id_evenement': idEvenement,
      'date_evenement': dateEvenement.toIso8601String(),
      'description': description,
      'titre': titre,
      'id_type_evenement': typeEvenement.idTypeEvenement,
      'details': details,
    };
  }

  // Helper pour savoir si l'événement est une livraison
  bool get isLivraison => details != null && details!.containsKey('livraison');

  // Helper pour savoir si l'événement est un inventaire
  bool get isInventaire => details != null && details!.containsKey('inventaire');
}