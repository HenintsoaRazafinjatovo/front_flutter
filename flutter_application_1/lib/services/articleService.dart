import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/article.dart';
import '../utils/paginatedResponse.dart';

class ArticleService {
  final String baseUrl = 'http://127.0.0.1:8000/api/articles'; 


  Future<PaginatedResponse<Article>> getArticles({int page = 1, int perPage = 10}) async {
    final response = await http.get(Uri.parse('$baseUrl?page=$page&per_page=$perPage'));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      // return data.map((json) => Article.fromJson(json)).toList();
      return PaginatedResponse.fromJson(
        jsonResponse,
        (item) => Article.fromJson(item),
      );
      
    } else {
      throw Exception('Erreur lors du chargement des articles');
    }
  }

  Future<List<Article>> getAllArticles() async {
    final response = await http.get(Uri.parse('$baseUrl/all'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Article.fromJson(json)).toList();
    } else {
      throw Exception('Erreur lors du chargement des articles');
    }
  }

 
 Future<bool> addArticle(Article article) async {
  final response = await http.post(
    Uri.parse(baseUrl),
     headers: {
      'Content-Type': 'application/json',  
      'Accept': 'application/json',
      },
    body: json.encode(article.toApiJson()),
  );
  return response.statusCode == 201 || response.statusCode == 200;
}

  
  Future<bool> updateArticle(Article article) async {
    final url = '$baseUrl/${article.idArticle}';
    final response = await http.put(
      Uri.parse(url),
      headers: {
      'Content-Type': 'application/json',  
      'Accept': 'application/json',
      },
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
