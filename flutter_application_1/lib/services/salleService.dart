import '../models/salle.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SalleService {
  final String baseUrl = 'http://127.0.0.1:8000/api/salles';

  Future<List<Salle>> getSalles() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Salle.fromJson(json)).toList();
    } else {
      print("Erreur lors du chargement des salles: ${response.body}");
      throw Exception('Erreur lors du chargement des salles');
    }
  }

  
}
