class Direction {
  final int? idDirection;
  final String nom;
  final String description;

  Direction({
    this.idDirection,
    required this.nom,
    required this.description,
  });

  factory Direction.fromJson(Map<String, dynamic> json) {
    return Direction(
      idDirection: json['id_direction'] as int?,
      nom: json['nom'] as String,
      description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_direction': idDirection,
      'nom': nom,
      'description': description,
    };
  }
}
