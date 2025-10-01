import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/mvt_stock.dart'; 
import '../utils/paginatedResponse.dart';

class MvtStockService {
  final String baseUrl = "http://127.0.0.1:8000/api/mvt-stocks"; 
  Future<bool> createMouvementWithArticles(
  int type,
  List<Map<String, dynamic>> articles,
) async {
  final url = Uri.parse('$baseUrl/create');

  try {
    final response = await http.post(
        url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'type': type,
        'articles': articles,
        'date_mvt': DateTime.now().toIso8601String(),
      }),
    );
    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data['success'] == true;
    } else {
      if (response.body.isNotEmpty) {
        final errorData = jsonDecode(response.body);
        print("Détails de l'erreur: $errorData");
      }
      return false;
    }
  } catch (e) {
    print("Erreur réseau: $e");
    return false;
  }
}

  Future<PaginatedResponse<MvtStock>> getMouvementsDetails({int page = 1 , int perPage = 10}) async {
    final url = Uri.parse('$baseUrl/details?page=$page&per_page=$perPage'); // remplace par la route de ton controller

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
  return PaginatedResponse.fromJson(
          jsonData,
          (item) => MvtStock.fromJson(item),
       );
    } else {
      throw Exception(
          'Erreur lors de la récupération des mouvements: ${response.statusCode}');
    }
  }
}
