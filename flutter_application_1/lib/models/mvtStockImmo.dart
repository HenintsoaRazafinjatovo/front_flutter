import 'materiel.dart';

class MvtStockImmo {
  final int? idMateriel;
  final double quantite; // quantité du mouvement
  final Materiel? materiel;
  final double? totalMateriel;
  final String? typeMouvement;
  final DateTime? dateMouvement;
  final String? etat;
  final String? designation;
 

  MvtStockImmo({
    this.idMateriel,
    required this.quantite,
    this.materiel,
    this.totalMateriel,
     this.typeMouvement,
      this.dateMouvement,
    this.etat,
    this.designation,
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
      etat:json['etat']?.toString() ?? 'BON',
      designation: json['designation']?.toString() ?? '',
      materiel: json['materiel'] != null
          ? Materiel(
              idMateriel: json['id_materiel'] ?? 0,
              designation: json['materiel'],
              dateAcquisition:json['date_acquisition'] != null
                  ? DateTime.parse(json['date_acquisition'])
                  : null,
              code: '',

            )
          : null,
      totalMateriel: totalMateriel,
      dateMouvement: json['date_mvt'] != null
          ? DateTime.parse(json['date_mvt'])
          : null,
       typeMouvement: json['type'] ?? 'ENTREE',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_materiel': idMateriel,
      'quantite': quantite,
      'code': materiel?.code,
      // 'type_mouvement': typeMouvement,
    };
  }
}
