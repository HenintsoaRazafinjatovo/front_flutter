import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/bon_de_livraison.dart';
import 'dart:typed_data';

class BonDeLivraisonService {
  final String baseUrl = 'http://127.0.0.1:8000/api/bon_de_livraisons';
  final String pdfBaseUrl = 'http://127.0.0.1:8000/api/pdf/livraison';

  // Récupérer la liste des bons de livraison avec leurs détails
  Future<List<BonDeLivraison>> getBonDeLivraisonWithDetails() async {
    final response = await http.get(Uri.parse(baseUrl));
    
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => BonDeLivraison.fromJson(item)).toList();
    } else {
      print("Erreur : " + response.body);
      throw Exception('Erreur lors de la récupération des bons de livraison : ${response.statusCode}');
    }
  }

  // Récupérer un bon de livraison par ID
  Future<BonDeLivraison> getBonDeLivraisonById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));
    
    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      return BonDeLivraison.fromJson(data);
    } else {
      print("Erreur : " + response.body);
      throw Exception('Erreur lors de la récupération du bon de livraison : ${response.statusCode}');
    }
  }
  Future<bool> creerBonDeLivraison(int idBonDeCommande) async {
  final url = Uri.parse("$baseUrl/creer/$idBonDeCommande");

  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      // Si le backend renvoie juste "true" ou "false"
      return response.body.toLowerCase() == "true";
    } else {
      throw Exception("Erreur API: ${response.statusCode} - ${response.body}");
    }
  } catch (e) {
    throw Exception("Erreur lors de l'appel API: $e");
  }
}
Future<Uint8List> generatePdf(String type, int id) async {
    final url = Uri.parse('$pdfBaseUrl/$id');

    try {
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/pdf',
        },
      );

      if (response.statusCode == 200) {
        // Retourne le PDF sous forme de bytes
        return response.bodyBytes;
      } else {
        throw Exception(
            'Erreur lors de la génération du PDF : ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Erreur lors de l’appel API : $e');
    }
  }

}
