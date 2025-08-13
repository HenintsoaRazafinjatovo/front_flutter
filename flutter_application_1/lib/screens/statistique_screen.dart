import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;

void main() {
  runApp(const StatistiqueScreen());
}

class StatistiqueScreen extends StatelessWidget {
  const StatistiqueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tableau de Bord Statistiques',
      theme: ThemeData(
        primarySwatch:  Colors.amber,
        fontFamily: 'Poppins',
      ),
      home: const DashboardScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Article {
  final String id;
  final String name;
  final int stock;
  final double unitPrice;

  Article({required this.id, required this.name, required this.stock, required this.unitPrice});
}

class Order {
  final int id;
  final String number;
  final String date;
  final String agency;
  final double total;
  final String status;

  Order({required this.id, required this.number, required this.date, required this.agency, required this.total, required this.status});
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({required this.text, required this.isUser, required this.timestamp});
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  bool _showChatbot = false;
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();
  List<ChatMessage> _chatMessages = [];
  bool _isTyping = false;
  DateTime? _predictionDate;
  String? _selectedAgency;

  final List<Article> articles = [
    Article(id: 'ART-001', name: 'PV de stockage', stock: 15, unitPrice: 1200),
    Article(id: 'ART-002', name: 'Fiche de prêt', stock: 25, unitPrice: 25),
    Article(id: 'ART-003', name: 'Carnet de prêt', stock: 8, unitPrice: 300),
    Article(id: 'ART-004', name: 'Acte de cautionnement', stock: 12, unitPrice: 80),
    Article(id: 'ART-005', name: 'Contrat depot a terme', stock: 5, unitPrice: 450),
    Article(id: 'ART-006', name: 'Fanambarana fanonerana', stock: 20, unitPrice: 60),
    Article(id: 'ART-007', name: 'Registre de transmission', stock: 3, unitPrice: 90),
    Article(id: 'ART-008', name: 'Registre de passation', stock: 18, unitPrice: 120),
  ];

  final List<Order> orders = [
    Order(id: 1, number: 'CMD-0001', date: '15/12/2024', agency: 'Agence Aina', total: 2525, status: 'Validée'),
    Order(id: 2, number: 'CMD-0002', date: '14/12/2024', agency: 'Agence Fanavotana', total: 1140, status: 'Livrée'),
    Order(id: 3, number: 'CMD-0003', date: '13/12/2024', agency: 'Agence Vonjy', total: 890, status: 'En cours'),
    Order(id: 4, number: 'CMD-0004', date: '12/12/2024', agency: 'Agence Farimbotsoa', total: 1650, status: 'Validée'),
    Order(id: 5, number: 'CMD-0005', date: '11/12/2024', agency: 'Agence Aina', total: 2100, status: 'Livrée'),
  ];

  final List<String> agencies = [
    'Agence Aina',
    'Agence Fanavotana',
    'Agence Vonjy',
    'Agence Farimbotsoa',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _chatMessages.add(ChatMessage(
      text: '👋 Bonjour ! Je peux vous aider à :\n• Vérifier le stock d\'un article\n• Consulter l\'état d\'une commande\n• Obtenir des informations sur les livraisons\n\nQue souhaitez-vous savoir ?',
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _chatController.dispose();
    _chatScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    body: Container(
      // color: Theme.of(context).scaffoldBackgroundColor,
      color: Color(0xFFF8F9FA),

      // decoration: const BoxDecoration(
      //   // gradient: LinearGradient(
      //   //   begin: Alignment.topLeft,
      //   //   end: Alignment.bottomRight,
      //   //   colors: [Color(0xFFF9FAFB), Color(0xFFF3E8FF)],
      //   // ),
      // ),
      child: SafeArea(
        child: Stack(
          children: [
            TabBarView(
              controller: _tabController,
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildHeader(),
                      _buildDashboardTab(),
                    ],
                  ),
                ),
                SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildHeader(),
                      _buildChartsTab(),
                    ],
                  ),
                ),
                SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildHeader(),
                      _buildPredictionTab(),
                    ],
                  ),
                ),
              ],
            ),
            if (_showChatbot) _buildChatbotDialog(),
          ],
        ),
      ),
    ),
    floatingActionButton: _buildChatbotFAB(),
    floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
  );
}

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tableau de Bord Statistiques',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Vue d\'ensemble des performances et analyses',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          TabBar(
            controller: _tabController,
            // labelColor: const Color(0xFFF9B70D),
            labelColor: Colors.red,

            unselectedLabelColor: Colors.grey[600],
            // indicatorColor: const Color(0xFFF9B70D),
            indicatorColor: Colors.red,

            tabs: const [
              Tab(icon: Icon(Icons.dashboard), text: 'Tableau de bord'),
              Tab(icon: Icon(Icons.bar_chart), text: 'Graphiques'),
              Tab(icon: Icon(Icons.trending_up), text: 'Prédictions'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildKPICards(),
          const SizedBox(height: 24),
          _buildDetailedDashboard(),
        ],
      ),
    );
  }

  Widget _buildKPICards() {
    final totalOrders = orders.length;
    final totalRevenue = orders.fold<double>(0, (sum, order) => sum + order.total);
    final totalArticles = articles.fold<int>(0, (sum, article) => sum + article.stock);
    const totalAgencies = 4;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildKPICard('📦', totalOrders.toString(), 'Commandes totales', const Color.fromARGB(205, 235, 203, 122)),
        _buildKPICard('💰', '${totalRevenue.toStringAsFixed(0)} €', 'Chiffre d\'affaires', const Color.fromARGB(234, 245, 126, 99)),
        _buildKPICard('📋', totalArticles.toString(), 'Articles en stock', const Color.fromARGB(198, 129, 150, 245)),
        _buildKPICard('🏢', totalAgencies.toString(), 'Agences actives', const Color.fromARGB(181, 138, 224, 214)),
      ],
    );
  }

  Widget _buildKPICard(String icon, String value, String label, Color color) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          // ignore: deprecated_member_use
          colors: [color, color.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedDashboard() {
    final pendingOrders = orders.where((order) => order.status == 'En cours').length;
    final successfulDeliveries = orders.where((order) => order.status == 'Livrée').length;
    final lowStockItems = articles.where((article) => article.stock < 10).length;
    final delayedOrders = math.Random().nextInt(3);

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildDetailCard('Commandes en cours', pendingOrders.toString(), 'En traitement', Colors.blue),
        _buildDetailCard('Livraisons réussies', successfulDeliveries.toString(), 'Ce mois', Colors.green),
        _buildDetailCard('Stock faible', lowStockItems.toString(), 'Articles < 10', Colors.orange),
        _buildDetailCard('Retards', delayedOrders.toString(), 'Commandes en retard', Colors.red),
      ],
    );
  }

  Widget _buildDetailCard(String title, String value, String subtitle, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        // ignore: deprecated_member_use
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
             style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildChartsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
           _buildChartCard(' Évolution des commandes', _buildLineChart()),
          const SizedBox(height: 20),
           _buildChartCard('Répartition par agence', _buildPieChart()),
          const SizedBox(height: 20),
           _buildChartCard(' Top articles', _buildBarChart()),
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
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1F2937)),
          ),
          const SizedBox(height: 20),
          SizedBox(height: 250, child: chart),
        ],
      ),
    );
  }

  Widget _buildLineChart() {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const titles = ['11/12', '12/12', '13/12', '14/12', '15/12', '16/12', '17/12'];
                if (value.toInt() >= 0 && value.toInt() < titles.length) {
                  return Text(titles[value.toInt()], style: const TextStyle(fontSize: 10));
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
            spots: const [
              FlSpot(0, 12),
              FlSpot(1, 19),
              FlSpot(2, 15),
              FlSpot(3, 25),
              FlSpot(4, 22),
              FlSpot(5, 18),
              FlSpot(6, 24),
            ],
            isCurved: true,
            color: const Color(0xFFF9B70D),
            barWidth: 3,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              // ignore: deprecated_member_use
              color: const Color(0xFFF9B70D).withOpacity(0.1),
            ),
          ),
        ],
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
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

    Widget _buildPieChart() {
    final sections = [
      PieChartSectionData(value: 35, color: const Color(0xFF7C3AED), radius: 80),
      PieChartSectionData(value: 25, color: const Color(0xFFEC4899), radius: 80),
      PieChartSectionData(value: 20, color: const Color(0xFF10B981), radius: 80),
      PieChartSectionData(value: 20, color: const Color(0xFFF59E0B), radius: 80),
      PieChartSectionData(value: 35, color: const Color.fromARGB(255, 22, 132, 60), radius: 80),
      PieChartSectionData(value: 25, color: const Color.fromARGB(255, 81, 38, 60), radius: 80),
      PieChartSectionData(value: 20, color: const Color.fromARGB(255, 11, 46, 34), radius: 80),
      PieChartSectionData(value: 20, color: const Color.fromARGB(255, 85, 59, 14), radius: 80),
      PieChartSectionData(value: 35, color: const Color.fromARGB(255, 106, 89, 135), radius: 80),
      PieChartSectionData(value: 25, color: const Color.fromARGB(255, 204, 0, 102), radius: 80),
      PieChartSectionData(value: 20, color: const Color.fromARGB(255, 155, 240, 26), radius: 80),
      PieChartSectionData(value: 20, color: const Color.fromARGB(255, 97, 173, 221), radius: 80),
      PieChartSectionData(value: 35, color: const Color.fromARGB(255, 178, 36, 200), radius: 80),
      PieChartSectionData(value: 25, color: const Color.fromARGB(255, 91, 77, 84), radius: 80),
      PieChartSectionData(value: 20, color: const Color.fromARGB(255, 151, 185, 16), radius: 80),
      PieChartSectionData(value: 5, color: const Color.fromARGB(255, 255, 0, 0), radius: 80),
    ];

    final labels = [
      'Aina', 'Vonjy', 'Farimbotsoa', 'Fanavotana',
      'Aina', 'Vonjy', 'Farimbotsoa', 'Fanavotana',
      'Aina', 'Vonjy', 'Farimbotsoa', 'Fanavotana',
      'Aina', 'Vonjy', 'Farimbotsoa', 'Fanavotana',
    ];


    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            height: 300,
            child: PieChart(
                PieChartData(
                  sections: sections,
                  centerSpaceRadius: 60,
                  sectionsSpace: 2,
                ),
              ),
          ),
          const SizedBox(height: 20),
          Wrap(
              spacing: 16,
              runSpacing: 8,
              children: List.generate(labels.length, (index) {
                return _buildLegendItem(labels[index], sections[index].color);
              }),
            ),
        ],
      ),
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
              getTitlesWidget: (value, meta) {
                const titles = ['PV stockage', 'Registre', 'Bordereau', 'Clavier', 'Casque'];
                if (value.toInt() >= 0 && value.toInt() < titles.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(titles[value.toInt()], style: const TextStyle(fontSize: 10)),
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
        barGroups: [
          BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 145, color:  const Color(0xFFF9B70D), width: 50)]),
          BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 32, color:  const Color(0xFFF9B70D), width: 50)]),
          BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 28, color: const Color(0xFFF9B70D), width: 50)]),
          BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 25, color: const Color(0xFFF9B70D), width: 50)]),
          BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 18, color: const Color(0xFFF9B70D), width: 50)]),
        ],
      ),
    );
  }

  Widget _buildPredictionTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  // ignore: deprecated_member_use
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Prédictions de commandes',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Date de prédiction', style: TextStyle(fontWeight: FontWeight.w500)),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now().add(const Duration(days: 1)),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(const Duration(days: 730)),
                              );
                              if (date != null) {
                                setState(() {
                                  _predictionDate = date;
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today, size: 16),
                                  const SizedBox(width: 8),
                                  Text(
                                    _predictionDate?.toString().substring(0, 10) ?? 'Sélectionner une date',
                                    style: TextStyle(color: _predictionDate != null ? Colors.black : Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Agence', style: TextStyle(fontWeight: FontWeight.w500)),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: _selectedAgency,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            ),
                            hint: const Text('Toutes les agences'),
                            items: agencies.map((agency) {
                              return DropdownMenuItem(value: agency, child: Text(agency));
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedAgency = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _generatePrediction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF9B70D),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text(' Prédire', style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _generatePrediction() {
    if (_predictionDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner une date')),
      );
      return;
    }

    final isWeekend = _predictionDate!.weekday == DateTime.saturday || _predictionDate!.weekday == DateTime.sunday;
    final basePrediction = isWeekend ? 5 : 15;
    
    final agencyMultipliers = {
      'Agence Aina': 1.5,
      'Agence Farimbotsoa': 1.2,
      'Agence Vonjy': 0.8,
      'Agence Fanavotana': 1.0,
    };
    
    final multiplier = _selectedAgency != null ? (agencyMultipliers[_selectedAgency] ?? 1.0) : 1.0;
    final predictedOrders = (basePrediction * multiplier).round();
    final confidence = 75 + math.Random().nextInt(20);
    final predictedRevenue = predictedOrders * (800 + math.Random().nextDouble() * 400);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🔮 Prédiction générée'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date: ${_predictionDate!.toString().substring(0, 10)}'),
            if (_selectedAgency != null) Text('Agence: $_selectedAgency'),
            const SizedBox(height: 16),
            Text('Commandes prédites: $predictedOrders'),
            Text('Confiance: $confidence%'),
            Text('CA estimé: ${predictedRevenue.toStringAsFixed(0)} €'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildChatbotFAB() {
    return FloatingActionButton(
      onPressed: () {
        setState(() {
          _showChatbot = !_showChatbot;
        });
      },
      backgroundColor: const Color(0xFFF9B70D),
      child: const Text('🤖', style: TextStyle(fontSize: 24)),
    );
  }

  Widget _buildChatbotDialog() {
    return Positioned(
      bottom: 90,
      right: 16,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 350,
          height: 500,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFF9B70D),
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    const Text('🤖', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    const Text('Assistant Logistique', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => setState(() => _showChatbot = false),
                      child: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: _chatScrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _chatMessages.length + (_isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _chatMessages.length && _isTyping) {
                      return _buildTypingIndicator();
                    }
                    final message = _chatMessages[index];
                    return _buildChatMessage(message);
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.grey[300]!)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _chatController,
                        decoration: InputDecoration(
                          hintText: 'Tapez votre question...',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _sendMessage,
                      icon: const Icon(Icons.send),
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFFF9B70D),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatMessage(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: message.isUser ? const Color(0xFFF9B70D) : Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: message.isUser ? Colors.white : Colors.black87,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🤖', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            ...List.generate(3, (index) => Container(
              margin: EdgeInsets.only(right: index < 2 ? 4 : 0),
              child: const TypingDot(),
            )),
          ],
        ),
      ),
    );
  }

  void _sendMessage() {
    final text = _chatController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _chatMessages.add(ChatMessage(text: text, isUser: true, timestamp: DateTime.now()));
      _isTyping = true;
    });

    _chatController.clear();
    _scrollToBottom();

    // Simuler une réponse du bot
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isTyping = false;
        _chatMessages.add(ChatMessage(
          text: _generateBotResponse(text),
          isUser: false,
          timestamp: DateTime.now(),
        ));
      });
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_chatScrollController.hasClients) {
        _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _generateBotResponse(String userMessage) {
    final message = userMessage.toLowerCase();

    // Recherche de stock
    if (message.contains('stock') || message.contains('quantité')) {
      final articleKeywords = {
        'pv de stock': 'ART-001',
        'fiche': 'ART-002',
        'carnet': 'ART-003',
        'acte': 'ART-004',
        'contrat': 'ART-005',
        'fanambarana': 'ART-006',
        'registre': 'ART-007',
      };

      for (final entry in articleKeywords.entries) {
        if (message.contains(entry.key)) {
          final article = articles.firstWhere((a) => a.id == entry.value, orElse: () => articles.first);
          final stockStatus = article.stock < 5 
              ? '⚠️ Stock faible' 
              : article.stock < 10 
                  ? '⚡ Stock modéré' 
                  : '✅ Stock suffisant';
          return '${article.name}\nStock actuel: ${article.stock} unités\nStatut: $stockStatus\nPrix unitaire: ${article.unitPrice} €';
        }
      }

      return 'Voici le stock actuel de nos principaux articles:\n\n${articles.take(4).map((a) => '• ${a.name}: ${a.stock} unités').join('\n')}\n\nPrécisez un article pour plus de détails !';
    }

    // Recherche de commande
    if (message.contains('commande') || message.contains('cmd')) {
      final cmdPattern = RegExp(r'cmd-\d+', caseSensitive: false);
      final match = cmdPattern.firstMatch(message);
      
      if (match != null) {
        final orderNumber = match.group(0)!.toUpperCase();
        final order = orders.firstWhere(
          (o) => o.number == orderNumber,
          orElse: () => Order(id: 0, number: '', date: '', agency: '', total: 0, status: ''),
        );
        
        if (order.id != 0) {
          final statusEmoji = {
            'Validée': '✅',
            'En cours': '⏳',
            'Livrée': '🚚',
            'Annulée': '❌'
          };
          return 'Commande ${order.number}\nDate: ${order.date}\nAgence: ${order.agency}\nMontant: ${order.total} €\nStatut: ${statusEmoji[order.status]} ${order.status}';
        } else {
          return '❌ Commande $orderNumber non trouvée. Vérifiez le numéro.';
        }
      }

      return 'Voici les dernières commandes:\n\n${orders.take(3).map((o) => '• ${o.number} - ${o.agency} (${o.status})').join('\n')}\n\nPrécisez un numéro (ex: CMD-0001) pour plus de détails !';
    }

    // Informations générales
    if (message.contains('aide') || message.contains('help')) {
      return '🤖 Je peux vous aider avec:\n\n📦 Stock: "Quel est le stock des PV ?"\n📋 Commandes: "État de la commande CMD-0001"\n🚚 Livraisons: "Statut des livraisons"\n📊 Statistiques: "Résumé du jour"\n\nPosez-moi votre question !';
    }

    if (message.contains('livraison') || message.contains('transport')) {
      final deliveredOrders = orders.where((o) => o.status == 'Livrée').length;
      final pendingOrders = orders.where((o) => o.status == 'En cours').length;
      return 'État des livraisons:\n\n✅ Livrées: $deliveredOrders\n⏳ En cours: $pendingOrders\n📦 Total commandes: ${orders.length}\n\nTaux de livraison: ${((deliveredOrders / orders.length) * 100).round()}%';
    }

    if (message.contains('résumé') || message.contains('statistique') || message.contains('bilan')) {
      final totalRevenue = orders.fold<double>(0, (sum, order) => sum + order.total);
      final lowStock = articles.where((a) => a.stock < 10).length;
      return 'Résumé du jour:\n\n📦 Commandes: ${orders.length}\n💰 CA: ${totalRevenue.toStringAsFixed(0)} €\n⚠️ Articles en stock faible: $lowStock\n🏢 Agences actives: 4\n\nTout semble bien fonctionner ! 👍';
    }

    // Réponse par défaut
    return '🤔 Je n\'ai pas bien compris votre demande. Essayez:\n\n• "Stock des PV"\n• "État commande CMD-0001"\n• "Résumé du jour"\n• "Aide" pour plus d\'options';
  }
}

class TypingDot extends StatefulWidget {
  const TypingDot({super.key});

  @override
  State<TypingDot> createState() => _TypingDotState();
}

class _TypingDotState extends State<TypingDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}