class TypeEvenement {
  final int? idTypeEvenement;
  final String description;

  TypeEvenement({this.idTypeEvenement, required this.description});
  factory TypeEvenement.fromJson(Map<String, dynamic> json) {
    return TypeEvenement(
      idTypeEvenement: json['id_type_evenement'],
      description: json['description'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id_type_evenement': idTypeEvenement,
      'description': description,
    };
  }
}