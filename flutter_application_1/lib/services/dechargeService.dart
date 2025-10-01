import 'dart:convert';
import 'dart:typed_data';

import 'package:flareline_template/utils/paginatedResponse.dart';

import '../models/decharge.dart';
import 'package:http/http.dart' as http;

class DechargeService {
  final String baseUrl = "http://127.0.0.1:8000/api/decharges";
  final String pdfBaseUrl = 'http://127.0.0.1:8000/api/pdfDecharge/decharge';


  // Récupérer toutes les décharges
  Future<PaginatedResponse<Decharge>> getDecharges({int page = 1, int perPage = 10}) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl?page=$page&per_page=$perPage'));

      if (response.statusCode == 200) {
        final  jsonData = json.decode(response.body);

        // Convertir chaque élément en Decharge
        return PaginatedResponse.fromJson(
          jsonData,
          (item) => Decharge.fromJson(item),
        );
      } else {
        throw Exception('Erreur lors du chargement des décharges');
      }
    } catch (e) {
      throw Exception('Erreur réseau : $e');
    }
  }
  Future<Uint8List> generatePdf( int id) async {
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