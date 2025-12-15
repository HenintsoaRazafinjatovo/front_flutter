import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/evenement.dart'; // ton modèle Evenement

class EvenementService {
  final String baseUrl = 'http://127.0.0.1:8000/api/evenements';

  // Récupérer tous les événements
  Future<List<Evenement>> getEvenements() async {
    final response = await http.get(Uri.parse('$baseUrl/evenements'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Evenement.fromJson(e)).toList();
    } else {
      throw Exception('Erreur lors de la récupération des événements');
    }
  }

  // Récupérer un événement par ID
  Future<Evenement> getEvenementById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));

    if (response.statusCode == 200) {
      return Evenement.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Événement non trouvé');
    }
  }

  // Ajouter un nouvel événement
  Future<Evenement> createEvenement(Evenement evenement) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(evenement.toJson()),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return Evenement.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Erreur lors de la création de l’événement');
    }
  }
  Future<Evenement> createEvenementWithLivraison(Evenement evenement,int idLivraison) async {
    final body = jsonEncode({
      ...evenement.toJson(),
      'id_bon_de_livraison': idLivraison,
    });
    final response = await http.post(
      Uri.parse('$baseUrl/with-livraison'),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );
  print('Status code: ${response.statusCode}');
  print('Body: ${response.body}');
    if (response.statusCode == 201 || response.statusCode == 200) {
      return Evenement.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Erreur lors de la création de l’événement');
    }
  }

  // Mettre à jour un événement
  Future<Evenement> updateEvenement(Evenement evenement) async {
    if (evenement.idEvenement == null) {
      throw Exception('L\'ID de l’événement est requis pour la mise à jour');
    }

    final response = await http.put(
      Uri.parse('$baseUrl/${evenement.idEvenement}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(evenement.toJson()),
    );

    if (response.statusCode == 200) {
      return Evenement.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Erreur lors de la mise à jour de l’événement');
    }
  }

  // Supprimer un événement
  Future<void> deleteEvenement(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));

    if (response.statusCode != 200) {
      throw Exception('Erreur lors de la suppression de l’événement');
    }
  }
}
