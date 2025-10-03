import 'categorie.dart';

class Article {
  final int? idArticle;
  final String intitule;
  double seuilMin;
  final String code;
  double? prix; 
  double? stockActuel;  
  final Categorie? categorie;

  Article({
    this.idArticle,
    this.prix,
    this.stockActuel,
    required this.intitule,
    required this.seuilMin,
    required this.code,
    this.categorie,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      idArticle: json['id_article'],
      intitule: json['intitule'],
      seuilMin: double.parse(json['seuil_min'].toString()),
      code: json['code'],
      prix: json['prix'] != null ? double.tryParse(json['prix'].toString()) : null,
      stockActuel: json['stock_actuel'] != null ? double.tryParse(json['stock_actuel'].toString()) : null,
      categorie: json['categorie'] != null ? Categorie.fromJson(json['categorie']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_article': idArticle,
      'intitule': intitule,
      'seuil_min': seuilMin,
      'code': code,
      'prix': prix,
      'stock_actuel': stockActuel,
      'categorie': categorie?.toJson(),
    };
  }
  Map<String, dynamic> toApiJson() {
  return {
    'intitule': intitule,
    'stock_actuel': stockActuel,
    'seuil_min': seuilMin,
    'code': code,
    'id_categorie': categorie?.idCategorie, // on envoie juste l'id
    'prix': prix, // pour l’historique
  };
}
}
