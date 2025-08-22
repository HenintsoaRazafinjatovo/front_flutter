import 'direction.dart';

class Employe {
  final int? idEmploye;
  final String nom;
  final Direction? direction;

  Employe({
    this.idEmploye,
    required this.nom,
    this.direction,
  });

  factory Employe.fromJson(Map<String, dynamic> json) {
    return Employe(
      idEmploye: json['id_employe'],
      nom: json['nom'],
      direction: json['direction'] != null
          ? Direction.fromJson(json['direction'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_employe': idEmploye,
      'nom': nom,
      'direction': direction?.toJson(),
    };
  }
}