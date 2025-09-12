import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/facture.dart';

class FactureService {
   final String baseUrl = "http://127.0.0.1:8000/api/factures"; 
  Future<List<Facture>> getFactures() async {
    final url = Uri.parse(baseUrl);
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final factures = data.map((json) => Facture.fromJson(json)).toList();
        return factures;
      } else {
        throw Exception(
            'Erreur lors de la récupération des factures : ${response.statusCode}');
      }
    } catch (e) {
      print("Erreur ebbbbebebebe : " + e.toString());
      if (e is http.Response) {
        print("Response body: " + e.body);
      }
      throw Exception('Erreur réseau ou JSON invalide : $e');
    }
  }
  Future<Map<String, dynamic>> creerFactureParBonLivraison(int idBonLivraison) async {
  try {
    final response = await http.post(
      Uri.parse("$baseUrl/creerParBl/$idBonLivraison"),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
    );

    if (response.statusCode == 201) {
      // Facture créée avec succès
      final body = json.decode(response.body);
      return {
        "success": true,
        "facture": body,
      };
    } else {
      // Erreur côté API
      final body = json.decode(response.body);
      return {
        "success": false,
        "error": body['error'] ?? "Erreur inconnue",
      };
    }
  } catch (e) {
    // Erreur réseau / exception
    print("Erreur API: $e");

    return {
      "success": false,
      "error": "Exception: $e",
    };
  }
}

}
