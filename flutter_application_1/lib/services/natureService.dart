// nature_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/nature.dart';

class NatureService {
  final String baseUrl='http://127.0.0.1:8000/api/natures';

  // Récupérer toutes les natures
  Future<List<Nature>> getAllNatures() async {
    final url = Uri.parse(baseUrl);
    final response = await http.get(url);

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Nature.fromJson(json)).toList();
    } else {
      throw Exception('Erreur lors de la récupération des natures : ${response.statusCode}');
    }
  }

  // Récupérer une nature par ID
  Future<Nature> getNatureById(int id) async {
    final url = Uri.parse('$baseUrl/api/natures/$id');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return Nature.fromJson(json.decode(response.body));
    } else {
      throw Exception('Erreur lors de la récupération de la nature : ${response.statusCode}');
    }
  }

  // Créer une nouvelle nature
  Future<Nature> createNature(Nature nature) async {
    final url = Uri.parse('$baseUrl/api/natures');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(nature.toJson()),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return Nature.fromJson(json.decode(response.body));
    } else {
      throw Exception('Erreur lors de la création de la nature : ${response.statusCode}');
    }
  }

  // Mettre à jour une nature
  Future<Nature> updateNature(Nature nature) async {
    if (nature.idNature == null) {
      throw Exception('ID de la nature requis pour la mise à jour');
    }
    final url = Uri.parse('$baseUrl/api/natures/${nature.idNature}');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(nature.toJson()),
    );

    if (response.statusCode == 200) {
      return Nature.fromJson(json.decode(response.body));
    } else {
      throw Exception('Erreur lors de la mise à jour de la nature : ${response.statusCode}');
    }
  }

  // Supprimer une nature
  Future<void> deleteNature(int id) async {
    final url = Uri.parse('$baseUrl/api/natures/$id');
    final response = await http.delete(url);

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Erreur lors de la suppression de la nature : ${response.statusCode}');
    }
  }
}
