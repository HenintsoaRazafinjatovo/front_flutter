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
  List<Decharge> decharges = [];
  List<Decharge> filteredDecharges = [];

  DateTime? selectedDate;
  String? selectedDirection;

  // Couleurs personnalisées
  final Color buttonColor = const Color(0xFFF9B70D);
  final Color headerRowColor = const Color.fromARGB(154, 131, 130, 129);
  final Color accentColor = Colors.redAccent;

  Future<void> _loadDecharges() async {
    try {
      final service = DechargeService();
      List<Decharge> fetched = await service.getDecharges();
      setState(() {
        decharges = fetched;
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

                  // Tableau des décharges
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(headerRowColor),
                      headingTextStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 49, 49, 49),
                      ),
                      columns: const [
                        DataColumn(label: Text('Salle')),
                        DataColumn(label: Text('Bureau')),
                        DataColumn(label: Text('Responsables')),
                        DataColumn(label: Text('Direction')),
                        DataColumn(label: Text('Matériels')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: filteredDecharges.map((d) {
                        return DataRow(
                          cells: [
                            DataCell(Text(d.numeroSalle ?? '')),
                            DataCell(Text(d.bureau ?? '')),
                            DataCell(Text(d.responsables.join(', '))),
                            DataCell(Text(d.direction ?? '')),
                            DataCell(Text('${d.materiels.length} matériels')),
                            DataCell(
                              ElevatedButton(
                                 onPressed: () => _showDechargeDetails(d),
                                // onPressed: () => {},

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
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
