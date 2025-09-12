import 'mvtStockArticle.dart';
import 'agence.dart';

class BonDeLivraison {
  final int? idBonDeLivraison;
  final DateTime dateBonDeLivraison;
  final String? reference;
  final Agence? agence;
  final int? nbArticle;
  final double? total;
  final List<MvtStockArticle>? articles;
  final String description;

  BonDeLivraison({
    this.idBonDeLivraison,
    required this.dateBonDeLivraison,
    this.agence,
    this.nbArticle,
    this.total,
    this.articles,
    this.reference,
    required this.description,
  });

  factory BonDeLivraison.fromJson(Map<String, dynamic> json) {
    var articlesJson = json['articles'] as List<dynamic>? ?? [];
    List<MvtStockArticle> articles = articlesJson
        .map((e) => MvtStockArticle.fromJson(e))
        .toList();

    return BonDeLivraison(
      idBonDeLivraison: json['id_bon_de_livraison'],
      dateBonDeLivraison: DateTime.parse(json['date_bon_de_livraison']),
      agence: json['agence'] != null ? Agence.fromJson(json['agence']) : null,
      nbArticle: json['nb_article'] ?? 0,
      total: (json['total'] != null)
          ? double.tryParse(json['total'].toString()) ?? 0
          : 0,
      articles: articles,
      description: json['description'] ?? '',
      reference: json['reference'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_bon_de_livraison': idBonDeLivraison,
      'date_bon_de_livraison': dateBonDeLivraison.toIso8601String(),
      'agence': agence?.toJson(),
      'nb_article': nbArticle,
      'total': total,
      'articles': articles?.map((e) => e.toJson()).toList() ?? [],
      'description': description,
    };
  }
}
