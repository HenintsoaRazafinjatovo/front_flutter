import 'inventaire_article.dart' show InventaireArticle;
import 'employe.dart' show Employe;

class Inventaire {
  final int id;
  final DateTime date;
  final List<InventaireArticle> articles;
  final List<Employe> employes;

  Inventaire({
    required this.id,
    required this.date,
    required this.articles,
    required this.employes,
  });

  factory Inventaire.fromJson(Map<String, dynamic> json) {
    return Inventaire(
      id: json['id_inventaire'],
      date: DateTime.parse(json['date_inventaire']),
      articles: (json['articles'] as List)
          .map((e) => InventaireArticle.fromJson(e))
          .toList(),
      employes: (json['employes'] as List)
          .map((e) => Employe.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_inventaire': id,
      'date_inventaire': date.toIso8601String(),
      'articles': articles ?? [], 
      'employes': employes ?? [], 
    };
  }
  int getNbArticles() {
    return articles.length;
  }
}