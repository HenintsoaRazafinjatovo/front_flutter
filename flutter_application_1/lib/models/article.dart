class Article {
  final int? idArticle;
  final String intitule;
  double seuilMin;
  final String code;
  double? prix; 
  double? stock_actuel;

  Article({
    this.idArticle,
    this.prix,
    this.stock_actuel, // pas required
    required this.intitule,
    required this.seuilMin,
    required this.code,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      idArticle: json['id_article'],
      intitule: json['intitule'],
      seuilMin: double.parse(json['seuil_min'].toString()),
      code: json['code'],
      prix: json['prix'] != null ? double.tryParse(json['prix'].toString()) : null,
      stock_actuel: json['stock_actuel'] != null ? double.tryParse(json['stock_actuel'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_article': idArticle,
      'intitule': intitule,
      'seuil_min': seuilMin,
      'code': code,
      'prix': prix,
    };
  }
}
