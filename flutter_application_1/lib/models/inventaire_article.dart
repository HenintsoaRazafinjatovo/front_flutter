import 'article.dart';

// class InventaireArticle {
//   final Article article;
//   final double stockTheorique;
//   final double stockPhysique;
//   final double ecart;

//   InventaireArticle({
//     required this.article,
//     required this.stockTheorique,
//     required this.stockPhysique,
//     required this.ecart,
//   });

//   factory InventaireArticle.fromJson(Map<String, dynamic> json) {
//     return InventaireArticle(
//       article: Article.fromJson(Map<String, dynamic>.from(json['article'])),
//       stockTheorique: (json['stock_theorique'] as num).toDouble(),
//       stockPhysique: (json['stock_physique'] as num).toDouble(),
//       ecart: (json['ecart'] as num).toDouble(),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'article': article.toJson(),
//       'stock_theorique': stockTheorique,
//       'stock_physique': stockPhysique,
//       'ecart': ecart,
//     };
//   }
// }
class InventaireArticle {
  final Article article;
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
      stockTheorique: json['stock_theorique'] ?? 0,
      stockPhysique: json['stock_physique'] ?? 0,
      ecart: json['ecart'] ?? 0,
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


