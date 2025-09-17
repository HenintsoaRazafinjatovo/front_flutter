import 'package:flutter/material.dart';

class TypeEvenement {
  final int? idTypeEvenement;
  final String description;
  final Color? color;
  final String? emoji;
     
  TypeEvenement({
    this.idTypeEvenement, 
    required this.description, 
    this.color, 
    this.emoji
  });
     
  factory TypeEvenement.fromJson(Map<String, dynamic> json) {
    final description = json['description'] ?? 'Sans description';
    
    // D'abord, essayer de trouver un type prédéfini correspondant
    final predefinedType = _findPredefinedType(description);
    if (predefinedType != null) {
      return TypeEvenement(
        idTypeEvenement: json['id_type_evenement'],
        description: description,
        color: predefinedType.color,
        emoji: predefinedType.emoji,
      );
    }
    
    // Sinon, parser depuis l'API
    Color? parsedColor;
    if (json['color'] != null) {
      try {
        if (json['color'] is int) {
          parsedColor = Color(json['color']);
        } else if (json['color'] is String) {
          final hex = json['color'].replaceAll('#', '');
          parsedColor = Color(int.parse(hex, radix: 16) + 0xFF000000);
        }
      } catch (_) {
        parsedColor = Colors.grey; // Couleur par défaut
      }
    } else {
      parsedColor = Colors.grey; // Couleur par défaut si null
    }

    return TypeEvenement(
      idTypeEvenement: json['id_type_evenement'],
      description: description,
      color: parsedColor,
      emoji: json['emoji'] ?? '📌',
    );
  }
  
  // Méthode helper pour trouver un type prédéfini
  static TypeEvenement? _findPredefinedType(String description) {
    try {
      return values.firstWhere(
        (t) => t.description.toLowerCase() == description.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id_type_evenement': idTypeEvenement,
      'description': description,
      'color': color?.value,
      'emoji': emoji,
    };
  }

  static final List<TypeEvenement> values = [
    TypeEvenement(idTypeEvenement: 1, description: "Livraison", emoji: "🚚", color: Color(0xFFC90F31)),
    TypeEvenement(idTypeEvenement: 2,description: "Inventaire", emoji: "📦", color: Color(0xFFF9B70D)),
    TypeEvenement(idTypeEvenement: 3,description: "Formation", emoji: "🎓", color: Color(0xFF374151)),
    TypeEvenement(idTypeEvenement: 4,description: "Maintenance", emoji: "🔧", color: Color(0xFFC90F31)),
  ];
}