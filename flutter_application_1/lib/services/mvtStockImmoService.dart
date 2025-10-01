import 'package:flareline_template/models/decharge.dart';
import 'package:flareline_template/utils/paginatedResponse.dart%20';

import '../models/materiel.dart';
import 'dart:convert';
import '../models/mvtStockImmo.dart';
import '../models/attribution.dart';
import 'package:http/http.dart' as http;
     

class MvtStockImmoService {

  final String baseUrl = "http://127.0.0.1:8000/api/mvt-stocks"; 

  // Pour récupérer les mouvements avec infos d'affichage
   Future<PaginatedResponse<MvtStockImmo>> getMouvementsImmo({int page = 1, int perPage = 10}) async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/details-immo?page=$page&per_page=$perPage"));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return PaginatedResponse.fromJson(
          data, 
        (item) => MvtStockImmo.fromJson(item)
        );

      } else {
        throw Exception(
            "Erreur lors du chargement des mouvements : ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Erreur de connexion à l'API: $e");
    }
  }

  Future<bool> createWithImmo({
    required String type,
    required List<Map<String, dynamic>> materiels,
  }) async {
    final url = Uri.parse('$baseUrl/api/mouvements-immo'); // adapte l'URL

    final body = jsonEncode({
      'type': type,
      'materiels': materiels,
    });

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          // 'Authorization': 'Bearer YOUR_TOKEN', // si tu utilises l'auth
        },
        body: body,
      );

      if (response.statusCode == 201) {
        print('Mouvement créé avec succès');
        return true;
      } else {
        print('Erreur: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Exception: $e');
      return false;
    }
  }
  Future<bool> createWithAttribution({
    required List<MvtStockImmo> materiels,
    required Attribution attribution,
    required Decharge decharge,
  }) async {
    final url = Uri.parse('$baseUrl/createWithImmoAndAttribution');

    final body = jsonEncode({
      'materiels': materiels.map((m) => m.toJson()).toList(),
      'attribution': attribution.toJson(),
      'decharge': decharge.toJson(),
    });

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Exception: $e');
      return false;
    }
  }
  Future<bool> createWithOrigine({
    required List<MvtStockImmo> materiels,
    required int idOrigine,
  }) async {
    final url = Uri.parse('$baseUrl/createWithOrigine');

    final body = jsonEncode({
      'materiels': materiels,
      'id_origine': idOrigine,
    });

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Erreur API: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Exception: $e');
      return false;
    }
  }

}
  
