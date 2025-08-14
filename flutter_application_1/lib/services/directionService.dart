import 'dart:convert';

import '../models/direction.dart';
import 'package:http/http.dart' as http;

class DirectionService {
  final String baseUrl = "http://127.0.0.1:8000/api/directions";

  // Récupérer toutes les directions
  Future<List<Direction>> getDirections() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);

        // Convertir chaque élément en Direction
        return jsonData.map((item) => Direction.fromJson(item)).toList();
      } else {
        throw Exception('Erreur lors du chargement des directions');
      }
    } catch (e) {
      throw Exception('Erreur réseau : $e');
    }
  }
}