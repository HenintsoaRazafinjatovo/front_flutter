import 'package:dio/dio.dart';

class StatistiqueService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "http://127.0.0.1:8000/api/statistiques", // ⚠️ Mets l’URL de ton backend
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  /// Récupère le nombre de commandes par agence
  Future<List<dynamic>> getCommandesParAgence(int annee) async {
    try {
      final response = await _dio.get('/commandes-par-agence/$annee');
      return response.data['commandes_par_agence'];
    } catch (e) {
      throw Exception("Erreur lors de la récupération des commandes par agence: $e");
    }
  }

  /// Récupère le top 5 des articles
  Future<List<dynamic>> getTop5Articles(int annee) async {
    try {
      final response = await _dio.get('/top5-articles/$annee');
      return response.data['top5_articles'];
    } catch (e) {
      throw Exception("Erreur lors de la récupération du top 5 des articles: $e");
    }
  }

  /// Récupère l’évolution des commandes par mois
  Future<List<dynamic>> getEvolutionCommandes(int annee) async {
    try {
      final response = await _dio.get('/evolution-commandes/$annee');
      return response.data['evolution_commandes'];
    } catch (e) {
      throw Exception("Erreur lors de la récupération de l’évolution des commandes: $e");
    }
  }
}
