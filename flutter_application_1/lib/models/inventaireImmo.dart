import 'inventaire_materiel.dart' show InventaireMateriel;
import 'employe.dart' show Employe;

class InventaireImmo {
  final int id;
  final DateTime date;
  final List<InventaireMateriel> materiels;
  final List<Employe>? employes;

  InventaireImmo({
    required this.id,
    required this.date,
    required this.materiels,
     this.employes,
  });

  factory InventaireImmo.fromJson(Map<String, dynamic> json) {
    return InventaireImmo(
      id: json['id_inventaire'],
      date: DateTime.parse(json['date_inventaire']),
      materiels: (json['materiels'] as List)
          .map((e) => InventaireMateriel.fromJson(e))
          .toList(),
      employes: (json['employes'] as List)
          .map((e) => Employe.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_inventaire': id,
      'date_inventaire': date.toIso8601String(),
      'materiels': materiels,
      'employes': employes, 
    };
  }
  int getNbMateriels() {
    return materiels.length;
  }
}