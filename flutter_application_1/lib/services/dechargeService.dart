import 'dart:convert';

import '../models/decharge.dart';
import 'package:http/http.dart' as http;

class DechargeService {
  final String baseUrl = "http://127.0.0.1:8000/api/decharges";

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
}