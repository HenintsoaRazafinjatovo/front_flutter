import 'mvtStockImmo.dart';
import 'salle.dart';
class Decharge {
  final int? idDecharge;
  final String? numeroSalle;
  final String? bureau;
  final Salle? salle;
  final int? idSalle;
  final List<String> responsables; // juste des noms
  final String? direction; // juste une chaîne
  final List<MvtStockImmo> materiels;

  Decharge({
    this.idDecharge,
    this.numeroSalle,
    this.bureau,
    required this.responsables,
    this.direction,
    this.salle,
    this.idSalle,
    required this.materiels,
  });

  factory Decharge.fromJson(Map<String, dynamic> json) {
    return Decharge(
      numeroSalle: json['numero_salle']?.toString(), // int → String
      bureau: json['bureau'] as String?,
      idSalle: json['id_salle'] as int?,
      idDecharge: json['id_decharge'] as int?,
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
      'id_salle': idSalle,
      'materiels': materiels.map((e) => e.toJson()).toList(),
      'salle': salle?.toJson(),
      'id_decharge': idDecharge,
    };
  }
}