import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/statistiqueService.dart';

class StatistiqueArticle extends StatefulWidget {
  const StatistiqueArticle({super.key});

  @override
  _StatistiqueArticleState createState() => _StatistiqueArticleState();
}

class _StatistiqueArticleState extends State<StatistiqueArticle> {
  Map<String, dynamic>? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchStatistics();
  }

  Future<void> fetchStatistics() async {
    try {
      StatistiqueService service = StatistiqueService();
      Map<String, dynamic> stats = await service.buildPageArticle();
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      print("Erreur lors de la récupération des statistiques: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_stats == null) {
      return const Center(
        child: Text(
          "Impossible de charger les statistiques.",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    final statArticle = _stats?['stat_article'] ?? {};
    final repartition = _stats?['repartition_articles_categorie'] ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildStatsGrid(statArticle),
          const SizedBox(height: 28),
          _buildCategoryDistribution(repartition),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statistiques Articles',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.grey[900],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Vue d\'ensemble de votre inventaire',
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(Map<String, dynamic> statArticle) {
    final nbEnStock = statArticle['nb_article_en_stock'] ?? 0;
    final nbStockFaible = statArticle['nb_article_stock_faible'] ?? 0;
    final nbInventaire = statArticle['nb_inventaire_du_mois'] ?? 0;
    final nbRupture = statArticle['nb_article_en_rupture_de_stock'] ?? 0;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Articles en stock',
            nbEnStock.toString(),
            Icons.inventory_2_rounded,
            const Color(0xFFF9B70D),
            const Color(0xFFFFF8E1),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Stock faible',
            nbStockFaible.toString(),
            Icons.warning_amber_rounded,
            Colors.orange.shade700,
            Colors.orange.shade50,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Inventaires du mois',
            nbInventaire.toString(),
            Icons.fact_check_rounded,
            Colors.green.shade600,
            Colors.green.shade50,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Rupture de stock',
            nbRupture.toString(),
            Icons.remove_shopping_cart_rounded,
            Colors.red.shade700,
            Colors.red.shade50,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color iconColor,
    Color bgColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: iconColor,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryDistribution(List<dynamic> repartition) {
    if (repartition.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Text(
            'Aucune donnée de répartition disponible',
            style: TextStyle(fontSize: 15, color: Colors.grey[600]),
          ),
        ),
      );
    }

    final colors = [
      const Color(0xFFF9B70D),
      const Color(0xFF4CAF50),
      const Color(0xFF2196F3),
      const Color(0xFFFF9800),
      const Color(0xFF9C27B0),
      const Color(0xFFE91E63),
      const Color(0xFF00BCD4),
      const Color(0xFFFF5722),
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Répartition par catégorie',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[900],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: SizedBox(
                  height: 280,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 3,
                      centerSpaceRadius: 60,
                      sections: repartition.asMap().entries.map((entry) {
                        int index = entry.key;
                        var item = entry.value;
                        return PieChartSectionData(
                          color: colors[index % colors.length],
                          value: (item['nb_articles'] ?? 0).toDouble(),
                          title: '${item['nb_articles'] ?? 0}',
                          radius: 85,
                          titleStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 32),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: repartition.asMap().entries.map((entry) {
                    int index = entry.key;
                    var item = entry.value;
                    final categoryName = item['nom_categorie'] ?? 'Catégorie ${item['id_categorie']}';
                    final nbArticles = item['nb_articles'] ?? 0;
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        children: [
                          Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: colors[index % colors.length],
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  categoryName,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[800],
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '$nbArticles article${nbArticles > 1 ? 's' : ''}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}