import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/statistiqueService.dart';

class StatistiqueMouvement extends StatefulWidget {
  const StatistiqueMouvement({super.key});

  @override
  _StatistiqueMouvementState createState() => _StatistiqueMouvementState();
}

class _StatistiqueMouvementState extends State<StatistiqueMouvement> {
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
      Map<String, dynamic> stats = await service.buildPageMouvement();
      // print("Statistiques des mouvements: $stats");
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderStats(),
          const SizedBox(height: 24),
          _buildChartsSection(),
        ],
      ),
    );
  }

  // ------------------- Header Stats -------------------
  Widget _buildHeaderStats() {
    final statMouvement = _stats?['stat_mouvement'] ?? {};
    final mouvements = statMouvement['nb_mouvements_du_mois'] ?? {'sorties': 0, 'entrees': 0};
    final entrees = mouvements['entrees'] ?? 0;
    final sorties = mouvements['sorties'] ?? 0;
    final ecart = statMouvement['ecart_mouvements'] ?? 0;
    final totalMouvements = entrees + sorties;

    const primaryColor = Color(0xFFF9B70D);
    const accentColor = Color(0xFFB28704);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color.fromARGB(255, 244, 209, 123),
            const Color.fromARGB(255, 244, 209, 123).withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Statistiques des mouvements',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  Icons.arrow_downward_rounded,
                  entrees.toString(),
                  'Entrées',
                  Colors.green.shade600,
                ),
              ),
              Container(
                width: 1,
                height: 60,
                color: Colors.white30,
              ),
              Expanded(
                child: _buildStatItem(
                  Icons.arrow_upward_rounded,
                  sorties.toString(),
                  'Sorties',
                  Colors.red.shade600,
                ),
              ),
              Container(
                width: 1,
                height: 60,
                color: Colors.white30,
              ),
              Expanded(
                child: _buildStatItem(
                  Icons.swap_vert_rounded,
                  totalMouvements.toString(),
                  'Total',
                  Colors.white,
                ),
              ),
              Container(
                width: 1,
                height: 60,
                color: Colors.white30,
              ),
              Expanded(
                child: _buildStatItem(
                  ecart >= 0 ? Icons.trending_up : Icons.trending_down,
                  ecart.toString(),
                  'Écart',
                  ecart >= 0 ? Colors.green.shade600 : Colors.red.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  // ------------------- Charts Section -------------------
  Widget _buildChartsSection() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: _buildHistoriqueChart(),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: _buildTop5ArticlesChart(),
            ),
          ],
        ),
      ],
    );
  }
// Widget _buildHistoriqueChart() {
//   final historique = _stats?['historique_mouvements'] as List<dynamic>? ?? [];

//   if (historique.isEmpty) {
//     return _buildEmptyChart('Aucun historique disponible');
//   }

//   final int totalSemaines = historique.length;

//   // On limite le nombre de labels visibles pour éviter la répétition
//   final int step = (totalSemaines / 6).ceil(); // max 6 labels visibles

//   return Container(
//     padding: const EdgeInsets.all(20),
//     decoration: BoxDecoration(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(16),
//       boxShadow: [
//         BoxShadow(
//           color: Colors.grey.withOpacity(0.1),
//           blurRadius: 8,
//           offset: const Offset(0, 2),
//         ),
//       ],
//     ),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             const Icon(Icons.show_chart_rounded, color: Color(0xFFF9B70D), size: 24),
//             const SizedBox(width: 8),
//             const Text(
//               'Historique des mouvements',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//                 color: Color(0xFF333333),
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 8),
//         Text(
//           'Évolution hebdomadaire du mois',
//           style: TextStyle(
//             fontSize: 12,
//             color: Colors.grey[600],
//           ),
//         ),
//         const SizedBox(height: 24),

//         /// --- GRAPHIQUE ---
//         SizedBox(
//           height: 280,
//           child: LineChart(
//             LineChartData(
//               minX: 0,
//               maxX: (totalSemaines - 1).toDouble(),
//               gridData: FlGridData(
//                 show: true,
//                 drawVerticalLine: false,
//                 horizontalInterval: 50,
//                 getDrawingHorizontalLine: (value) => FlLine(
//                   color: Colors.grey.shade200,
//                   strokeWidth: 1,
//                 ),
//               ),
//               titlesData: FlTitlesData(
//                 leftTitles: AxisTitles(
//                   sideTitles: SideTitles(
//                     showTitles: true,
//                     reservedSize: 40,
//                     getTitlesWidget: (value, meta) => Text(
//                       value.toInt().toString(),
//                       style: TextStyle(
//                         color: Colors.grey[600],
//                         fontSize: 11,
//                       ),
//                     ),
//                   ),
//                 ),
//                 bottomTitles: AxisTitles(
//                   sideTitles: SideTitles(
//                     showTitles: true,
//                     reservedSize: 32,
//                     getTitlesWidget: (value, meta) {
//                       final index = value.toInt();
//                       // Affiche seulement quelques labels espacés
//                       if (index % step == 0 && index >= 0 && index < historique.length) {
//                         return Padding(
//                           padding: const EdgeInsets.only(top: 8),
//                           child: Text(
//                             historique[index]['semaine'] ?? '',
//                             style: TextStyle(
//                               color: Colors.grey[600],
//                               fontSize: 10,
//                             ),
//                           ),
//                         );
//                       }
//                       return const SizedBox.shrink();
//                     },
//                   ),
//                 ),
//                 rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                 topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//               ),
//               borderData: FlBorderData(show: false),

//               /// --- COURBES ---
//               lineBarsData: [
//                 // Entrées
//                 LineChartBarData(
//                   spots: [
//                     for (int i = 0; i < totalSemaines; i++)
//                       FlSpot(
//                         i.toDouble(),
//                         double.tryParse(historique[i]['total_entrees']?.toString() ?? '0') ?? 0,
//                       )
//                   ],
//                   isCurved: true,
//                   color: Colors.green.shade600,
//                   barWidth: 3,
//                   dotData: FlDotData(show: true),
//                   belowBarData: BarAreaData(
//                     show: true,
//                     color: Colors.green.shade600.withOpacity(0.1),
//                   ),
//                 ),
//                 // Sorties
//                 LineChartBarData(
//                   spots: [
//                     for (int i = 0; i < totalSemaines; i++)
//                       FlSpot(
//                         i.toDouble(),
//                         double.tryParse(historique[i]['total_sorties']?.toString() ?? '0') ?? 0,
//                       )
//                   ],
//                   isCurved: true,
//                   color: Colors.red.shade600,
//                   barWidth: 3,
//                   dotData: FlDotData(show: true),
//                   belowBarData: BarAreaData(
//                     show: true,
//                     color: Colors.red.shade600.withOpacity(0.1),
//                   ),
//                 ),
//               ],

//               /// --- INTERACTIONS ---
//               lineTouchData: LineTouchData(
//                 touchTooltipData: LineTouchTooltipData(
//                   getTooltipColor: (_) => Colors.grey.shade800,
//                   getTooltipItems: (touchedSpots) => touchedSpots.map((spot) {
//                     final isEntree = spot.barIndex == 0;
//                     return LineTooltipItem(
//                       '${isEntree ? 'Entrées' : 'Sorties'}\n${spot.y.toInt()}',
//                       const TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 12,
//                       ),
//                     );
//                   }).toList(),
//                 ),
//               ),
//             ),
//           ),
//         ),

//         const SizedBox(height: 16),

//         /// --- LÉGENDE ---
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             _buildLegendItem(Colors.green.shade600, 'Entrées'),
//             const SizedBox(width: 24),
//             _buildLegendItem(Colors.red.shade600, 'Sorties'),
//           ],
//         ),
//       ],
//     ),
//   );
// }
Widget _buildHistoriqueChart() {
  final historique = _stats?['historique_mouvements'] as List<dynamic>? ?? [];

  if (historique.isEmpty) {
    return _buildEmptyChart('Aucun historique disponible');
  }

  final int totalSemaines = historique.length;

  // On choisit le maximum de labels à afficher (5 pour une bonne lisibilité)
  const maxLabels = 5;
  final interval = (totalSemaines / maxLabels).ceil();

  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
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
          children: [
            const Icon(Icons.show_chart_rounded, color: Color(0xFFF9B70D), size: 24),
            const SizedBox(width: 8),
            const Text(
              'Historique des mouvements',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Évolution hebdomadaire du mois',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 24),

        /// --- GRAPHIQUE ---
        SizedBox(
          height: 280,
          child: LineChart(
            LineChartData(
              minX: 0,
              maxX: (totalSemaines - 1).toDouble(),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 50,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: Colors.grey.shade200,
                  strokeWidth: 1,
                ),
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) => Text(
                      value.toInt().toString(),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 32,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      // On affiche un label tous les 'interval' indices
                      if (index % interval == 0 && index >= 0 && index < historique.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            historique[index]['semaine'] ?? '',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 10,
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),

              /// --- COURBES ---
              lineBarsData: [
                // Entrées
                LineChartBarData(
                  spots: [
                    for (int i = 0; i < totalSemaines; i++)
                      FlSpot(
                        i.toDouble(),
                        double.tryParse(historique[i]['total_entrees']?.toString() ?? '0') ?? 0,
                      )
                  ],
                  isCurved: true,
                  color: Colors.green.shade600,
                  barWidth: 3,
                  dotData: FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.green.shade600.withOpacity(0.1),
                  ),
                ),
                // Sorties
                LineChartBarData(
                  spots: [
                    for (int i = 0; i < totalSemaines; i++)
                      FlSpot(
                        i.toDouble(),
                        double.tryParse(historique[i]['total_sorties']?.toString() ?? '0') ?? 0,
                      )
                  ],
                  isCurved: true,
                  color: Colors.red.shade600,
                  barWidth: 3,
                  dotData: FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.red.shade600.withOpacity(0.1),
                  ),
                ),
              ],

              /// --- INTERACTIONS ---
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => Colors.grey.shade800,
                  getTooltipItems: (touchedSpots) => touchedSpots.map((spot) {
                    final isEntree = spot.barIndex == 0;
                    return LineTooltipItem(
                      '${isEntree ? 'Entrées' : 'Sorties'}\n${spot.y.toInt()}',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        /// --- LÉGENDE ---
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem(Colors.green.shade600, 'Entrées'),
            const SizedBox(width: 24),
            _buildLegendItem(Colors.red.shade600, 'Sorties'),
          ],
        ),
      ],
    ),
  );
}


  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ------------------- Top 5 Articles (Bar Chart) -------------------
  Widget _buildTop5ArticlesChart() {
    final top5 = _stats?['top_5_articles'] as List<dynamic>? ?? [];

    if (top5.isEmpty) {
      return _buildEmptyChart('Aucun article disponible');
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
            children: [
              Icon(Icons.bar_chart_rounded, color: const Color(0xFFF9B70D), size: 24),
              const SizedBox(width: 8),
              const Text(
                'Top 5 articles',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Articles les plus mouvementés',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 280,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (top5.isNotEmpty
                        ? double.tryParse(top5[0]['total_quantite']?.toString() ?? '0')
                        : 100) ??
                    100,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) => Colors.grey.shade800,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${top5[groupIndex]['intitule']}\n${rod.toY.toInt()}',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < top5.length) {
                          final intitule = top5[index]['intitule'] ?? '';
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              intitule.length > 8 ? '${intitule.substring(0, 8)}...' : intitule,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 10,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 11,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 100,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.shade200,
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
                barGroups: top5.asMap().entries.map((entry) {
                  final quantite = double.tryParse(entry.value['total_quantite']?.toString() ?? '0') ?? 0;
                  final colors = [
                    const Color(0xFFF9B70D),
                    const Color(0xFFB28704),
                    Colors.orange.shade700,
                    Colors.amber.shade700,
                    Colors.yellow.shade700,
                  ];
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: quantite,
                        color: colors[entry.key % colors.length],
                        width: 24,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
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

  Widget _buildEmptyChart(String message) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          message,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ),
    );
  }
}