import 'article.dart';

class MvtStockArticle {
  final int? idArticle;
  final double quantite; // quantité du mouvement
  final Article? article;
  final double? totalArticle;
  // final String typeMouvement; // "ENTREE" ou "SORTIE"

  MvtStockArticle({
    this.idArticle,
    required this.quantite,
    this.article,
    this.totalArticle,
    // required this.typeMouvement,
  });

  factory MvtStockArticle.fromJson(Map<String, dynamic> json) {
    double prix = json['prix_unitaire'] != null
        ? double.tryParse(json['prix_unitaire'].toString()) ?? 0.0
        : 0.0;
    
    double quantite = json['quantite'] != null
        ? double.tryParse(json['quantite'].toString()) ?? 0.0
        : 0.0;

    double totalArticle = json['total_article'] != null
        ? double.tryParse(json['total_article'].toString()) ?? 0.0
        : quantite * prix;

    return MvtStockArticle(
      idArticle: json['id_article'],
      quantite: quantite,
      article: json['intitule'] != null
          ? Article(
              idArticle: json['id_article'] ?? 0,
              intitule: json['intitule'],
              seuilMin: 0,
              code: '',
              prix: prix,
            )
          : null,
      totalArticle: totalArticle,
      // typeMouvement: json['type_mouvement'] ?? 'ENTREE',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_article': idArticle,
      'quantite': quantite,
      'prix_unitaire': article?.prix,
      'total_article': totalArticle,
      'intitule': article?.intitule,
      // 'type_mouvement': typeMouvement,
    };
  }
}
