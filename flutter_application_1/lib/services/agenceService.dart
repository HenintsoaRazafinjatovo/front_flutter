import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/agence.dart';

class AgenceService {
  final String baseUrl = "http://127.0.0.1:8000/api/agences"; 

  /// Récupérer toutes les agences
  Future<List<Agence>> getAgences() async {
    final url = Uri.parse(baseUrl);

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Agence.fromJson(json)).toList();
      } else {
        throw Exception("Erreur API: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      throw Exception("Erreur lors de l'appel API: $e");
    }
  }

  /// Récupérer une agence par ID
  Future<Agence> getAgenceById(int id) async {
    final url = Uri.parse("$baseUrl/$id");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Agence.fromJson(data);
      } else {
        throw Exception("Erreur API: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      throw Exception("Erreur lors de l'appel API: $e");
    }
  }

  /// Créer une nouvelle agence
  Future<Agence> createAgence(Agence agence) async {
    final url = Uri.parse(baseUrl);

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(agence.toJson()),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return Agence.fromJson(data);
      } else {
        throw Exception("Erreur API: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      throw Exception("Erreur lors de l'appel API: $e");
    }
  }

}