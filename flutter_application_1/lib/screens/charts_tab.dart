// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';
// import '../services/statistiqueService.dart';

// class ChartsTab extends StatefulWidget {
//   const ChartsTab({super.key});

//   @override
//   State<ChartsTab> createState() => _ChartsTabState();
// }

// class _ChartsTabState extends State<ChartsTab> {
//   List<dynamic> evolution = [];
//   List<dynamic> agences = [];
//   List<dynamic> topArticles = [];

//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadData();
//   }

//   Future<void> _loadData() async {
//     final evo = await StatistiqueService().getEvolutionCommandes(2025);
//     final ag = await StatistiqueService().getCommandesParAgence(2025);
//     final top = await StatistiqueService().getTop5Articles(2025);

//     setState(() {
//       evolution = evo;
//       agences = ag;
//       topArticles = top;
//       isLoading = false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (isLoading) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         children: [
//           _buildChartCard('Évolution des commandes', _buildLineChart()),
//           const SizedBox(height: 20),
//           _buildChartCard('Répartition par agence', _buildPieChart()),
//           const SizedBox(height: 20),
//           _buildChartCard('Top articles', _buildBarChart()),
//         ],
//       ),
//     );
//   }

//   Widget _buildChartCard(String title, Widget chart) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1F2937))),
//           const SizedBox(height: 20),
//           SizedBox(height: 400, child: chart),
//         ],
//       ),
//     );
//   }
// Widget _buildLineChart() {
//   // Liste des mois
//   const moisLabels = [
//     'Janv', 'Févr', 'Mars', 'Avr', 'Mai', 'Juin',
//     'Juil', 'Août', 'Sept', 'Oct', 'Nov', 'Déc'
//   ];

//   return LineChart(
//     LineChartData(
//       gridData: FlGridData(show: false),
//       titlesData: FlTitlesData(
//         leftTitles: AxisTitles(
//           sideTitles: SideTitles(
//             showTitles: true,
//             reservedSize: 40,
//           ),
//         ),
//         bottomTitles: AxisTitles(
//           sideTitles: SideTitles(
//             showTitles: true,
//             interval: 1, // ✅ Un seul label par mois
//             getTitlesWidget: (value, _) {
//               int index = value.toInt();
//               if (index >= 0 && index < moisLabels.length) {
//                 return Text(
//                   moisLabels[index],
//                   style: const TextStyle(fontSize: 10),
//                 );
//               }
//               return const Text('');
//             },
//           ),
//         ),
//         rightTitles: const AxisTitles(
//           sideTitles: SideTitles(showTitles: false),
//         ),
//         topTitles: const AxisTitles(
//           sideTitles: SideTitles(showTitles: false),
//         ),
//       ),
//       borderData: FlBorderData(show: false),
//       lineBarsData: [
//         LineChartBarData(
//           spots: List.generate(
//             evolution.length,
//             (i) => FlSpot(
//               (int.parse(evolution[i]["mois"].toString()) - 1).toDouble(),
//               double.parse(evolution[i]["nb_commandes"].toString()),
//             ),
//           ),
//           isCurved: true,
//           color: const Color(0xFFF9B70D),
//           barWidth: 3,
//           dotData: FlDotData(show: true),
//           belowBarData: BarAreaData(
//             show: true,
//             color: const Color(0xFFF9B70D).withOpacity(0.1),
//           ),
//         ),
//       ],
//     ),
//   );
// }


//   /// ---- RÉPARTITION PAR AGENCE (PIE CHART) ----
//   Widget _buildPieChart() {
//     final sections = agences.map((a) {
//       final value = double.parse(a["nb_commandes"].toString()); // ✅ conversion
//       return PieChartSectionData(
//         value: value,
//         title: "${a["code_agence"]}",
//         color: Colors.primaries[agences.indexOf(a) % Colors.primaries.length],
//         radius: 80,
//       );
//     }).toList();

//     return Column(
//       children: [
//         SizedBox(height: 300, child: PieChart(PieChartData(sections: sections, centerSpaceRadius: 60, sectionsSpace: 2))),
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
//     );
//   }

//   Widget _buildLegendItem(String label, Color color) {
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
//         const SizedBox(width: 6),
//         Text(label, style: const TextStyle(fontSize: 14)),
//       ],
//     );
//   }

//   /// ---- TOP ARTICLES (BAR CHART) ----
//   Widget _buildBarChart() {
//     return BarChart(
//       BarChartData(
//         alignment: BarChartAlignment.spaceAround,
//         gridData: FlGridData(show: false),
//         titlesData: FlTitlesData(
//           leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
//           bottomTitles: AxisTitles(
//             sideTitles: SideTitles(
//               showTitles: true,
//               getTitlesWidget: (value, _) {
//                 if (value.toInt() >= 0 && value.toInt() < topArticles.length) {
//                   return Padding(
//                     padding: const EdgeInsets.only(top: 8),
//                     child: Text(
//                       topArticles[value.toInt()]["intitule"].toString(),
//                       style: const TextStyle(fontSize: 10),
//                     ),
//                   );
//                 }
//                 return const Text('');
//               },
//             ),
//           ),
//           rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//           topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//         ),
//         borderData: FlBorderData(show: false),
//         barGroups: List.generate(
//           topArticles.length,
//           (i) => BarChartGroupData(
//             x: i,
//             barRods: [
//               BarChartRodData(
//                 toY: double.parse(topArticles[i]["total_quantite"].toString()), // ✅ conversion
//                 color: const Color(0xFFF9B70D),
//                 width: 30,
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/statistiqueService.dart';

class ChartsTab extends StatefulWidget {
  const ChartsTab({super.key});

  @override
  State<ChartsTab> createState() => _ChartsTabState();
}

class _ChartsTabState extends State<ChartsTab> {
  List<dynamic> evolution = [];
  List<dynamic> agences = [];
  List<dynamic> topArticles = [];

  bool isLoading = true;
  int selectedYear = 2025; // Année par défaut
  final List<int> availableYears = [2023, 2024, 2025, 2026]; // Liste d'années disponibles

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
    });

    final evo = await StatistiqueService().getEvolutionCommandes(selectedYear);
    final ag = await StatistiqueService().getCommandesParAgence(selectedYear);
    final top = await StatistiqueService().getTop5Articles(selectedYear);

    setState(() {
      evolution = evo;
      agences = ag;
      topArticles = top;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.calendar_today, color: Color(0xFFF9B70D)),
                  const SizedBox(width: 8),
                  const Text(
                    "Année :",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF1F2937)),
                  ),
                  const SizedBox(width: 12),
                  DropdownButton<int>(
                    value: selectedYear,
                    underline: const SizedBox(), // enlève le trait par défaut
                    items: availableYears
                        .map((year) => DropdownMenuItem(
                              value: year,
                              child: Text(
                                year.toString(),
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                            ))
                        .toList(),
                    onChanged: (year) {
                      if (year != null) {
                        setState(() {
                          selectedYear = year;
                        });
                        _loadData();
                      }
                    },
                  ),
                ],
              ),
            ),

          const SizedBox(height: 20),
          _buildChartCard('Évolution des commandes', _buildLineChart()),
          const SizedBox(height: 20),
          _buildChartCard('Répartition par agence', _buildPieChart()),
          const SizedBox(height: 20),
          _buildChartCard('Top articles', _buildBarChart()),
        ],
      ),
    );
  }

  Widget _buildChartCard(String title, Widget chart) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1F2937))),
          const SizedBox(height: 20),
          SizedBox(height: 400, child: chart),
        ],
      ),
    );
  }

  Widget _buildLineChart() {
    const moisLabels = [
      'Janv', 'Févr', 'Mars', 'Avr', 'Mai', 'Juin',
      'Juil', 'Août', 'Sept', 'Oct', 'Nov', 'Déc'
    ];

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, _) {
                int index = value.toInt();
                if (index >= 0 && index < moisLabels.length) {
                  return Text(moisLabels[index], style: const TextStyle(fontSize: 10));
                }
                return const Text('');
              },
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(
              evolution.length,
              (i) => FlSpot(
                (int.parse(evolution[i]["mois"].toString()) - 1).toDouble(),
                double.parse(evolution[i]["nb_commandes"].toString()),
              ),
            ),
            isCurved: true,
            color: const Color(0xFFF9B70D),
            barWidth: 3,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(show: true, color: const Color(0xFFF9B70D).withOpacity(0.1)),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart() {
    final sections = agences.map((a) {
      final value = double.parse(a["nb_commandes"].toString());
      return PieChartSectionData(
        value: value,
        title: "${a["code_agence"]}",
        color: Colors.primaries[agences.indexOf(a) % Colors.primaries.length],
        radius: 80,
      );
    }).toList();

    return Column(
      children: [
        SizedBox(height: 300, child: PieChart(PieChartData(sections: sections, centerSpaceRadius: 60, sectionsSpace: 2))),
        const SizedBox(height: 20),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: agences.map((a) {
            final color = Colors.primaries[agences.indexOf(a) % Colors.primaries.length];
            return _buildLegendItem(a["code_agence"], color);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget _buildBarChart() {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                if (value.toInt() >= 0 && value.toInt() < topArticles.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      topArticles[value.toInt()]["intitule"].toString(),
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(
          topArticles.length,
          (i) => BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: double.parse(topArticles[i]["total_quantite"].toString()),
                color: const Color(0xFFF9B70D),
                width: 30,
              )
            ],
          ),
        ),
      ),
    );
  }
}
