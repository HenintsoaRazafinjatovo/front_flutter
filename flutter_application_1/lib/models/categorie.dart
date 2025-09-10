class Categorie {
  int? idCategorie;
  String nomCategorie;
  String? description;

  Categorie({
    this.idCategorie,
    required this.nomCategorie,
    this.description,
  });

  // Convertir un JSON en objet Categorie
  factory Categorie.fromJson(Map<String, dynamic> json) {
    return Categorie(
      idCategorie: json['id_categorie'],
      nomCategorie: json['nom_categorie'],
      description: json['description'],
    );
  }

  // Convertir un objet Categorie en JSON
  Map<String, dynamic> toJson() {
    return {
      'id_categorie': idCategorie,
      'nom_categorie': nomCategorie,
      'description': description,
    };
  }
}
