class Employe {
  final int? idEmploye;
  final String nom;
  final int? idDirection;

  Employe({
     this.idEmploye,
    required this.nom,
    this.idDirection,
  });

  factory Employe.fromJson(Map<String, dynamic> json) {
    return Employe(
      idEmploye: json['id_employe'],
      nom: json['nom'],
      idDirection: json['id_direction'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_employe': idEmploye,
      'nom': nom,
      'id_direction': idDirection,
    };
  }
}