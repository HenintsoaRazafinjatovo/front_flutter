import 'package:flutter/material.dart';

class TypeEvenement {
  final int? idTypeEvenement;
  final String description;
  final Color? color;
  final String? emoji;

  TypeEvenement({this.idTypeEvenement, required this.description, this.color, this.emoji});
  factory TypeEvenement.fromJson(Map<String, dynamic> json) {
    return TypeEvenement(
      idTypeEvenement: json['id_type_evenement'],
      description: json['description'],
      color: json['color'] != null ? Color(json['color']) : null,
      emoji: json['emoji'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id_type_evenement': idTypeEvenement,
      'description': description,
    };
  }
   static final List<TypeEvenement> values = [
    TypeEvenement(description: "Livraison", emoji: "🚚", color: Color(0xFFC90F31)),
    TypeEvenement(description: "Inventaire", emoji: "📦", color: Color(0xFFF9B70D)),
    TypeEvenement(description: "Formation", emoji: "🎓", color: Color(0xFF374151)),
    TypeEvenement(description: "Maintenance", emoji: "🔧", color: Color(0xFFC90F31)),
    // Add other types as needed
  ];
  
}