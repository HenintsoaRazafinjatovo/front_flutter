class Attribution {
  final int? idAttribution;
  final DateTime dateAttribution;
  final String description;
  final String direction; // Nom de la direction au lieu de l'ID
  final int idMvt;

  Attribution({
    this.idAttribution,
    required this.dateAttribution,
    required this.description,
    required this.direction,
    required this.idMvt,
  });

  factory Attribution.fromJson(Map<String, dynamic> json) {
    return Attribution(
      idAttribution: json['id_attribution'] as int?,
      dateAttribution: DateTime.parse(json['date_attribution']),
      description: json['description'] ?? '',
      direction: json['direction'] ?? '', // nom_direction attendu depuis l'API
      idMvt: json['id_mvt'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_attribution': idAttribution,
      'date_attribution': dateAttribution.toIso8601String(),
      'description': description,
      'direction': direction,
      'id_mvt': idMvt,
    };
  }
}
