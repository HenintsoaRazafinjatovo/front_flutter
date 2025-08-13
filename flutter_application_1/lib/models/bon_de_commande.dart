class BonDeCommande {
  final int? idBonDeCommande;
  final DateTime dateBonDeCommande;
  final String description;
  final String status_commande;

  BonDeCommande({
    this.idBonDeCommande,
    required this.dateBonDeCommande,
    required this.description,
    required this.status_commande,
  });
  factory BonDeCommande.fromJson(Map<String, dynamic> json) {
    return BonDeCommande(
      idBonDeCommande: json['id_bon_de_commande'],
      dateBonDeCommande: DateTime.parse(json['date_bon_de_commande']),
      description: json['description'],
      status_commande: json['status_commande'],
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'id_bon_de_commande': idBonDeCommande,
      'date_bon_de_commande': dateBonDeCommande.toIso8601String(),
      'description': description,
      'status_commande': status_commande,
    };
  }
}

