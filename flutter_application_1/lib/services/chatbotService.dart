import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatbotService {
  final String baseUrl= 'http://127.0.0.1:8000/api/chatbot';



  /// Envoie le message à l'API et retourne la réponse du chatbot
  Future<String> sendMessage(String message) async {
    final url = Uri.parse(baseUrl);

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': message}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['message'] ?? 'Pas de réponse du chatbot.';
      } else {
        return 'Erreur API : ${response.statusCode}';
      }
    } catch (e) {
      return 'Erreur de connexion : $e';
    }
  }
}
