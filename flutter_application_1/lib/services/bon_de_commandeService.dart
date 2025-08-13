import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/bon_de_commande.dart';

class BonDeCommandeService {
  final String baseUrl='http://127.0.0.1:8000/api/bon_de_commandes';


  // Récupérer la liste des bons de commande
  Future<List<BonDeCommande>> getBonDeCommandeWithStatus() async {
    final response = await http.get(Uri.parse('$baseUrl/getBonDeCommandeWithStatus'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => BonDeCommande.fromJson(item)).toList();
    } else {
      throw Exception(
          'Erreur lors de la récupération des bons de commande : ${response.statusCode}');
    }
  }

  Future<bool> addBonDeCommande({
    required String description,
    required List<Map<String, dynamic>> articles,
    int? idStatusCommande,
  }) async {
    final body = {
      'description': description,
      'id_status_commande': idStatusCommande,
      'articles': articles,
    };

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );

    return response.statusCode == 201;
  }

  // Supprimer un bon de commande
  Future<bool> deleteBonDeCommande(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/$id'),
    );

    return response.statusCode == 200;
  }
}
