import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/materiel.dart';
import '../models/mvtStockImmo.dart';
import '../models/direction.dart';
import '../services/materielService.dart';
import '../services/directionService.dart';
import '../services/mvtStockImmoService.dart';

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

  List<Materiel> materiels = [];
  List<MvtStockImmo> movements = [];
  List<Direction> directions = [];
  
  Future<void> _loadMateriels() async {
    try {
      final loadedMateriels = await MaterielService().getAllMateriels();
      setState(() {
        materiels = loadedMateriels;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur de chargement des matériels: $e")),
      );
    }
  }
  
  Future<void> _loadMovements() async {
    try {
      final loadedMovements = await MvtStockImmoService().getMouvementsImmo();
      setState(() {
        movements = loadedMovements;
        filteredMovements = List.from(loadedMovements);
        for (var mvt in loadedMovements) {
          print('Mouvement: date=${mvt.dateMouvement}, type=${mvt.typeMouvement}, materiel=${mvt.materiel?.designation}, quantite=${mvt.quantite}, total=${mvt.totalMateriel}');
        }
      });
    } catch (e, stackTrace) {
      print("Erreur de chargement des mouvements: $e\n$stackTrace");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur de chargement des mouvements: $e\n$stackTrace")),
      );
    }
  }
  
  Future<void> _loadDirections() async {
    try {
      final loadedDirections = await DirectionService().getDirections();
      setState(() {
        directions = loadedDirections;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur de chargement des directions: $e")),
      );
    }
  }

  List<MvtStockImmo> filteredMovements = [];

  // Filtres
  String? selectedMaterielFilter;
  String? selectedTypeFilter;
  String? selectedSourceFilter;
  DateTime? dateFromFilter;
  DateTime? dateToFilter;

  @override
  void initState() {
    super.initState();
    _loadMovements();
    _loadMateriels();
    _loadDirections();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
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

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(headerColor),
        headingTextStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        border: TableBorder.all(
          color: Colors.grey[300]!,
          width: 1,
        ),
        columns: const [
          DataColumn(label: Text('Date')),
          DataColumn(label: Text('Type')),
          DataColumn(label: Text('Matériel')),
          DataColumn(label: Text('Quantité')),
          // DataColumn(label: Text('Total')),
          // DataColumn(label: Text('Source/Direction')),
          DataColumn(label: Text('Actions')),
        ],
        rows: filteredMovements.map((movement) {
          final typeColor = movement.typeMouvement == 'entree'
              ? Colors.green[700]
              : redAccent;
          final quantityColor = movement.typeMouvement   == 'entree'
              ? Colors.green[700]
              : redAccent;

          return DataRow(
            cells: [
              DataCell(Text(DateFormat('dd/MM/yyyy').format(movement.dateMouvement ?? DateTime.now()))),
              DataCell(
                Text(
                  movement.typeMouvement ?? '',
                  style: TextStyle(
                    color: typeColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              DataCell(Text(movement.materiel?.designation ?? 'misy ka')),
              DataCell(
                Text(
                  '${movement.typeMouvement == 'entree' ? '+ ' : '- '}${movement.quantite.abs()}',
                  style: TextStyle(
                    color: quantityColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              // DataCell(Text('${NumberFormat.currency(locale: 'fr', symbol: '€').format(movement.totalMateriel ?? 0)}')),
              // DataCell(Text(movement.sourceOrDirection ?? '-')),
              DataCell(
                ElevatedButton(
                  onPressed: () => _showMovementDetails(movement),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    minimumSize: const Size(80, 32),
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
            ],
          );
        }).toList(),
      ),
    );
  }

  void _showCreateMovementDialog() {
    showDialog(
      context: context,
      builder: (context) => CreateMovementImmoDialog(
        materiels: materiels,
        directions: directions,
        onMovementCreated: (newMovement) {
          setState(() {
            movements.add(newMovement);
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
                // _buildDetailRow('Source/Direction:', movement.sourceOrDirection ?? '-'),
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
        // final sourceMatch = selectedSourceFilter == null ||
        //     (movement.sourceOrDirection != null &&
        //      movement.sourceOrDirection!.toLowerCase().contains(selectedSourceFilter!));
        // return materielMatch && typeMatch && sourceMatch;
        return materielMatch && typeMatch;

      }).map((movement) => MvtStockImmo(
        dateMouvement: movement.dateMouvement ?? DateTime.now(),
        typeMouvement: movement.typeMouvement ?? '',
        materiel: movement.materiel,
        quantite: movement.typeMouvement == 'entree'
            ? movement.quantite ?? 0
            : -(movement.quantite ?? 0),
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

// Dialog pour créer un nouveau mouvement d'immobilisation
class CreateMovementImmoDialog extends StatefulWidget {
  final List<Materiel> materiels;
  final List<Direction> directions;
  final Function(MvtStockImmo) onMovementCreated;

  const CreateMovementImmoDialog({
    super.key,
    required this.materiels,
    required this.directions,
    required this.onMovementCreated,
  });

  @override
  State<CreateMovementImmoDialog> createState() => _CreateMovementImmoDialogState();
}

class _CreateMovementImmoDialogState extends State<CreateMovementImmoDialog> {
  static const Color primaryColor = Color(0xFFF9B70D);

  String selectedMovementType = '';
  String? selectedEntreeSource; // 'fond_propre' ou 'subvention'
  Direction? selectedDirection; // Pour les sorties
  String? selectedMaterielId;
  int quantity = 0;
  String comment = '';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('➕ Nouveau mouvement d\'immobilisation'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 800,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildMovementTypeSelection(),
              const SizedBox(height: 16),
              if (selectedMovementType == 'entree') ...[
                _buildEntreeSourceSelection(),
                const SizedBox(height: 16),
              ],
              if (selectedMovementType == 'sortie') ...[
                _buildDirectionSelection(),
                const SizedBox(height: 16),
              ],
              _buildMaterielSelection(),
              const SizedBox(height: 16),
              _buildQuantityInput(),
            ],
          ),
        ),
      ),
      // actions: [
      //   TextButton(
      //     onPressed: () => Navigator.of(context).pop(),
      //     child: const Text('Annuler'),
      //   ),
      //   ElevatedButton(
      //     onPressed: _canCreateMovement() ? _createMovement : null,
      //     style: ElevatedButton.styleFrom(
      //       backgroundColor: primaryColor,
      //     ),
      //     child: const Text(
      //       'Valider',
      //       style: TextStyle(color: Colors.white),
      //     ),
      //   ),
      // ],
    );
  }

  Widget _buildMovementTypeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Type de mouvement',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: RadioListTile<String>(
                title: const Text('📥 Entrée'),
                value: 'entree',
                groupValue: selectedMovementType,
                onChanged: (value) {
                  setState(() {
                    selectedMovementType = value ?? '';
                    selectedDirection = null;
                  });
                },
              ),
            ),
            Expanded(
              child: RadioListTile<String>(
                title: const Text('📤 Sortie'),
                value: 'sortie',
                groupValue: selectedMovementType,
                onChanged: (value) {
                  setState(() {
                    selectedMovementType = value ?? '';
                    selectedEntreeSource = null;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEntreeSourceSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Source de financement',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: RadioListTile<String>(
                title: const Text('💰 Fond Propre'),
                value: 'fond_propre',
                groupValue: selectedEntreeSource,
                onChanged: (value) {
                  setState(() {
                    selectedEntreeSource = value;
                  });
                },
              ),
            ),
            Expanded(
              child: RadioListTile<String>(
                title: const Text('🏛️ Subvention'),
                value: 'subvention',
                groupValue: selectedEntreeSource,
                onChanged: (value) {
                  setState(() {
                    selectedEntreeSource = value;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDirectionSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Direction de destination',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selectedDirection?.nom,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: '-- Choisir une direction --',
          ),
          items: widget.directions.map((direction) => DropdownMenuItem(
                value: direction.nom,
                child: Text(direction.nom),
              )).toList(),
          onChanged: (value) {
            setState(() {
              selectedDirection = widget.directions.firstWhere((d) => d.nom == value);
            });
          },
        ),
      ],
    );
  }

  Widget _buildMaterielSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Matériel',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selectedMaterielId,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: '-- Choisir un matériel --',
          ),
          items: widget.materiels.map((materiel) => DropdownMenuItem(
                value: materiel.idMateriel.toString(),
                child: Text('${materiel.designation} (${materiel.code})'),
              )).toList(),
          onChanged: (value) {
            setState(() {
              selectedMaterielId = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildQuantityInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quantité',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextFormField(
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: '0',
          ),
          onChanged: (value) {
            setState(() {
              quantity = int.tryParse(value) ?? 0;
            });
          },
        ),
      ],
    );
  }

  bool _canCreateMovement() {
    if (selectedMaterielId == null || quantity <= 0) {
      return false;
    }

    if (selectedMovementType == 'entree') {
      return selectedEntreeSource != null;
    } else if (selectedMovementType == 'sortie') {
      return selectedDirection != null;
    }

    return false;
  }

  // void _createMovement() async {
  //   if (!_canCreateMovement()) return;

  //   // Vérification qu'un matériel est bien sélectionné
  //   if (selectedMaterielId == null) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text("Veuillez sélectionner un matériel")),
  //     );
  //     return;
  //   }

  //   // Vérification que la liste n'est pas vide
  //   if (widget.materiels.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text("Aucun matériel disponible")),
  //     );
  //     return;
  //   }

  //   // Recherche du matériel
  //   final materiel = widget.materiels.firstWhere(
  //     (m) => m.idMateriel.toString() == selectedMaterielId,
  //     orElse: () => Materiel(
  //       idMateriel: 0,
  //       designation: '',
  //       code: '',
  //     ),
  //   );

  //   if (materiel.idMateriel == 0) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text("Matériel introuvable")),
  //     );
  //     return;
  //   }

  //   try {
  //     final mvtStockImmoService = MvtStockImmoService();
      
  //     String sourceOrDirection = '';
  //     if (selectedMovementType == 'entree') {
  //       sourceOrDirection = selectedEntreeSource == 'fond_propre' ? 'Fond Propre' : 'Subvention';
  //     } else {
  //       sourceOrDirection = selectedDirection?.nom ?? '';
  //     }

  //     // Créer l'objet MvtStockImmo selon la vraie structure
  //     final mvtStockImmo = MvtStockImmo(
  //       idMateriel: materiel.idMateriel,
  //       quantite: quantity.toDouble(),
  //       materiel: materiel,
  //     );

  //     final success = await mvtStockImmoService.createMouvement(
  //       mvtStockImmo: mvtStockImmo,
  //       type: selectedMovementType,
  //       sourceOrDirection: sourceOrDirection,
  //     );

  //     if (success) {
  //       // Créer un objet d'affichage pour la table
  //       final movementDisplay = MovementDisplay(
  //         dateMvt: DateTime.now(),
  //         type: selectedMovementType,
  //         materielNom: materiel.designation ?? '',
  //         quantite: selectedMovementType == 'entree' ? quantity.toDouble() : -quantity.toDouble(),
  //         totalMateriel: mvtStockImmo.totalMateriel,
  //         sourceOrDirection: sourceOrDirection,
  //       );

  //       widget.onMovementCreated(movementDisplay);
  //       Navigator.of(context).pop();

  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text("Mouvement créé avec succès")),
  //       );
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text("Échec de la création du mouvement")),
  //       );
  //     }
  //   } catch (e) {
  //     print("Erreur : $e");
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("Erreur : $e")),
  //     );
  //   }
  // }
}

