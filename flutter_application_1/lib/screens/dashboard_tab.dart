
import 'package:flutter/material.dart';
import '../services/statistiqueService.dart';

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  _DashboardTabState createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
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
      Map<String, dynamic> stats = await service.buildStat();
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
      return const Center(child: Text("Impossible de charger les statistiques."));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildTopSection(),
          const SizedBox(height: 20),
          _buildMiddleSection(),
          const SizedBox(height: 20),
          _buildBottomSection(),
        ],
      ),
    );
  }

  // ------------------- Top Section: KPIs Large -------------------
  Widget _buildTopSection() {
    final totalOrders = _stats?['nb_commandes_non_validees'] ?? 0;
    final totalRevenue = _stats?['montant_total_facture_du_mois'] ?? '0';
    final totalArticles = _stats?['nb_article_en_stock'] ?? 0;
    final totalAgencies = _stats?['nb_agences'] ?? 0;

    // const warningYellow = Color(0xFFF9B70D);
    const darkYellow = Color(0xFFB28704);
    // const lightGrey = Color(0xFFF7F6E7);
    // const mediumGrey = Color(0xFF999666);

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: _buildLargeCard(
            '',
                  '${totalRevenue.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]} ')} Ar',
            'Chiffre d\'affaires du mois',
            const Color.fromARGB(255, 244, 209, 123),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            children: [
              _buildSmallCard('📦', totalOrders.toString(), 'Commandes en attente', darkYellow),
              const SizedBox(height: 12),
              _buildSmallCard('📋', totalArticles.toString(), 'Articles en stock', darkYellow),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            children: [
              _buildSmallCard('🏢', totalAgencies.toString(), 'Agences', darkYellow),
              const SizedBox(height: 12),
              _buildActivityIndicator(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLargeCard(String icon, String value, String label, Color color) {
    return Container(
      height: 160,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.85), color.withOpacity(0.45)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(icon, style: const TextStyle(fontSize: 32, color: Colors.white70)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallCard(String icon, String value, String label, Color color) {
    return Container(
      height: 74,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(child: Text(icon, style: TextStyle(fontSize: 20, color: color.withOpacity(0.8)))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityIndicator() {
    final dailyEvents = _stats?['nb_evenements_aujourdhui'] ?? 0;
    return Container(
      height: 74,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFFF9B70D), const Color(0xFFD79500)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            dailyEvents.toString(),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            'Événements du jour',
            style: TextStyle(
              fontSize: 10,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }


  // ------------------- Middle Section: Stats Grid -------------------
  Widget _buildMiddleSection() {
    final lowStockItems = _stats?['nb_article_stock_faible'] ?? 0;
    final monthlyInventories = _stats?['nb_inventaire_du_mois'] ?? 0;
    final mouvements = _stats?['nb_mouvements_du_mois'] ?? {'sorties': 0, 'entrees': 0};
    final entrees = mouvements['entrees'] ?? 0;
    final sorties = mouvements['sorties'] ?? 0;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Articles à risque',
            lowStockItems.toString(),
            'Stock < seuil',
            Icons.warning_amber_rounded,
            Colors.deepOrange.shade700,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Inventaires réalisés',
            monthlyInventories.toString(),
            'Ce mois',
            Icons.inventory_2_rounded,
            Colors.green.shade700,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Entrées',
            entrees.toString(),
            'Mouvements',
            Icons.arrow_downward_rounded,
            const Color(0xFFF9B70D),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Sorties',
            sorties.toString(),
            'Mouvements',
            Icons.arrow_upward_rounded,
            Colors.red.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  // ------------------- Bottom Section: Progress Bars -------------------
  Widget _buildBottomSection() {
    final totalArticles = _stats?['nb_article_en_stock'] ?? 1;
    final lowStockItems = _stats?['nb_article_stock_faible'] ?? 0;
    final stockHealthPercent = ((totalArticles - lowStockItems) / totalArticles * 100).clamp(0, 100);

    final mouvements = _stats?['nb_mouvements_du_mois'] ?? {'sorties': 0, 'entrees': 0};
    final entrees = mouvements['entrees'] ?? 0;
    final sorties = mouvements['sorties'] ?? 0;
    final totalMouvements = entrees + sorties;
    final entreesPercent = totalMouvements > 0 ? (entrees / totalMouvements * 100) : 0;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildProgressCard(
                'Santé du stock',
                stockHealthPercent.toInt(),
                '${totalArticles - lowStockItems} articles OK / $totalArticles',
                const Color(0xFFF9B70D),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildProgressCard(
                'Ratio Entrées/Sorties',
                entreesPercent.toInt(),
                '$entrees entrées / $sorties sorties',
                Colors.red.shade700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildAdditionalInfoSection(),
      ],
    );
  }

  Widget _buildProgressCard(String title, int percent, String subtitle, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              Text(
                '$percent%',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percent / 100,
              minHeight: 8,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  // ------------------- Additional Info Section -------------------
  Widget _buildAdditionalInfoSection() {
    final totalOrders = _stats?['nb_commandes_non_validees'] ?? 0;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 2,
              child: _buildQuickStatsPanel(),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTrendCard(
                'Commandes',
                totalOrders,
                'En attente de validation',
                Icons.pending_actions,
                const Color(0xFFF9B70D),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickStatsPanel() {
    final mouvements = _stats?['nb_mouvements_du_mois'] ?? {'sorties': 0, 'entrees': 0};
    final entrees = mouvements['entrees'] ?? 0;
    final sorties = mouvements['sorties'] ?? 0;
    final totalMouvements = entrees + sorties;
    final lowStockItems = _stats?['nb_article_stock_faible'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            // const Color(0xFFF9B70D),
            const Color.fromARGB(255, 244, 209, 123),
            const Color.fromARGB(255, 244, 209, 123),

            // const Color(0xFFB28704),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 243, 211, 131).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Aperçu du mois',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildQuickStatItem('$totalMouvements', 'Mouvements totaux'),
              ),
              Container(width: 1, height: 40, color: Colors.white30),
              Expanded(
                child: _buildQuickStatItem('$lowStockItems', 'Alertes stock'),
              ),
              Container(width: 1, height: 40, color: Colors.white30),
              Expanded(
                child: _buildQuickStatItem(
                  totalMouvements > 0 ? '${(sorties / totalMouvements * 100).toStringAsFixed(0)}%' : '0%',
                  'Taux de sortie',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildTrendCard(String title, int value, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 36),
          const SizedBox(height: 12),
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
