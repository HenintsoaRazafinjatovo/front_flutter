import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/mvt_stock.dart'; // ton model MvtStock

class MvtStockService {
  final String baseUrl = "http://127.0.0.1:8000/api/mvt-stocks"; // 
  

  /// Crée un mouvement avec articles
  Future<MvtStock?> createMouvementWithArticles(
    int type,
    List<Map<String, dynamic>> articles,
  ) async {
    final url = Uri.parse('$baseUrl/create');
  
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'type': type,
          'articles': articles,
          'date_mvt': DateTime.now().toIso8601String(),
        }),
      );
      print("Réponse du serveur: ${response.statusCode  }");
      print("Réponse du serveur: ${response.statusCode}");
      print("Corps de la réponse: ${response.body}");

      if (response.statusCode == 201) {
        
        final data = jsonDecode(response.body);
        return MvtStock.fromJson(data['data']);
      } else {
        if (response.body.isNotEmpty) {
          final errorData = jsonDecode(response.body);
          print("Détails de l'erreur: $errorData");
        }
        return null;
      }
    } catch (e) {
      print("Erreur réseau: $e");
      return null;
    }
  }
  Future<List<MvtStock>> getMouvementsDetails() async {
    final url = Uri.parse('$baseUrl/details'); // remplace par la route de ton controller

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);

      // Convertit chaque élément en MvtStock
      return jsonData.map((item) => MvtStock.fromJson(item)).toList();
    } else {
      throw Exception(
          'Erreur lors de la récupération des mouvements: ${response.statusCode}');
    }
  }
}
