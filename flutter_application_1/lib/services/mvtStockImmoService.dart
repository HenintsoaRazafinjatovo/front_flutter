import '../models/materiel.dart';
import 'dart:convert';
import '../models/mvtStockImmo.dart';
import 'package:http/http.dart' as http;
     
 // Classe d'aide pour l'affichage des mouvements dans le tableau
class MovementDisplay {
  final DateTime dateMvt;
  final String type;
  final String materielNom;
  final double quantite;
  final double? totalMateriel;
  final String? sourceOrDirection;

  MovementDisplay({
    required this.dateMvt,
    required this.type,
    required this.materielNom,
    required this.quantite,
    this.totalMateriel,
    this.sourceOrDirection,
  });

  // Factory pour convertir depuis les données de l'API
  factory MovementDisplay.fromApiData(Map<String, dynamic> json) {
    return MovementDisplay(
      dateMvt: DateTime.parse(json['date_mvt']),
      type: json['type'],
      materielNom: json['materiel_nom'] ?? json['intitule'] ?? '',
      quantite: double.tryParse(json['quantite'].toString()) ?? 0.0,
      totalMateriel: double.tryParse(json['total_materiel'].toString()),
      sourceOrDirection: json['source_direction'],
    );
  }
}

class MvtStockImmoService {

  final String baseUrl = "http://127.0.0.1:8000/api/mvt-stocks"; 

  // Pour récupérer les mouvements avec infos d'affichage
   Future<List<MvtStockImmo>> getMouvementsImmo() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/details-immo"));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        return data.map((json) => MvtStockImmo.fromJson(json)).toList();
      } else {
        throw Exception(
            "Erreur lors du chargement des mouvements : ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Erreur de connexion à l'API: $e");
    }
  }
  Future<List<Materiel>> getMateriels() async {
    // TODO: Replace with actual implementation to fetch materiels
    // Example:
    // final response = await http.get(Uri.parse('your_api_endpoint'));
    // return parseMateriels(response.body);
    return [];
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
}
  
