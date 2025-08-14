import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/mvt_stock.dart';
class Attributionservice {
  final String baseUrl= "http://127.0.0.1:8000/api/attributions";

 Future<Map<String, dynamic>> createAttributionWithMvtStock({
    required List<Map<String, dynamic>> articles,
    required String description,
    required int idDirection,
  }) async {
    final url = Uri.parse(baseUrl); // Assurez-vous que l'URL correspond à votre route Laravel

    final body = jsonEncode({
      'articles': articles,
      'description': description,
      'id_direction': idDirection,
    });

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: body,
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      print('Erreur lors de la création du mouvement : ${response.statusCode} - ${response.body}');
      throw Exception('Erreur lors de la création du mouvement : ${response.body}');
    }
  }
  
}