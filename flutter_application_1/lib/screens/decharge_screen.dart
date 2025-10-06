import 'package:flutter/material.dart';
import '../models/decharge.dart';
import '../services/dechargeService.dart';
import 'dechargeDetails_screen.dart';

void main() {
  runApp(DechargeScreen());
}

class DechargeScreen extends StatefulWidget {
  const DechargeScreen({super.key});

  @override
  State<DechargeScreen> createState() => _DechargeScreenState();
}

class _DechargeScreenState extends State<DechargeScreen> {
  int currentPage = 1;
  int lastPage = 1;
  int itemsPerPage = 10;
  int totalDecharges = 0;

  List<Decharge> decharges = [];
  List<Decharge> filteredDecharges = [];

  // Getter pour obtenir les décharges paginées de la page courante
  List<Decharge> get paginatedDecharges => filteredDecharges;

  // Getter pour le nombre total de pages
  int get totalPages => (decharges.length / itemsPerPage).ceil();

  DateTime? selectedDate;
  String? selectedDirection;

  // Couleurs personnalisées
  final Color buttonColor = const Color(0xFFF9B70D);
  final Color headerRowColor = const Color.fromARGB(154, 131, 130, 129);
  final Color accentColor = Colors.redAccent;

  Future<void> _loadDecharges() async {
    try {
      final service = DechargeService();
      final fetched = await service.getDecharges(page: currentPage, perPage: itemsPerPage);
      setState(() {
        decharges = fetched.data;
        totalDecharges = fetched.total;
        lastPage = fetched.lastPage;
        currentPage = fetched.currentPage;
        filteredDecharges = List.from(decharges);
      });
    } catch (e) {
      print('Erreur lors de la récupération des décharges: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de la récupération des décharges')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadDecharges();
  }

  void _showDechargeDetails(Decharge decharge) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DechargeDetailScreen(
          decharge: decharge,
          buttonColor: buttonColor,
          headerRowColor: headerRowColor,
          accentColor: accentColor,
        ),
      ),
    );
  }

  void _applyFilters() {
    setState(() {
      filteredDecharges = decharges.where((d) {
        bool directionMatch = selectedDirection == null || d.direction == selectedDirection;
        return directionMatch;
      }).toList();
    });
  }

  void _clearFilters() {
    setState(() {
      selectedDate = null;
      selectedDirection = null;
      filteredDecharges = List.from(decharges);
    });
  }

  Widget _buildPaginationControls() {
    if (lastPage <= 1) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.first_page),
          onPressed: currentPage == 1
              ? null
              : () {
                  setState(() => currentPage = 1);
                  _loadDecharges();
                },
        ),
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: currentPage == 1
              ? null
              : () {
                  setState(() => currentPage--);
                  _loadDecharges();
                },
        ),

        // Current page avec background color
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF9B70D),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$currentPage / $lastPage',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),

        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: currentPage >= lastPage
              ? null
              : () {
                  setState(() => currentPage++);
                  _loadDecharges();
                },
        ),
        IconButton(
          icon: const Icon(Icons.last_page),
          onPressed: currentPage >= lastPage
              ? null
              : () {
                  setState(() => currentPage = lastPage);
                  _loadDecharges();
                },
        ),
        const SizedBox(width: 16),
        DropdownButton<int>(
          value: itemsPerPage,
          items: [5, 10, 20, 50].map((value) {
            return DropdownMenuItem<int>(
              value: value,
              child: Text('$value / page'),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                itemsPerPage = value;
                currentPage = 1;
              });
              _loadDecharges();
            }
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Décharges',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Gestion des décharges',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Tableau
            Container(
              width: double.infinity, // Prend toute la largeur
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titre et bouton reset
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Liste des décharges',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _clearFilters,
                        icon: const Icon(Icons.refresh, color: Colors.white, size: 16),
                        label: const Text(
                          'Réinitialiser',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: headerRowColor,
                          minimumSize: const Size(100, 32),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Tableau des décharges - Version responsive
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: constraints.maxWidth,
                          ),
                          child: DataTable(
                            columnSpacing: 20,
                            horizontalMargin: 20,
                            headingRowColor: WidgetStateProperty.all(headerRowColor),
                            headingTextStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 49, 49, 49),
                            ),
                            columns: [
                              // Colonnes avec largeurs proportionnelles
                              DataColumn(
                                label: Expanded(
                                  child: Text(
                                    'Salle',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Expanded(
                                  child: Text(
                                    'Bureau',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Expanded(
                                  child: Text(
                                    'Responsables',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Expanded(
                                  child: Text(
                                    'Direction',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Expanded(
                                  child: Text(
                                    'Matériels',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Expanded(
                                  child: Text(
                                    'Actions',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                            rows: filteredDecharges.map((d) {
                              return DataRow(
                                cells: [
                                  DataCell(
                                    Center(
                                      child: Text(
                                        d.numeroSalle ?? '',
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Center(
                                      child: Text(
                                        d.bureau ?? '',
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Center(
                                      child: Text(
                                        d.responsables.join(', '),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Center(
                                      child: Text(
                                        d.direction ?? '',
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Center(
                                      child: Text(
                                        '${d.materiels.length} matériels',
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Center(
                                      child: ElevatedButton(
                                        onPressed: () => _showDechargeDetails(d),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: buttonColor,
                                          minimumSize: const Size(60, 30),
                                          padding: const EdgeInsets.symmetric(horizontal: 8),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                        ),
                                        child: const Text(
                                          'Voir',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  _buildPaginationControls(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}