import 'package:flareline_template/models/mvtStockArticle.dart';
import 'agence.dart';

  class Facture {
    final int? idFacture;
    final String reference;
    final DateTime dateFacture;
    final String? description;
    final double? montant;
    final double? montantTva;
    final double? montantTtc;
    final Agence? agence;
    final List<MvtStockArticle> articles;
    final String? referenceBonDeLivraison;
    final String? referenceBonDeCommande;

  Facture({
     this.idFacture,
    required this.reference,
    required this.dateFacture,
    this.description,
    this.montant,
    this.montantTva,
    this.montantTtc,
    this.agence,
    this.articles = const [],
    this.referenceBonDeLivraison,
    this.referenceBonDeCommande,
  });

  // Pour créer un objet Facture à partir d'un JSON
  factory Facture.fromJson(Map<String, dynamic> json) {
    var articlesFromJson = <MvtStockArticle>[];
    if (json['articles'] != null) {
      articlesFromJson = List<MvtStockArticle>.from(
          json['articles'].map((a) => MvtStockArticle.fromJson(a)));
    }

    return Facture(
      idFacture: json['id_facture'],
      reference: json['reference'] ?? '',
      dateFacture: DateTime.parse(json['date_facture']),
      description: json['description'],
      montant: json['montant'] != null ? double.tryParse(json['montant'].toString()) : null,
      montantTva: json['montant_tva'] != null ? double.tryParse(json['montant_tva'].toString()) : null,
      montantTtc: json['montant_ttc'] != null ? double.tryParse(json['montant_ttc'].toString()) : null,
      agence: json['agence'] != null ? Agence.fromJson(json['agence']) : null,
      articles: articlesFromJson,
      referenceBonDeLivraison: json['reference_bon_livraison'],
      referenceBonDeCommande: json['reference_bon_commande'],
    );
  }

  // Pour convertir en JSON si besoin
  Map<String, dynamic> toJson() {
    return {
      'id_facture': idFacture,
      'reference': reference,
      'date_facture': dateFacture.toIso8601String(),
      'description': description,
      'montant': montant,
      'montant_tva': montantTva,
      'montant_ttc': montantTtc,
      'agence': agence?.toJson(),
      'articles': articles.map((a) => a.toJson()).toList(),
      'reference_bon_de_livraison': referenceBonDeLivraison,
      'reference_bon_de_commande': referenceBonDeCommande,
    };
  }
}
