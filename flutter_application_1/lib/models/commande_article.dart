
import 'article.dart';

class CommandeArticle {
  final int? idArticle;
  final double quantite; // Changé de int à double pour gérer les décimales
  final Article? article;
  final double totalArticle;

  CommandeArticle({
    this.idArticle,
    required this.quantite,
    this.article,
    required this.totalArticle,
  });

  factory CommandeArticle.fromJson(Map<String, dynamic> json) {
    double prix = json['prix_unitaire'] != null
        ? double.tryParse(json['prix_unitaire'].toString()) ?? 0.0
        : 0.0;
    
    // Correction: Parse quantite comme double au lieu de int
    double quantite = json['quantite'] != null
        ? double.tryParse(json['quantite'].toString()) ?? 0.0
        : 0.0;

    // Utiliser total_article du JSON s'il existe, sinon calculer
    double totalArticle = json['total_article'] != null
        ? double.tryParse(json['total_article'].toString()) ?? 0.0
        : quantite * prix;

    return CommandeArticle(
      idArticle: json['id_article'],
      quantite: quantite,
      article: json['intitule'] != null
          ? Article(
              idArticle: json['id_article'] ?? 0,
              intitule: json['intitule'],
              stockActuel: json['stock_actuel'] != null
                  ? double.tryParse(json['stock_actuel'].toString()) ?? 0.0
                  : 0.0,
              seuilMin: 0,
              code: '',
              prix: prix,
            )
          : null,
      totalArticle: totalArticle,
    );
  }

  get prixUnitaire => null;

  Map<String, dynamic> toJson() {
    return {
      'id_article': idArticle,
      'quantite': quantite,
      'prix_unitaire': article?.prix,
      'total_article': totalArticle,
      'intitule': article?.intitule,
    };
  }
}