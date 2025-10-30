import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/statistiqueService.dart';

class StatistiqueCommande extends StatefulWidget {
  const StatistiqueCommande({super.key});

  @override
  _StatistiqueCommandeState createState() => _StatistiqueCommandeState();
}

class _StatistiqueCommandeState extends State<StatistiqueCommande> {
  Map<String, dynamic>? _stats;
  bool _isLoading = true;
  //  List<dynamic> agences = [];

  @override
  void initState() {
    super.initState();
    fetchStatistics();
  }

  Future<void> fetchStatistics() async {
    try {
      StatistiqueService service = StatistiqueService();
      Map<String, dynamic> stats = await service.buildPageCommande();
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

    // final statCommande = _stats?['stat_commande'] ?? {};
    final statCommande = Map<String, dynamic>.from(_stats?['stat_commande'] ?? {});

    final evolutionCommandes = _stats?['evolution_commandes'] ?? [];
    final agences = _stats?['commande_agence'] ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildTopKPIs(statCommande),
          const SizedBox(height: 28),
          _buildPieChart(agences),
          const SizedBox(height: 28),
          _buildEvolutionCommandes(evolutionCommandes),

          
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statistiques Commandes',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.grey[900],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Suivi de l\'activité commerciale',
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildTopKPIs(Map<String, dynamic> statCommande) {
    final nbAgencesActives = statCommande['nb_agences_actives'] ?? 0;
    final montantTotal = statCommande['montant_total_facture_du_mois'] ?? '0';
    final nbCommandesAttente = statCommande['nb_commandes_en_attente'] ?? 0;

    final montantFormatted = double.parse(montantTotal.toString())
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]} ');

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: _buildLargeRevenueCard(montantFormatted),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            children: [
              _buildSmallKPICard(
                Icons.apartment_outlined,
                nbAgencesActives.toString(),
                'Agences actives',
                const Color(0xFFF9B70D),
              ),
              const SizedBox(height: 12),
              _buildSmallKPICard(
                Icons.pending_actions_outlined,
                nbCommandesAttente.toString(),
                'Commandes en attente',
                Colors.orange.shade700,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLargeRevenueCard(String montant) {
    return Container(
      height: 168,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFF9B70D).withOpacity(0.9),
            const Color(0xFFF9B70D).withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF9B70D).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.payments_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$montant Ar',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Montant total facturé ce mois',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  Widget _buildSmallKPICard(IconData icon, String value, String label, Color color) {
  return Container(
    height: 78,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color.withOpacity(0.3), width: 2),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.08),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
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
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

  Widget _buildEvolutionCommandes(List<dynamic> evolutionCommandes) {
    if (evolutionCommandes.isEmpty) {
      return _buildEmptyCard('Aucune donnée d\'évolution disponible');
    }

    final monthNames = [
      '', 'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jun',
      'Jul', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'
    ];

    double maxY = evolutionCommandes
        .map((e) => (e['nb_commandes'] ?? 0).toDouble())
        .reduce((a, b) => a > b ? a : b);
    maxY = (maxY * 1.2).ceilToDouble();

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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.bar_chart_rounded,
                  color: Color(0xFFF9B70D),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Évolution des commandes',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[900],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 280,
            child: BarChart(
              BarChartData(
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) => Colors.grey[800]!,
                    tooltipBorderRadius: BorderRadius.circular(8),
                    tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${rod.toY.toInt()} commandes reçues',
                        const TextStyle(
                          color:  Color(0xFFF9B70D),
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      );
                    },
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY / 5,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey[200]!,
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 42,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget: (value, meta) {
                        int month = value.toInt();
                        if (month >= 1 && month <= 12) {
                          if (evolutionCommandes.any((e) => e['mois'] == month)) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                monthNames[month],
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minY: 0,
                maxY: maxY,
                barGroups: evolutionCommandes.map((item) {
                  final month = (item['mois'] ?? 0).toDouble();
                  final value = (item['nb_commandes'] ?? 0).toDouble();
                  return BarChartGroupData(
                    x: month.toInt(),
                    barRods: [
                      BarChartRodData(
                        toY: value,
                        color: const Color(0xFFF9B70D),
                        width: 20,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(6),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            const Color(0xFFF9B70D).withOpacity(0.7),
                            const Color(0xFFF9B70D),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
  // Widget _buildPieChart(List<dynamic> agences) {
  //   if (agences.isEmpty) {
  //     return _buildEmptyCard('Aucune donnée de répartition par agence disponible');
  //   }

  //   final sections = agences.map((a) {
  //     final value = double.parse(a["nb_commandes"].toString());
  //     return PieChartSectionData(
  //       value: value,
  //       title: "${a["code_agence"]}",
  //       color: Colors.primaries[agences.indexOf(a) % Colors.primaries.length],
  //       radius: 80,
  //     );
  //   }).toList();

  //   return Container(
  //     padding: const EdgeInsets.all(24),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(16),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.grey.withOpacity(0.08),
  //           blurRadius: 10,
  //           offset: const Offset(0, 3),
  //         ),
  //       ],
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Row(
  //           children: [
  //             Container(
  //               padding: const EdgeInsets.all(8),
  //               decoration: BoxDecoration(
  //                 color: const Color(0xFFFFF8E1),
  //                 borderRadius: BorderRadius.circular(8),
  //               ),
  //               child: const Icon(
  //                 Icons.pie_chart_rounded,
  //                 color: Color(0xFFF9B70D),
  //                 size: 22,
  //               ),
  //             ),
  //             const SizedBox(width: 12),
  //             Text(
  //               'Répartition des commandes par agence',
  //               style: TextStyle(
  //                 fontSize: 20,
  //                 fontWeight: FontWeight.bold,
  //                 color: Colors.grey[900],
  //               ),
  //             ),
  //           ],
  //         ),
  //         const SizedBox(height: 24),
  //         SizedBox(
  //           height: 300,
  //           child: PieChart(
  //             PieChartData(
  //               sections: sections,
  //               centerSpaceRadius: 60,
  //               sectionsSpace: 2,
  //             ),
  //           ),
  //         ),
  //         const SizedBox(height: 20),
  //         Wrap(
  //           spacing: 16,
  //           runSpacing: 8,
  //           children: agences.map((a) {
  //             final color = Colors.primaries[agences.indexOf(a) % Colors.primaries.length];
  //             return _buildLegendItem(a["code_agence"], color);
  //           }).toList(),
  //         ),
  //       ],
  //     ),
  //   );
  // }
  Widget _buildPieChart(List<dynamic> agences) {
    if (agences.isEmpty) {
      return _buildEmptyCard('Aucune donnée de répartition par agence disponible');
    }

    // Calculer le total des commandes
    final totalCommandes = agences.fold<double>(
      0,
      (sum, a) => sum + double.parse(a["nb_commandes"].toString()),
    );

    final sections = agences.map((a) {
      final value = double.parse(a["nb_commandes"].toString());
      final percentage = (value / totalCommandes * 100).toStringAsFixed(1);
      
      return PieChartSectionData(
        value: value,
        title: '',  // Pas de titre affiché directement
        color: Colors.primaries[agences.indexOf(a) % Colors.primaries.length],
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 0,  // Masquer complètement le titre
        ),
      );
    }).toList();

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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.pie_chart_rounded,
                  color: Color(0xFFF9B70D),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Répartition des commandes par agence',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[900],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 300,
            child: PieChart(
              PieChartData(
                sections: sections,
                centerSpaceRadius: 60,
                sectionsSpace: 2,
                pieTouchData: PieTouchData(
                  enabled: true,
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    // Gestion du survol
                  },
                ),
              ),
              swapAnimationDuration: const Duration(milliseconds: 300),
              swapAnimationCurve: Curves.easeInOut,
            ),
          ),
          const SizedBox(height: 20),
          // Informations textuelles en dessous
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total: ${totalCommandes.toInt()} commandes',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 16,
                  runSpacing: 12,
                  children: agences.map((a) {
                    final color = Colors.primaries[agences.indexOf(a) % Colors.primaries.length];
                    final nbCommandes = double.parse(a["nb_commandes"].toString()).toInt();
                    final percentage = (nbCommandes / totalCommandes * 100).toStringAsFixed(1);
                    return _buildLegendItemWithCount(
                      a["code_agence"],
                      nbCommandes,
                      percentage,
                      color,
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItemWithCount(String label, int count, String percentage, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[800],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '$count (${percentage}%)',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyCard(String message) {
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
          message,
          style: TextStyle(fontSize: 15, color: Colors.grey[600]),
        ),
      ),
    );
  }
}