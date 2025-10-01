import 'dart:convert';
import 'package:flareline_template/models/inventaire_materiel.dart';
import 'package:http/http.dart' as http;
import '../models/inventaire.dart';
import '../models/inventaireImmo.dart';
import '../models/inventaire_article.dart';
import '../models/employe.dart';
import '../utils/paginatedResponse.dart';

class InventaireService {
  final String baseUrl = 'http://127.0.0.1:8000/api/inventaires';

  Future<PaginatedResponse<Inventaire>> getAllInventaires({
    int page = 1,
    int perPage = 10,
  }) async {
    final url = Uri.parse('$baseUrl/getInventairesWithDetails?page=$page&per_page=$perPage');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return PaginatedResponse.fromJson(
        data,
        (item) => Inventaire.fromJson(item),
      );
    } else {
    
      throw Exception('Erreur lors de la récupération des inventaires: ${response.body}');
    }
  }

  Future<bool> faireInventaire({
    required List<InventaireArticle> articles,
    required List<Employe> employes,
  }) async {
    final url = Uri.parse('$baseUrl/faireInventaire');

    final body = jsonEncode({
      'articles': articles
          .map((a) => {
                'id_article': a.article.idArticle,
                'stock_physique': a.stockPhysique,
              })
          .toList(),
      'employes': employes.map((e) => e.idEmploye).toList(),
    });

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: body,
    );

    if (response.statusCode == 201) {
      // return Inventaire.fromJson(jsonDecode(response.body));
      return true;

    } else {
      throw Exception(
          'Erreur lors de la création de l\'inventaire: ${response.body}');
    }
  }

  /// Récupérer l'écart d'un article
  Future<double> getEcart(int idArticle, double stockPhysique) async {
    final url = Uri.parse('$baseUrl/inventaires/ecart/$idArticle?stock_physique=$stockPhysique');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['ecart'] as num).toDouble();
    } else {
      throw Exception('Erreur lors de la récupération de l\'écart: ${response.body}');
    }
  }
  Future<double> getStockActuel(int idArticle) async {
    final url = Uri.parse('$baseUrl/getStockActuel/$idArticle');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['stock_theorique'] as num).toDouble();
    } else {
      throw Exception('Erreur lors de la récupération du stock actuel: ${response.body}');
    }
  }
  //  Future<List<Inventaire>> getAllInventairesWithDetails() async {
  //   try {
  //     final response = await http.get(
  //       Uri.parse('$baseUrl/getInventairesWithDetails'),
    
  //     );

  //     if (response.statusCode == 200) {
  //       final List<dynamic> jsonData = json.decode(response.body);
  //       return jsonData.map((json) => Inventaire.fromJson(json)).toList();
  //     } else {
  //       throw Exception('Erreur ${response.statusCode}: ${response.body}');
  //     }
  //   } catch (e) {
  //     throw Exception('Erreur de connexion: $e');
  //   }
  // }
  Future<List<Inventaire>> getAllInventairesWithDetails() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/getInventairesWithDetails'),
    
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => Inventaire.fromJson(json)).toList();
      } else {
        throw Exception('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }
  Future<PaginatedResponse<InventaireImmo>> getAllInventairesImmoWithDetails({int page = 1, int perPage = 10}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/getInventaireWithMateriels?page=$page&per_page=$perPage'),

      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return PaginatedResponse.fromJson(
          jsonData,
          (item) => InventaireImmo.fromJson(item),
        );  
      } else {
        throw Exception('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }
  Future<bool> faireInventaireImmo({
    required List<InventaireMateriel> materiels,
    required List<Employe> employes,
  }) async {
    final url = Uri.parse('$baseUrl/faireInventaireImmo');

    final body = jsonEncode({
      'materiels': materiels
          .map((a) => {
                'id_materiel': a.materiel.idMateriel,
                'stock_physique': a.stockPhysique,
              })
          .toList(),
      'employes': employes.map((e) => e.idEmploye).toList(),
    });

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: body,
    );

    if (response.statusCode == 201) {
      // return Inventaire.fromJson(jsonDecode(response.body));
      return true;

    } else {
      throw Exception(
          'Erreur lors de la création de l\'inventaire: ${response.body}');
    }
  }
}
