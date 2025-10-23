// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import '../models/materiel.dart';
// import '../models/mvtStockImmo.dart';
// import '../models/direction.dart';
// import '../models/salle.dart';
// import '../services/materielService.dart';
// import '../services/directionService.dart';
// import '../services/mvtStockImmoService.dart';
// import '../services/salleService.dart';
// import 'create_movement_immo_dialog.dart';

// class MouvementStockImmoScreen extends StatefulWidget {
//   const MouvementStockImmoScreen({super.key});

//   @override
//   State<MouvementStockImmoScreen> createState() => _MouvementStockImmoScreenState();
// }

// class _MouvementStockImmoScreenState extends State<MouvementStockImmoScreen> {
//   // Couleurs définies
//   static const Color primaryColor = Color(0xFFF9B70D);
//   static const Color headerColor = Color.fromARGB(154, 131, 130, 129);
//   static const Color backgroundColor = Colors.white;
//   static const Color redAccent = Color(0xFFE53E3E);

//   int currentPage = 1;
//   int lastPage = 1;
//   int itemsPerPage = 10;
//   int totalMouvements = 0;

//   List<Materiel> materiels = [];
//   List<MvtStockImmo> movements = [];
//   List<Direction> directions = [];
//   List<MvtStockImmo> filteredMovements = [];
//   List<Salle> salles = [];

//  // Getter pour obtenir les mouvements paginés de la page courante
//   List<MvtStockImmo> get paginatedMovements => movements;

//   // Getter pour le nombre total de pages
//   int get totalPages => (movements.length / itemsPerPage).ceil();
//   // Filtres
//   String? selectedMaterielFilter;
//   String? selectedTypeFilter;
//   String? selectedSourceFilter;
//   DateTime? dateFromFilter;
//   DateTime? dateToFilter;

//   @override
//   void initState() {
//     super.initState();
//     _loadData();
//   }

//   Future<void> _loadData() async {
//     await Future.wait([
//       _loadMovements(),
//       _loadMateriels(),
//       _loadDirections(),
//       _loadSalles(),
//     ]);
//   }

//   Future<void> _loadMateriels() async {
//     try {
//       final loadedMateriels = await MaterielService().getAllMaterielsList();
//       setState(() {
//         materiels = loadedMateriels;
//       });
//     } catch (e) {
//       _showErrorSnackBar("Erreur de chargement des matériels: $e");
//     }
//   }
//   Future<void> _loadSalles() async {
//     try {
//       final loadedSalles = await SalleService().getSalles();
//       setState(() {
//         salles = loadedSalles;
//       });
      
//     } catch (e) {
//       print("Erreur de chargement des salles: $e");
//       _showErrorSnackBar("Erreur de chargement des salles: $e");
//     }
//   }
//   Future<void> _loadMovements() async {
//     try {
//       final loadedMovements = await MvtStockImmoService().getMouvementsImmo(page: currentPage, perPage: itemsPerPage);
//       setState(() {
//         movements = loadedMovements.data;
//         totalMouvements = loadedMovements.total;
//         lastPage = loadedMovements.lastPage;
//         currentPage = loadedMovements.currentPage;
//         filteredMovements = List.from(loadedMovements.data);
//       });
//     } catch (e, stackTrace) {
//       print("Erreur de chargement des mouvements: $e\n$stackTrace");
//       _showErrorSnackBar("Erreur de chargement des mouvements: $e");
//     }
//   }
  
//   Future<void> _loadDirections() async {
//     try {
//       final loadedDirections = await DirectionService().getDirections();
//       setState(() {
//         directions = loadedDirections;
//       });
//     } catch (e) {
//       _showErrorSnackBar("Erreur de chargement des directions: $e");
//     }
//   }

//   void _showErrorSnackBar(String message) {
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(message)),
//       );
//     }
//   }
// Widget _buildPaginationControls() {
//   if (lastPage <= 1) return const SizedBox.shrink();

//   return Row(
//     mainAxisAlignment: MainAxisAlignment.center,
//     children: [
//       IconButton(
//         icon: const Icon(Icons.first_page),
//         onPressed: currentPage == 1
//             ? null
//             : () {
//                 setState(() => currentPage = 1);
//                 _loadMovements();
//               },
//       ),
//       IconButton(
//         icon: const Icon(Icons.chevron_left),
//         onPressed: currentPage == 1
//             ? null
//             : () {
//                 setState(() => currentPage--);
//                 _loadMovements();
//               },
//       ),

//       // Current page avec background color
//       Container(
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//         decoration: BoxDecoration(
//           color: const Color(0xFFF9B70D),
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Text(
//           '$currentPage / $lastPage',
//           style: const TextStyle(
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//       ),

//       IconButton(
//         icon: const Icon(Icons.chevron_right),
//         onPressed: currentPage >= lastPage
//             ? null
//             : () {
//                 setState(() => currentPage++);
//                 _loadMovements();
//               },
//       ),
//       IconButton(
//         icon: const Icon(Icons.last_page),
//         onPressed: currentPage >= lastPage
//             ? null
//             : () {
//                 setState(() => currentPage = lastPage);
//                 _loadMovements();
//               },
//       ),
//       const SizedBox(width: 16),
//       DropdownButton<int>(
//         value: itemsPerPage,
//         items: [5, 10, 20, 50].map((value) {
//           return DropdownMenuItem<int>(
//             value: value,
//             child: Text('$value / page'),
//           );
//         }).toList(),
//         onChanged: (value) {
//           if (value != null) {
//             setState(() {
//               itemsPerPage = value;
//               currentPage = 1;
//             });
//             _loadMovements();
//           }
//         },
//       ),
//     ],
//   );
// }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8F9FA),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildHeader(),
//             const SizedBox(height: 20),
//             _buildHistorySection(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildHeader() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         color: backgroundColor,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           const Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Gestion des mouvements de stock immobilisation',
//                 style: TextStyle(
//                   color: Color.fromARGB(255, 3, 3, 3),
//                   fontSize: 25,
//                   fontWeight: FontWeight.bold,
//                   fontFamily: 'Poppins',
//                 ),
//               ),
//             ],
//           ),
//           ElevatedButton.icon(
//             onPressed: () => _showCreateMovementDialog(),
//             icon: const Icon(Icons.add, color: Colors.white),
//             label: const Text(
//               'Nouveau Mouvement',
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//               ),
//             ),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: primaryColor,
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               elevation: 4,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildHistorySection() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         color: backgroundColor,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Historique des mouvements d\'immobilisation',
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.w600,
//               color: Colors.black87,
//             ),
//           ),
//           const SizedBox(height: 24),
//           _buildFilters(),
//           const SizedBox(height: 24),
//           _buildMovementsTable(),
//           _buildPaginationControls(),
//         ],
//       ),
//     );
//   }

//   Widget _buildFilters() {
//     return Wrap(
//       spacing: 16,
//       runSpacing: 16,
//       children: [
//         SizedBox(
//           width: 400,
//           child: DropdownButtonFormField<String>(
//             value: selectedMaterielFilter,
//             decoration: const InputDecoration(
//               labelText: 'Tous les matériels',
//               border: OutlineInputBorder(),
//               contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//             ),
//             items: [
//               const DropdownMenuItem(value: null, child: Text('Tous les matériels')),
//               ...materiels.map((materiel) => DropdownMenuItem(
//                     value: materiel.designation,
//                     child: Text(materiel.designation ?? ''),
//                   )),
//             ],
//             onChanged: (value) {
//               setState(() {
//                 selectedMaterielFilter = value;
//                 _applyFilters();
//               });
//             },
//           ),
//         ),
//         SizedBox(
//           width: 180,
//           child: DropdownButtonFormField<String>(
//             value: selectedTypeFilter,
//             decoration: const InputDecoration(
//               labelText: 'Tous les types',
//               border: OutlineInputBorder(),
//               contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//             ),
//             items: const [
//               DropdownMenuItem(value: null, child: Text('Tous les types')),
//               DropdownMenuItem(value: 'entree', child: Text('Entrée')),
//               DropdownMenuItem(value: 'sortie', child: Text('Sortie')),
//             ],
//             onChanged: (value) {
//               setState(() {
//                 selectedTypeFilter = value;
//                 _applyFilters();
//               });
//             },
//           ),
//         ),
//         SizedBox(
//           width: 200,
//           child: DropdownButtonFormField<String>(
//             value: selectedSourceFilter,
//             decoration: const InputDecoration(
//               labelText: 'Source/Destination',
//               border: OutlineInputBorder(),
//               contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//             ),
//             items: const [
//               DropdownMenuItem(value: null, child: Text('Toutes')),
//               DropdownMenuItem(value: 'fond_propre', child: Text('Fond Propre')),
//               DropdownMenuItem(value: 'subvention', child: Text('Subvention')),
//             ],
//             onChanged: (value) {
//               setState(() {
//                 selectedSourceFilter = value;
//                 _applyFilters();
//               });
//             },
//           ),
//         ),
//         // Boutons
//         Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             ElevatedButton.icon(
//               onPressed: _applyFilters,
//               icon: const Icon(Icons.search, color: Colors.white),
//               label: const Text(
//                 'Filtrer',
//                 style: TextStyle(color: Colors.white),
//               ),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: primaryColor,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//             ),
//             const SizedBox(width: 12),
//             ElevatedButton.icon(
//               onPressed: _clearFilters,
//               icon: const Icon(Icons.refresh, color: Colors.white),
//               label: const Text(
//                 'Réinitialiser',
//                 style: TextStyle(color: Colors.white),
//               ),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.grey[600],
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildMovementsTable() {
//     if (filteredMovements.isEmpty) {
//       return Container(
//         height: 200,
//         alignment: Alignment.center,
//         child: const Text(
//           'Aucun mouvement trouvé',
//           style: TextStyle(
//             color: Colors.grey,
//             fontSize: 16,
//           ),
//         ),
//       );
//     }

//     return SingleChildScrollView(
//       scrollDirection: Axis.horizontal,
//       child: DataTable(
//         headingRowColor: WidgetStateProperty.all(headerColor),
//         headingTextStyle: const TextStyle(
//           fontWeight: FontWeight.w600,
//           color: Colors.black87,
//         ),
//         border: TableBorder.all(
//           color: Colors.grey[300]!,
//           width: 1,
//         ),
//         columns: const [
//           DataColumn(label: Text('Date')),
//           DataColumn(label: Text('Type')),
//           DataColumn(label: Text('Matériel')),
//           DataColumn(label: Text('Quantité')),
//           DataColumn(label: Text('Actions')),
//         ],
//         rows: filteredMovements.map((movement) {
//           final typeColor = movement.typeMouvement == 'entree'
//               ? Colors.green[700]
//               : redAccent;
//           final quantityColor = movement.typeMouvement == 'entree'
//               ? Colors.green[700]
//               : redAccent;

//           return DataRow(
//             cells: [
//               DataCell(Text(DateFormat('dd/MM/yyyy').format(movement.dateMouvement ?? DateTime.now()))),
//               DataCell(
//                 Text(
//                   movement.typeMouvement ?? '',
//                   style: TextStyle(
//                     color: typeColor,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//               DataCell(Text(movement.materiel?.designation ?? 'Non défini')),
//               DataCell(
//                 Text(
//                   '${movement.typeMouvement == 'entree' ? '+ ' : '- '}${movement.quantite.abs()}',
//                   style: TextStyle(
//                     color: quantityColor,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//               DataCell(
//                 ElevatedButton(
//                   onPressed: () => _showMovementDetails(movement),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: primaryColor,
//                     minimumSize: const Size(80, 32),
//                   ),
//                   child: const Text(
//                     'Détails',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 12,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           );
//         }).toList(),
//       ),
//     );
//   }

//   void _showCreateMovementDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => CreateMovementImmoDialog(
//         materiels: materiels,
//         directions: directions,
//         salles: salles,
//         onMovementCreated: (newMovement) {
//           setState(() {
//             movements.add(newMovement as MvtStockImmo);
//             filteredMovements = List.from(movements);
//           });
//         },
//       ),
//     );
//   }

//   void _showMovementDetails(MvtStockImmo movement) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Détails du mouvement'),
//         content: SizedBox(
//           width: 600,
//           height: 300,
//           child: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 _buildDetailRow('Date:', DateFormat('dd/MM/yyyy').format(movement.dateMouvement ?? DateTime.now())),
//                 _buildDetailRow('Type:', movement.typeMouvement ?? ''),
//                 _buildDetailRow('Matériel:', movement.materiel?.designation ?? '-'),
//                 _buildDetailRow(
//                   'Quantité:',
//                   '${movement.typeMouvement == 'entree' ? '+' : '-'}${movement.quantite.abs()}',
//                 ),
//                 _buildDetailRow('Total:', '${NumberFormat.currency(locale: 'fr', symbol: '€').format(movement.totalMateriel ?? 0)}'),
//               ],
//             ),
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: const Text('Fermer'),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDetailRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 120,
//             child: Text(
//               label,
//               style: const TextStyle(
//                 fontWeight: FontWeight.w600,
//                 color: Colors.black87,
//               ),
//             ),
//           ),
//           Expanded(
//             child: Text(
//               value,
//               style: const TextStyle(color: Colors.black54),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _applyFilters() {
//     setState(() {
//       filteredMovements = movements.where((movement) {
//         final materielMatch = selectedMaterielFilter == null ||
//             (movement.materiel != null &&
//              (movement.materiel!.designation ?? '').contains(selectedMaterielFilter!));
//         final typeMatch = selectedTypeFilter == null ||
//             (movement.typeMouvement != null && movement.typeMouvement == selectedTypeFilter);
        
//         return materielMatch && typeMatch;

//       }).map((movement) => MvtStockImmo(
//         dateMouvement: movement.dateMouvement ?? DateTime.now(),
//         typeMouvement: movement.typeMouvement ?? '',
//         materiel: movement.materiel,
//         quantite: movement.typeMouvement == 'entree'
//             ? movement.quantite ?? 0
//             : -(movement.quantite ?? 0),
//         totalMateriel: movement.totalMateriel,
//       )).toList();
//     });
//   }

//   void _clearFilters() {
//     setState(() {
//       selectedMaterielFilter = null;
//       selectedTypeFilter = null;
//       selectedSourceFilter = null;
//       dateFromFilter = null;
//       dateToFilter = null;
//       filteredMovements = List.from(movements);
//     });
//   }
// }
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/materiel.dart';
import '../models/mvtStockImmo.dart';
import '../models/direction.dart';
import '../models/salle.dart';
import '../services/materielService.dart';
import '../services/directionService.dart';
import '../services/mvtStockImmoService.dart';
import '../services/salleService.dart';
import 'create_movement_immo_dialog.dart';

class MouvementStockImmoScreen extends StatefulWidget {
  const MouvementStockImmoScreen({super.key});

  @override
  State<MouvementStockImmoScreen> createState() => _MouvementStockImmoScreenState();
}

class _MouvementStockImmoScreenState extends State<MouvementStockImmoScreen> {
  // Couleurs définies
  static const Color primaryColor = Color(0xFFF9B70D);
  static const Color headerColor = Color.fromARGB(154, 131, 130, 129);
  static const Color backgroundColor = Colors.white;
  static const Color redAccent = Color(0xFFE53E3E);

  int currentPage = 1;
  int lastPage = 1;
  int itemsPerPage = 10;
  int totalMouvements = 0;

  List<Materiel> materiels = [];
  List<MvtStockImmo> movements = [];
  List<Direction> directions = [];
  List<MvtStockImmo> filteredMovements = [];
  List<Salle> salles = [];

  // Getter pour obtenir les mouvements paginés de la page courante
  List<MvtStockImmo> get paginatedMovements => movements;

  // Getter pour le nombre total de pages
  int get totalPages => (movements.length / itemsPerPage).ceil();
  // Filtres
  String? selectedMaterielFilter;
  String? selectedTypeFilter;
  String? selectedSourceFilter;
  DateTime? dateFromFilter;
  DateTime? dateToFilter;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadMovements(),
      _loadMateriels(),
      _loadDirections(),
      _loadSalles(),
    ]);
  }

  Future<void> _loadMateriels() async {
    try {
      final loadedMateriels = await MaterielService().getAllMaterielsList();
      setState(() {
        materiels = loadedMateriels;
      });
    } catch (e) {
      _showErrorSnackBar("Erreur de chargement des matériels: $e");
    }
  }
  
  Future<void> _loadSalles() async {
    try {
      final loadedSalles = await SalleService().getSalles();
      setState(() {
        salles = loadedSalles;
      });
      
    } catch (e) {
      print("Erreur de chargement des salles: $e");
      _showErrorSnackBar("Erreur de chargement des salles: $e");
    }
  }
  
  Future<void> _loadMovements() async {
    try {
      final loadedMovements = await MvtStockImmoService().getMouvementsImmo(page: currentPage, perPage: itemsPerPage);
      setState(() {
        movements = loadedMovements.data;
        totalMouvements = loadedMovements.total;
        lastPage = loadedMovements.lastPage;
        currentPage = loadedMovements.currentPage;
        filteredMovements = List.from(loadedMovements.data);
      });
    } catch (e, stackTrace) {
      print("Erreur de chargement des mouvements: $e\n$stackTrace");
      _showErrorSnackBar("Erreur de chargement des mouvements: $e");
    }
  }
  
  Future<void> _loadDirections() async {
    try {
      final loadedDirections = await DirectionService().getDirections();
      setState(() {
        directions = loadedDirections;
      });
    } catch (e) {
      _showErrorSnackBar("Erreur de chargement des directions: $e");
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
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
                  _loadMovements();
                },
        ),
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: currentPage == 1
              ? null
              : () {
                  setState(() => currentPage--);
                  _loadMovements();
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
                  _loadMovements();
                },
        ),
        IconButton(
          icon: const Icon(Icons.last_page),
          onPressed: currentPage >= lastPage
              ? null
              : () {
                  setState(() => currentPage = lastPage);
                  _loadMovements();
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
              _loadMovements();
            }
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildHistorySection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Gestion des mouvements de stock immobilisation',
                style: TextStyle(
                  color: Color.fromARGB(255, 3, 3, 3),
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
          ElevatedButton.icon(
            onPressed: () => _showCreateMovementDialog(),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              'Nouveau Mouvement',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: backgroundColor,
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
        mainAxisSize: MainAxisSize.min, // ← CHANGEMENT IMPORTANT ICI
        children: [
          const Text(
            'Historique des mouvements d\'immobilisation',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
          _buildFilters(),
          const SizedBox(height: 24),
          _buildMovementsTable(),
          const SizedBox(height: 16),
          _buildPaginationControls(),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        SizedBox(
          width: 400,
          child: DropdownButtonFormField<String>(
            value: selectedMaterielFilter,
            decoration: const InputDecoration(
              labelText: 'Tous les matériels',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            items: [
              const DropdownMenuItem(value: null, child: Text('Tous les matériels')),
              ...materiels.map((materiel) => DropdownMenuItem(
                    value: materiel.designation,
                    child: Text(materiel.designation ?? ''),
                  )),
            ],
            onChanged: (value) {
              setState(() {
                selectedMaterielFilter = value;
                _applyFilters();
              });
            },
          ),
        ),
        SizedBox(
          width: 180,
          child: DropdownButtonFormField<String>(
            value: selectedTypeFilter,
            decoration: const InputDecoration(
              labelText: 'Tous les types',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            items: const [
              DropdownMenuItem(value: null, child: Text('Tous les types')),
              DropdownMenuItem(value: 'entree', child: Text('Entrée')),
              DropdownMenuItem(value: 'sortie', child: Text('Sortie')),
            ],
            onChanged: (value) {
              setState(() {
                selectedTypeFilter = value;
                _applyFilters();
              });
            },
          ),
        ),
        SizedBox(
          width: 200,
          child: DropdownButtonFormField<String>(
            value: selectedSourceFilter,
            decoration: const InputDecoration(
              labelText: 'Source/Destination',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            items: const [
              DropdownMenuItem(value: null, child: Text('Toutes')),
              DropdownMenuItem(value: 'fond_propre', child: Text('Fond Propre')),
              DropdownMenuItem(value: 'subvention', child: Text('Subvention')),
            ],
            onChanged: (value) {
              setState(() {
                selectedSourceFilter = value;
                _applyFilters();
              });
            },
          ),
        ),
        // Boutons
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              onPressed: _applyFilters,
              icon: const Icon(Icons.search, color: Colors.white),
              label: const Text(
                'Filtrer',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: _clearFilters,
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text(
                'Réinitialiser',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[600],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMovementsTable() {
    if (filteredMovements.isEmpty) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        child: const Text(
          'Aucun mouvement trouvé',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 16,
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(4),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: MediaQuery.of(context).size.width - 350, // Largeur moins les paddings
          ),
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(headerColor),
            headingTextStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            dataRowMinHeight: 50,
            dataRowMaxHeight: 60,
            horizontalMargin: 16,
            columnSpacing: 0,
            dividerThickness: 1,
            border: TableBorder.all(
              color: Colors.grey[300]!,
              width: 1,
            ),
            columns: [
              DataColumn(
                label: _buildHeaderCell('Date'),
              ),
              DataColumn(
                label: _buildHeaderCell('Type'),
              ),
              DataColumn(
                label: _buildHeaderCell('Matériel'),
              ),
              DataColumn(
                label: _buildHeaderCell('Quantité'),
              ),
              DataColumn(
                label: _buildHeaderCell('Actions'),
              ),
            ],
            rows: filteredMovements.map((movement) {
              final typeColor = movement.typeMouvement == 'entree'
                  ? Colors.green[700]
                  : redAccent;
              final quantityColor = movement.typeMouvement == 'entree'
                  ? Colors.green[700]
                  : redAccent;

              return DataRow(
                cells: [
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        DateFormat('dd/MM/yyyy').format(movement.dateMouvement ?? DateTime.now()),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        movement.typeMouvement ?? '',
                        style: TextStyle(
                          color: typeColor,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        movement.materiel?.designation ?? 'Non défini',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        '${movement.typeMouvement == 'entree' ? '+ ' : '- '}${movement.quantite.abs()}',
                        style: TextStyle(
                          color: quantityColor,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ElevatedButton(
                        onPressed: () => _showMovementDetails(movement),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          minimumSize: const Size(80, 32),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        child: const Text(
                          'Détails',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  void _showCreateMovementDialog() {
    showDialog(
      context: context,
      builder: (context) => CreateMovementImmoDialog(
        materiels: materiels,
        directions: directions,
        salles: salles,
        onMovementCreated: (newMovement) {
          setState(() {
            movements.add(newMovement as MvtStockImmo);
            filteredMovements = List.from(movements);
          });
        },
      ),
    );
  }

  void _showMovementDetails(MvtStockImmo movement) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Détails du mouvement'),
        content: SizedBox(
          width: 600,
          height: 300,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow('Date:', DateFormat('dd/MM/yyyy').format(movement.dateMouvement ?? DateTime.now())),
                _buildDetailRow('Type:', movement.typeMouvement ?? ''),
                _buildDetailRow('Matériel:', movement.materiel?.designation ?? '-'),
                _buildDetailRow(
                  'Quantité:',
                  '${movement.typeMouvement == 'entree' ? '+' : '-'}${movement.quantite.abs()}',
                ),
                _buildDetailRow('Total:', '${NumberFormat.currency(locale: 'fr', symbol: '€').format(movement.totalMateriel ?? 0)}'),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  void _applyFilters() {
    setState(() {
      filteredMovements = movements.where((movement) {
        final materielMatch = selectedMaterielFilter == null ||
            (movement.materiel != null &&
             (movement.materiel!.designation ?? '').contains(selectedMaterielFilter!));
        final typeMatch = selectedTypeFilter == null ||
            (movement.typeMouvement != null && movement.typeMouvement == selectedTypeFilter);
        
        return materielMatch && typeMatch;

      }).map((movement) => MvtStockImmo(
        dateMouvement: movement.dateMouvement ?? DateTime.now(),
        typeMouvement: movement.typeMouvement ?? '',
        materiel: movement.materiel,
        quantite: movement.typeMouvement == 'entree'
            ? movement.quantite
            : -(movement.quantite ),
        totalMateriel: movement.totalMateriel,
      )).toList();
    });
  }

  void _clearFilters() {
    setState(() {
      selectedMaterielFilter = null;
      selectedTypeFilter = null;
      selectedSourceFilter = null;
      dateFromFilter = null;
      dateToFilter = null;
      filteredMovements = List.from(movements);
    });
  }
}