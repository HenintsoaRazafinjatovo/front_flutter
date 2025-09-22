import 'mvtStockImmo.dart';
class Decharge {
  final String? numeroSalle;
  final String? bureau;
  final List<String> responsables; // juste des noms
  final String? direction; // juste une chaîne
  final List<MvtStockImmo> materiels;

  Decharge({
    this.numeroSalle,
    this.bureau,
    required this.responsables,
    this.direction,
    required this.materiels,
  });

  factory Decharge.fromJson(Map<String, dynamic> json) {
    return Decharge(
      numeroSalle: json['numero_salle']?.toString(), // int → String
      bureau: json['bureau'] as String?,
      responsables: (json['responsables'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      direction: json['direction']?.toString(),
      materiels: (json['materiels'] as List<dynamic>?)
              ?.map((e) => MvtStockImmo.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'numero_salle': numeroSalle,
      'bureau': bureau,
      'responsables': responsables,
      'direction': direction,
      'materiels': materiels.map((e) => e.toJson()).toList(),
    };
  }
}