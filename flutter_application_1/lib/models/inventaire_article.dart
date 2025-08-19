import 'article.dart' show Article;

class InventaireArticle {
  final Article article; // Suppose que tu as déjà une classe Article
  final double stockTheorique;
  final double stockPhysique;
  final double ecart;

  InventaireArticle({
    required this.article,
    required this.stockTheorique,
    required this.stockPhysique,
    required this.ecart,
  });

  factory InventaireArticle.fromJson(Map<String, dynamic> json) {
    return InventaireArticle(
      article: Article.fromJson(json['article']),
      stockTheorique: (json['stock_theorique'] as num).toDouble(),
      stockPhysique: (json['stock_physique'] as num).toDouble(),
      ecart: (json['ecart'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'article': article.toJson(),
      'stock_theorique': stockTheorique,
      'stock_physique': stockPhysique,
      'ecart': ecart,
    };
  }
}
