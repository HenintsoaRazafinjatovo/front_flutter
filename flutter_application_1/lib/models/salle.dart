class Salle {
  final int idSalle;
  final String bureau;
  final int  numero;

  Salle({required this.idSalle, required this.bureau, required this.numero});

  factory Salle.fromJson(Map<String, dynamic> json) {
    return Salle(
      idSalle: json['id_salle'],
      bureau: json['bureau'],
      numero: json['numero'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'idSalle': idSalle,
      'bureau': bureau,
      'numero': numero,
    };
  }
}