import 'dart:convert';

import '../models/employe.dart';
import 'package:http/http.dart' as http;

class EmployeService {
  final String baseUrl = "http://127.0.0.1:8000/api/employes";

  // Récupérer tous les employés
  Future<List<Employe>> getEmployes() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);

        // Convertir chaque élément en Employe
        return jsonData.map((item) => Employe.fromJson(item)).toList();
      } else {
        throw Exception('Erreur lors du chargement des employés');
      }
    } catch (e) {
      throw Exception('Erreur réseau : $e');
    }
  }
}