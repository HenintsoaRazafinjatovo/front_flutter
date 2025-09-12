import 'type_evenement.dart';
class Evenement {
  final int? idEvenement;
  final DateTime dateEvenement;
  final String? description;
  final String? titre;
  final TypeEvenement typeEvenement;

  Evenement({
    this.idEvenement,
    required this.dateEvenement,
    this.description,
    this.titre,
    required this.typeEvenement,
  });

  // Pour convertir un JSON en objet Evenement
  factory Evenement.fromJson(Map<String, dynamic> json) {
    return Evenement(
      idEvenement: json['id_evenement'],
      dateEvenement: DateTime.parse(json['date_evenement']),
      description: json['description'],
      titre: json['titre'],
      typeEvenement: TypeEvenement.fromJson(json['type_evenement']),
    );
  }

  // Pour convertir un objet Evenement en JSON
  Map<String, dynamic> toJson() {
    return {
      'id_evenement': idEvenement,
      'date_evenement': dateEvenement.toIso8601String(),
      'description': description,
      'titre': titre,
      'type_evenement': typeEvenement.toJson(),
    };
  }
}
