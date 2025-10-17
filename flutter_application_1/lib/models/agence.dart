  class Agence {
  final int? idAgence;
  final String codeAgence;
  final String? libelle;

   Agence({
    this.idAgence,
    required this.codeAgence,
    this.libelle,
  });
  factory Agence.fromJson(Map<String, dynamic> json) {
    return Agence(
      idAgence: json['id_agence'],
      codeAgence: json['ute_vcode'],
      libelle: json['libelle'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id_agence': idAgence,
      'code_agence': codeAgence,
      'libelle': libelle,
    };
  }
}