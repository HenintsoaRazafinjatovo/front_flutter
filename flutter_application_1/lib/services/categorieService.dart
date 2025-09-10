import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/categorie.dart';

class CategorieService {
 final String baseUrl = 'http://127.0.0.1:8000/api/categories'; 

  // Récupérer toutes les catégories
  Future<List<Categorie>> getCategories() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((json) => Categorie.fromJson(json)).toList();
    } else {
      throw Exception('Impossible de récupérer les catégories');
    }
  }

  // Récupérer une catégorie par ID
  Future<Categorie> getCategorieById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/categorie/$id'));
    if (response.statusCode == 200) {
      return Categorie.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Catégorie non trouvée');
    }
  }

  // Créer une nouvelle catégorie
  Future<Categorie> createCategorie(Categorie categorie) async {
    final response = await http.post(
      Uri.parse('$baseUrl/categorie'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(categorie.toJson()),
    );
    if (response.statusCode == 201) {
      return Categorie.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Impossible de créer la catégorie');
    }
  }

  // Mettre à jour une catégorie
  Future<Categorie> updateCategorie(Categorie categorie) async {
    final response = await http.put(
      Uri.parse('$baseUrl/categorie/${categorie.idCategorie}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(categorie.toJson()),
    );
    if (response.statusCode == 200) {
      return Categorie.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Impossible de mettre à jour la catégorie');
    }
  }

  // Supprimer une catégorie
  Future<void> deleteCategorie(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/categorie/$id'));
    if (response.statusCode != 200) {
      throw Exception('Impossible de supprimer la catégorie');
    }
  }
}
