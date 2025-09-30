import 'inventaire_article.dart';
import 'employe.dart';

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

  // factory Inventaire.fromJson(Map<String, dynamic> json) {
  //   final articlesList = (json['articles'] as List<dynamic>? ?? [])
  //       .map((e) => InventaireArticle.fromJson(Map<String, dynamic>.from(e)))
  //       .toList();

  //   final employesList = (json['employes'] as List<dynamic>? ?? [])
  //       .map((e) => Employe.fromJson(Map<String, dynamic>.from(e)))
  //       .toList();

  //   return Inventaire(
  //     id: json['id_inventaire'],
  //     date: DateTime.parse(json['date_inventaire']),
  //     articles: articlesList,
  //     employes: employesList,
  //   );
  // }
  factory Inventaire.fromJson(Map<String, dynamic> json) {
  final articlesList = (json['articles'] as List<dynamic>? ?? [])
      .map((e) => InventaireArticle.fromJson(e as Map<String, dynamic>))
      .toList();

  final employesList = (json['employes'] as List<dynamic>? ?? [])
      .map((e) => Employe.fromJson(e as Map<String, dynamic>))
      .toList();

  return Inventaire(
    id: json['id_inventaire'],
    date: DateTime.parse(json['date_inventaire']),
    articles: articlesList,
    employes: employesList,
  );
}


  Map<String, dynamic> toJson() {
    return {
      'id_inventaire': id,
      'date_inventaire': date.toIso8601String(),
      'articles': articles.map((e) => e.toJson()).toList(),
      'employes': employes.map((e) => e.toJson()).toList(),
    };
  }

  int getNbArticles() => articles.length;
}
