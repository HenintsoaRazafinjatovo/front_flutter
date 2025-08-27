import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/bon_de_commande.dart';

class BonDeCommandeService {
  final String baseUrl='http://127.0.0.1:8000/api/bon_de_commandes';


  // Récupérer la liste des bons de commande
  Future<List<BonDeCommande>> getBonDeCommandeWithStatus() async {
    final response = await http.get(Uri.parse('$baseUrl/getBonDeCommandeWithDetails'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => BonDeCommande.fromJson(item)).toList();
    } else {
      throw Exception(
          'Erreur lors de la récupération des bons de commande : ${response.statusCode}');
    }
  }
  Future<List<BonDeCommande>> getBonDeCommandeWithStatusEnAttente() async {
    final response = await http.get(Uri.parse('$baseUrl/getBonDeCommandeWithDetailsEnAttente'));
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
      headers: {
        'Content-Type': 'application/json',
        'accept': 'application/json',
      },
      body: json.encode(body),
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      print('Erreur lors de l\'ajout du bon de commande : ${response.statusCode} - ${response.body}');
      return false;
    }
  }

  // Supprimer un bon de commande
  Future<bool> deleteBonDeCommande(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/$id'),
    );

    return response.statusCode == 200;
  }
  Future<List<BonDeCommande>> getBonDeCommandes() async {
    final response = await http.get(Uri.parse('$baseUrl/getBonDeCommandeWithDetails'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => BonDeCommande.fromJson(e)).toList();
    } else {
      throw Exception('Erreur lors de la récupération des bons de commande');
    }
  }
  Future<bool> validerBonDeCommande(int id) async {
    final response = await http.put(
      Uri.parse('$baseUrl/valider/$id'),
      headers: {
        'Content-Type': 'application/json',
        'accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      print(jsonDecode(response.body)['message']);
      return true;
    } else {
      print('Erreur lors de la validation du bon de commande : ${response.statusCode} - ${response.body}');
      return false;
    }
  }

  // Rejeter un bon de commande
  Future<bool> rejeterBonDeCommande(int id) async {
    final response = await http.put(
      Uri.parse('$baseUrl/rejeter/$id'),
      headers: {
        'Content-Type': 'application/json',
        'accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      print(jsonDecode(response.body)['message']);
      return true;
    } else {
      print('Erreur lors du rejet du bon de commande : ${response.statusCode} - ${response.body}');
      return false;
    }
  }
}
