import 'commande_article.dart';
import 'agence.dart';

class BonDeCommande {
  final int? idBonDeCommande;
  final DateTime? dateBonDeCommande;
  final Agence? agence;
  final int? nbArticle;
  final double? total;
  final List<CommandeArticle>? articles;
  final String? description;
  final String? reference;
  String? status_commande;
  bool? bon_de_sortie;

  BonDeCommande({
    this.idBonDeCommande,
     this.dateBonDeCommande,
    this.agence,
    this.nbArticle,
    this.total,
    this.articles,
    this.bon_de_sortie,
   this.description,
    this.status_commande,
    this.reference,
  });

  factory BonDeCommande.fromJson(Map<String, dynamic> json) {
    var articlesJson = json['articles'] as List<dynamic>? ?? [];
    List<CommandeArticle> articles = articlesJson
        .map((e) => CommandeArticle.fromJson(e))
        .toList();

    return BonDeCommande(
      idBonDeCommande: json['id_bon_de_commande'],
      dateBonDeCommande: DateTime.parse(json['date_bon_de_commande']),
      reference: json['reference'] ?? '',
      agence: json['agence'] != null ? Agence.fromJson(json['agence']) : null,
      nbArticle: json['nb_article'] ?? 0,
      total: (json['total'] != null)
          ? double.tryParse(json['total'].toString()) ?? 0
          : 0,
      articles: articles,
      description: json['description'] ?? '',
      status_commande: json['status_commande'] ?? '',
      bon_de_sortie: json['bon_de_sortie'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_bon_de_commande': idBonDeCommande,
      'date_bon_de_commande': dateBonDeCommande?.toIso8601String(),
      'agence': agence?.toJson(),
      'nb_article': nbArticle,
      'total': total,
      'articles': articles?.map((e) => e.toJson()).toList() ?? [],
      'description': description,
      'status_commande': status_commande,
      'bon_de_sortie': bon_de_sortie,
    };
  }
}
