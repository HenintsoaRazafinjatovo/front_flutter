import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

import '../services/statistiqueService.dart';
class StatistiqueImmoScreen extends StatefulWidget {
  @override
  _StatistiqueImmoScreenState createState() => _StatistiqueImmoScreenState();
}

class _StatistiqueImmoScreenState extends State<StatistiqueImmoScreen> {
  // Couleurs définies
  static const Color buttonColor = Color(0xFFF9B70D);
  static const Color headerRowColor = Color.fromARGB(154, 131, 130, 129);
  static const Color accentColor = Colors.redAccent;
  
  // Service simulé pour les données
  List<Map<String, dynamic>> mouvementsParSemaine = [];
  List<Map<String, dynamic>> stockParNature = [];
  List<Map<String, dynamic>> stockTurnover = [];
  bool isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  List<Color> generateUniqueColors(int count) {
  final random = Random();
  final List<Color> colors = [];

  while (colors.length < count) {
    final color = Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
    // éviter les doublons
    if (!colors.contains(color)) {
      colors.add(color);
    }
  }
  return colors;
}

  // Simulation du service
  // Future<void> _loadData() async {
  //   await Future.delayed(Duration(milliseconds: 500)); // Simulation délai réseau
  //   final mvt = await StatistiqueService().getMouvementsParSemaineImmo(9, 2025);
  //   final stock = await StatistiqueService().getStockParNature();
  //   final turnover = await StatistiqueService().getStockTurnover();

  //   setState(() {
  //     mouvementsParSemaine = List<Map<String, dynamic>>.from(mvt);
  //     stockParNature = List<Map<String, dynamic>>.from(stock);
  //     stockTurnover = List<Map<String, dynamic>>.from(turnover);
  //     isLoading = false;
  //   });
  // }
  Future<void> _loadData() async {
  await Future.delayed(Duration(milliseconds: 500)); // Simulation délai réseau

  final mvt = await StatistiqueService().getMouvementsParSemaineImmo(9, 2025);
  final stock = await StatistiqueService().getStockParNature();
  final turnover = await StatistiqueService().getStockTurnover();

  setState(() {
    mouvementsParSemaine = List<Map<String, dynamic>>.from(mvt);
    stockParNature = List<Map<String, dynamic>>.from(stock);

    // ⚡ Conversion correcte des valeurs turnover en double
    stockTurnover = (turnover as List).map((e) {
      return {
        'id_nature': e['id_nature'],
        'description': e['description'],
        'turnover': (e['turnover'] is int)
            ? (e['turnover'] as int).toDouble()
            : e['turnover'] as double,
      };
    }).toList();

    isLoading = false;
  });
}

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
       backgroundColor: const Color.fromARGB(255, 253, 253, 253),
        title: Text(
          'Statistiques Immobilisations',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: buttonColor))
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _buildMouvementsChart()),
                      SizedBox(width: 16),
                      Expanded(child: _buildRepartitionStockChart(stockParNature)),
                    ],
                  ),
                  SizedBox(height: 24),
                  _buildStockTurnoverChart(),
                ],
              ),
            ),
    );
  }
  
  // Premier graphique: Mouvements par semaine
  Widget _buildMouvementsChart() {
    return Card(
      elevation: 4,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mouvements par Semaine - Septembre 2025',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 16),
            Container(
              height: 250,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 60,
                  minY: -60,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (touchedSpot) => headerRowColor,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        String type = rodIndex == 0 ? 'Entrées' : 'Sorties';
                        return BarTooltipItem(
                          '$type\n${rod.toY.toStringAsFixed(0)}',
                          TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          if (value.toInt() < mouvementsParSemaine.length) {
                            return Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: Text(
                                mouvementsParSemaine[value.toInt()]['semaine'],
                                style: TextStyle(fontSize: 10, color: Colors.black54),
                              ),
                            );
                          }
                          return Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                    ),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: mouvementsParSemaine.asMap().entries.map((entry) {
                    int index = entry.key;
                    var data = entry.value;
                    double entrees = double.parse(data['total_entrees']);
                    double sorties = double.parse(data['total_sorties']);
                    
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: entrees,
                          color: buttonColor,
                          width: 12,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        BarChartRodData(
                          toY: -sorties, // Négatif pour inverser les barres
                          color: accentColor,
                          width: 12,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                      barsSpace: 4,
                    );
                  }).toList(),
                ),
              ),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem('Entrées', buttonColor),
                SizedBox(width: 20),
                _buildLegendItem('Sorties', accentColor),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  // Deuxième graphique: Stock Turnover
  // Widget _buildStockTurnoverChart() {
  //   List<Map<String, dynamic>> turnoverData = [
  //     {'categorie': 'Mobilier', 'turnover': 2.3},
  //     {'categorie': 'Informatique', 'turnover': 4.1},
  //     {'categorie': 'Véhicules', 'turnover': 1.8},
  //     {'categorie': 'Équipements', 'turnover': 3.2},
  //     {'categorie': 'Immobilier', 'turnover': 0.5},
  //   ];
    
  //   return Card(
  //     elevation: 4,
  //     color: Colors.white,
  //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  //     child: Padding(
  //       padding: EdgeInsets.all(16.0),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Text(
  //             'Rotation des Stocks par Catégorie',
  //             style: TextStyle(
  //               fontSize: 18,
  //               fontWeight: FontWeight.bold,
  //               color: Colors.black87,
  //             ),
  //           ),
  //           SizedBox(height: 16),
  //           Container(
  //             height: 250,
  //             child: LineChart(
  //               LineChartData(
  //                 gridData: FlGridData(show: true),
  //                 titlesData: FlTitlesData(
  //                   show: true,
  //                   bottomTitles: AxisTitles(
  //                     sideTitles: SideTitles(
  //                       showTitles: true,
  //                       getTitlesWidget: (double value, TitleMeta meta) {
  //                         if (value.toInt() < turnoverData.length) {
  //                           return Padding(
  //                             padding: EdgeInsets.only(top: 8),
  //                             child: Text(
  //                               turnoverData[value.toInt()]['categorie'],
  //                               style: TextStyle(fontSize: 10, color: Colors.black54),
  //                               textAlign: TextAlign.center,
  //                             ),
  //                           );
  //                         }
  //                         return Text('');
  //                       },
  //                     ),
  //                   ),
  //                   leftTitles: AxisTitles(
  //                     sideTitles: SideTitles(showTitles: true, reservedSize: 40),
  //                   ),
  //                   topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
  //                   rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
  //                 ),
  //                 borderData: FlBorderData(show: true, border: Border.all(color: headerRowColor)),
  //                 minX: 0,
  //                 maxX: (turnoverData.length - 1).toDouble(),
  //                 minY: 0,
  //                 maxY: 5,
  //                 lineBarsData: [
  //                   LineChartBarData(
  //                     spots: turnoverData.asMap().entries.map((entry) {
  //                       return FlSpot(entry.key.toDouble(), entry.value['turnover']);
  //                     }).toList(),
  //                     isCurved: true,
  //                     color: buttonColor,
  //                     barWidth: 3,
  //                     isStrokeCapRound: true,
  //                     dotData: FlDotData(
  //                       show: true,
  //                       getDotPainter: (spot, percent, barData, index) =>
  //                           FlDotCirclePainter(
  //                         radius: 4,
  //                         color: accentColor,
  //                         strokeWidth: 2,
  //                         strokeColor: Colors.white,
  //                       ),
  //                     ),
  //                     belowBarData: BarAreaData(
  //                       show: true,
  //                       color: buttonColor.withOpacity(0.3),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
  // List<Map<String, dynamic>> turnoverData = [
    //   {'categorie': 'Mobilier', 'turnover': 2.3},
    //   {'categorie': 'Informatique', 'turnover': 4.1},
    //   {'categorie': 'Véhicules', 'turnover': 1.8},
    //   {'categorie': 'Équipements', 'turnover': 3.2},
    //   {'categorie': 'Immobilier', 'turnover': 0.5},
    // ];
  Widget _buildStockTurnoverChart() {
    
    List<Map<String, dynamic>> turnoverData = List.from(stockTurnover);

    // Ajouter des points fictifs si nécessaire
    while (turnoverData.length < 3) {
      turnoverData.add({
        'id_nature': 0,
        'description': 'Autre',
        'turnover': 0.0,
      });
    }
    
  return Card(
    elevation: 4,
    color: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rotation des Stocks par Catégorie',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16),
          Container(
            height: 300,
            child: RadarChart(
              RadarChartData(
                dataSets: [
                  RadarDataSet(
                    dataEntries: turnoverData.map((data) {
                      return RadarEntry(value: data['turnover']);
                    }).toList(),
                    fillColor: buttonColor.withOpacity(0.3),
                    borderColor: buttonColor,
                    borderWidth: 2,
                    entryRadius: 4,
                  ),
                ],
                radarBackgroundColor: Colors.transparent,
                borderData: FlBorderData(show: false),
                radarBorderData: BorderSide(color: Colors.grey.shade300, width: 1),
                titlePositionPercentageOffset: 0.2,
                titleTextStyle: TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                getTitle: (index, angle) {
                  if (index < turnoverData.length) {
                    return RadarChartTitle(
                      text: turnoverData[index]['description'],
                      angle: angle,
                    );
                  }
                  return RadarChartTitle(text: '');
                },
                tickCount: 5,
                ticksTextStyle: TextStyle(
                  color: Colors.black45,
                  fontSize: 10,
                ),
                tickBorderData: BorderSide(color: Colors.grey.shade300, width: 1),
                gridBorderData: BorderSide(color: Colors.grey.shade200, width: 1),
              ),
            ),
          ),
          SizedBox(height: 8),
          // Légende pour expliquer les valeurs
          Wrap(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: buttonColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Valeurs de rotation (fois par an)',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.black54,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
  Widget _buildRepartitionStockChart(List<Map<String, dynamic>> stockParNature) {
  // Attribution de couleurs aléatoires (uniques) si pas déjà fait
  final colors = generateUniqueColors(stockParNature.length);
  for (int i = 0; i < stockParNature.length; i++) {
    stockParNature[i]['color'] = colors[i];
  }

  return Card(
    elevation: 4,
    color: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Répartition du Stock par Nature',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16),
          Container(
            height: 250,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: stockParNature.map((data) {
                  return PieChartSectionData(
                    color: data['color'],
                    value: (data['total_stock'] as num).toDouble(),
                    title:
                        '${(data['total_stock'] as num).toStringAsFixed(0)}',
                    radius: 80,
                    titleStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: stockParNature.map((data) {
              return _buildLegendItem(data['description'], data['color']);
            }).toList(),
          ),
        ],
      ),
    ),
  );
}

  
  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}