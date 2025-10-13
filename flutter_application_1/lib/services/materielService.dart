import 'dart:convert';
import 'dart:typed_data'; 
import 'package:http/http.dart' as http;
import '../models/materiel.dart';
import '../utils/paginatedResponse.dart';

class MaterielService {
  final String baseUrl = 'http://127.0.0.1:8000/api/materiels';

  // Récupérer tous les matériels
  Future<PaginatedResponse<Materiel>> getAllMateriels({int page = 1, int perPage = 10}) async {
    final url = Uri.parse('$baseUrl?page=$page&perPage=$perPage');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return PaginatedResponse.fromJson(
        data,
        (item) => Materiel.fromJson(item),
      );
    } else {
      throw Exception('Erreur lors de la récupération des matériels : ${response.statusCode}');
    }
  }
  Future<List<Materiel>> getAllMaterielsList() async {
    final url = Uri.parse('$baseUrl/all');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Materiel.fromJson(json)).toList();
    } else {
      throw Exception('Erreur lors de la récupération des matériels : ${response.statusCode}');
    }
  }
  Future<Map<String, dynamic>> createMateriel(Materiel materiel) async {
    try {
      final url = Uri.parse(baseUrl);
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(materiel.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          "success": true,
          "materiel": Materiel.fromJson(json.decode(response.body)),
          "error": null,
        };
      } else {
        return {
          "success": false,
          "materiel": null,
          "error": response.body, // message d’erreur renvoyé par le backend
        };
      }
    } catch (e) {
      return {
        "success": false,
        "materiel": null,
        "error": e.toString(), // erreur réseau ou exception
      };
    }
  }

  // Mettre à jour un matériel
  Future<Map<String, dynamic>> updateMateriel(Materiel materiel) async {
    if (materiel.idMateriel == null) {
      return {
        "success": false,
        "materiel": null,
        "error": "ID du matériel requis pour la mise à jour",
      };
    }

    try {
      final url = Uri.parse('$baseUrl/${materiel.idMateriel}');
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(materiel.toJson()),
      );

      if (response.statusCode == 200) {
        return {
          "success": true,
          "materiel": Materiel.fromJson(json.decode(response.body)),
          "error": null,
        };
      } else {
        return {
          "success": false,
          "materiel": null,
          "error": response.body,
        };
      }
    } catch (e) {
      return {
        "success": false,
        "materiel": null,
        "error": e.toString(),
      };
    }
  }

  // Supprimer un matériel
  Future<Map<String, dynamic>> deleteMateriel(int id) async {
    try {
      final url = Uri.parse('$baseUrl/$id');
      final response = await http.delete(url);

      if (response.statusCode == 200 || response.statusCode == 204) {
        return {
          "success": true,
          "error": null,
        };
      } else {
        return {
          "success": false,
          "error": response.body,
        };
      }
    } catch (e) {
      return {
        "success": false,
        "error": e.toString(),
      };
    }
  }
  Future<Uint8List?> getMaterielQr(int id) async {
    try {
      final url = Uri.parse('$baseUrl/$id/barcodeImage'); // attention au route exact
      final response = await http.get(url, headers: {
        'Accept': 'image/png', // pour signaler qu’on attend une image
      });

      if (response.statusCode == 200) {
        return response.bodyBytes; // Uint8List de l'image PNG
      } else {
        print('Erreur lors de la récupération du QR code : ${response.statusCode}');
        print('Body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception lors de la récupération du QR code: $e');
      return null;
    }
  }
}
