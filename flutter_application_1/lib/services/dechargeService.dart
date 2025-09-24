import 'dart:convert';
import 'dart:typed_data';

import '../models/decharge.dart';
import 'package:http/http.dart' as http;

class DechargeService {
  final String baseUrl = "http://127.0.0.1:8000/api/decharges";
  final String pdfBaseUrl = 'http://127.0.0.1:8000/api/pdfDecharge/decharge';


  // Récupérer toutes les décharges
  Future<List<Decharge>> getDecharges() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);

        // Convertir chaque élément en Decharge
        return jsonData.map((item) => Decharge.fromJson(item)).toList();
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