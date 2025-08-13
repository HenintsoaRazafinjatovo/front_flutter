import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/article.dart';

class ArticleService {
  final String baseUrl = 'http://127.0.0.1:8000/api/articles'; 


  Future<List<Article>> getArticles() async {
    final response = await http.get(Uri.parse(baseUrl));
    // print('ETOOOOOOOOO Response status: ${response.statusCode}');
    // print('ETOOOOOOOOO articles: ${response.body}');

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Article.fromJson(json)).toList();
    } else {
      throw Exception('Erreur lors du chargement des articles');
    }
  }

 
  Future<bool> addArticle(Article article) async {
  final response = await http.post(
    Uri.parse(baseUrl),
    headers: {'Content-Type': 'application/json'},
    body: json.encode(article.toJson()),
  );

  return response.statusCode == 201 || response.statusCode == 200;
}

  
  Future<bool> updateArticle(Article article) async {
    final url = '$baseUrl/${article.idArticle}';
    final response = await http.put(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(article.toJson()),
    );

    return response.statusCode == 200;
  }

  Future<bool> deleteArticle(int idArticle) async {
    final url = '$baseUrl/$idArticle';
    final response = await http.delete(Uri.parse(url));

    return response.statusCode == 200;
  }
}
