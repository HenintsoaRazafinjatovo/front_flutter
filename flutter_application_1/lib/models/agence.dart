  class Agence {
  final int? idAgence;
  final String codeAgence;

   Agence({
    this.idAgence,
    required this.codeAgence,
  });
  factory Agence.fromJson(Map<String, dynamic> json) {
    return Agence(
      idAgence: json['id_agence'],
      codeAgence: json['code_agence'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id_agence': idAgence,
      'code_agence': codeAgence,
    };
  }
}