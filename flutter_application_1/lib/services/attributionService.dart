import 'dart:convert';
import 'package:http/http.dart' as http;
class Attributionservice {
  final String baseUrl= "http://127.0.0.1:8000/api/attributions";
  Future<bool> createAttributionWithMvtStock({
    required List<Map<String, dynamic>> articles,
    required String description,
    required int idDirection,
  }) async {
    final url = Uri.parse(baseUrl); 

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'articles': articles,
          'description': description,
          'id_direction': idDirection,
        }),
      );

      print("Réponse du serveur: ${response.statusCode}");
      print("Corps de la réponse: ${response.body}");

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      } else {
        print('Erreur lors de la création du mouvement : ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print("Erreur réseau: $e");
      return false;
    }
  }

  
}