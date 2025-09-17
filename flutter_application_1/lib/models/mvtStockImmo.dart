import 'materiel.dart';

class MvtStockImmo {
  final int? idMateriel;
  final double quantite; // quantité du mouvement
  final Materiel? materiel;
  final double? totalMateriel;
  // final String typeMouvement; // "ENTREE" ou "SORTIE"

  MvtStockImmo({
    this.idMateriel,
    required this.quantite,
    this.materiel,
    this.totalMateriel,
    // required this.typeMouvement,
  });

  factory MvtStockImmo.fromJson(Map<String, dynamic> json) {
    double prix = json['prix_unitaire'] != null
        ? double.tryParse(json['prix_unitaire'].toString()) ?? 0.0
        : 0.0;
    
    double quantite = json['quantite'] != null
        ? double.tryParse(json['quantite'].toString()) ?? 0.0
        : 0.0;

    double totalMateriel = json['total_materiel'] != null
        ? double.tryParse(json['total_materiel'].toString()) ?? 0.0
        : quantite * prix;

    return MvtStockImmo(
      idMateriel: json['id_materiel'],
      quantite: quantite,
      materiel: json['intitule'] != null
          ? Materiel(
              idMateriel: json['id_materiel'] ?? 0,
              designation: json['intitule'],
              dateAcquisition:json['date_acquisition'] != null
                  ? DateTime.parse(json['date_acquisition'])
                  : null,
              code: '',
              reference: '',
            )
          : null,
      totalMateriel: totalMateriel,
      // typeMouvement: json['type_mouvement'] ?? 'ENTREE',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_materiel': idMateriel,
      'quantite': quantite,
      'code': materiel?.code,
    'reference': materiel?.reference,
      // 'type_mouvement': typeMouvement,
    };
  }
}
      // 'type_mouvement': typeMouvement,
 