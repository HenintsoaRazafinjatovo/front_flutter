import 'materiel.dart' show Materiel;

class InventaireMateriel {
  final Materiel materiel; // Suppose que tu as déjà une classe Materiel
  final double stockTheorique;
  final double stockPhysique;
  final double ecart;

  InventaireMateriel({
    required this.materiel,
    required this.stockTheorique,
    required this.stockPhysique,
    required this.ecart,
  });

  factory InventaireMateriel.fromJson(Map<String, dynamic> json) {
    return InventaireMateriel(
      materiel: Materiel.fromJson(json['materiel']),
      stockTheorique: (json['stock_theorique'] as num).toDouble(),
      stockPhysique: (json['stock_physique'] as num).toDouble(),
      ecart: (json['ecart'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'materiel': materiel.toJson(),
      'stock_theorique': stockTheorique,
      'stock_physique': stockPhysique,
      'ecart': ecart,
    };
  }
}
