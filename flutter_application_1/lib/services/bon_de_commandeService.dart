import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/bon_de_commande.dart';
import '../utils/paginatedResponse.dart';
import 'dart:typed_data';


class BonDeCommandeService {
  final String baseUrl='http://127.0.0.1:8000/api/bon_de_commandes';
  final String pdfBaseUrl = 'http://127.0.0.1:8000/api/pdf/commande';
  final String predictionUrl = 'http://127.0.0.1:8000/api/fetch-predictions';

  Future<PaginatedResponse<BonDeCommande>> getBonDeCommandeWithStatus({
  int page = 1,
  int perPage = 10,
}) async {
  final response = await http.get(
    Uri.parse('$baseUrl/getBonDeCommandeWithDetails?page=$page&per_page=$perPage'),
  );

  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);
    return PaginatedResponse.fromJson(
      jsonResponse,
      (item) => BonDeCommande.fromJson(item),
    );
  } else {
    throw Exception('Erreur lors de la récupération: ${response.statusCode}');
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
  Future <List<BonDeCommande>> getBonDeCommandeWithoutBonDeLivraison() async {
    final response = await http.get(Uri.parse('$baseUrl/getBonDeCommandeWithoutBonDeLivraison'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => BonDeCommande.fromJson(item)).toList();
    } else {
      throw Exception(
          'Erreur lors de la récupération des bons de commande : ${response.statusCode}');
    }
  }
  Future<BonDeCommande> getCommandePrediction(DateTime date, int idAgence) async {
  final formattedDate = date.toIso8601String().split("T")[0]; // YYYY-MM-DD
  final uri = Uri.parse('$predictionUrl?date=$formattedDate&agence=$idAgence');

  final response = await http.get(uri, headers: {'Accept': 'application/json'});

  if (response.statusCode == 200) {
    final Map<String, dynamic> data = json.decode(response.body);
    return BonDeCommande.fromJson(data); // assure-toi que BonDeCommande.fromJson gère "articles" et "agence"
  } else {
    throw Exception(
        'Erreur lors de la récupération de la commande prédictive : ${response.statusCode} - ${response.body}');
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
      return true;
    } else {
      print('Erreur lors du rejet du bon de commande : ${response.statusCode} - ${response.body}');
      return false;
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
