import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/materiel.dart' show Materiel;
import '../models/inventaire_materiel.dart' show InventaireMateriel;
import '../models/inventaire.dart' show Inventaire;
import '../models/employe.dart' show Employe;
import '../services/materielService.dart';
import '../services/employeService.dart';
import '../services/inventaireService.dart';
import '../models/inventaireImmo.dart' show InventaireImmo;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventaire immobilisations',
      theme: ThemeData(
        fontFamily: 'Poppins',
        primarySwatch: Colors.orange,
      ),
      home: InventoryImmoManagementScreen(),
    );
  }
}

class InventoryImmoManagementScreen extends StatefulWidget {
  @override
  _InventoryImmoManagementScreenState createState() =>
      _InventoryImmoManagementScreenState();
}

class _InventoryImmoManagementScreenState extends State<InventoryImmoManagementScreen> {
  DateTime selectedDate = DateTime.now();
  List<Employe> selectedEmployees = [];
  List<Materiel> selectedMateriels = [];
  List<InventaireImmo> inventoryData = [];
  List<Employe> employees = [];
  List<Materiel> filteredMateriels = [];
  List<Materiel> materiels = [];
  //  Timer? _debounce;

  bool showInventoryForm = false;
  Future<void> _loadMateriels() async {
    try {
      final loadedMateriels = await MaterielService().getAllMateriels();
      setState(() {
        materiels = loadedMateriels;
        filteredMateriels = loadedMateriels;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur de chargement des matériels: $e")),
      );
    }
  }
  Future<void> _loadEmployes() async {
    try {
      final loadedEmployes = await EmployeService().getEmployes();
      setState(() {
        employees = loadedEmployes;
      });
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur de chargement des employés: $e")),
      );
    }
  }
  Future<void> _loadInventory() async {
    try {
      final loadedInventory = await InventaireService().getAllInventairesImmoWithDetails();
      setState(() {
        inventoryData = loadedInventory;
      });
    } catch (e) {
      // ignore: use_build_context_synchronously
      print("Erreur de chargement des inventaires: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur de chargement des inventaires: $e")),
      );
    }
  }

  Map<int, TextEditingController> physicalStockControllers = {};
  Map<int, double> physicalStocks = {};

  @override
  void initState() {
    super.initState();
    _loadMateriels();
    _loadEmployes();
    _loadInventory();
  }

  @override
  void dispose() {
    physicalStockControllers.values.forEach((controller) {
      controller.dispose();
    });
    super.dispose();
  }

  void startInventory() {
    if (selectedEmployees.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez sélectionner au moins un employé')),
      );
      return;
    }
    if (selectedMateriels.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez sélectionner au moins un matériel')),
      );
      return;
    }

    setState(() {
      showInventoryForm = true;
      physicalStocks.clear();
      selectedMateriels.forEach((materiel) {
        if (materiel.idMateriel != null) {
          physicalStockControllers[materiel.idMateriel!]?.clear();
        }
      });
    });
  }

  void saveInventory() async {
  try {
    List<InventaireMateriel> inventaireMateriels = [];

    // Construire la liste des matériels d'inventaire
    for (var materiel in selectedMateriels) {
      if (materiel.idMateriel != null) {
        double physicalStock = double.tryParse(
              physicalStocks[materiel.idMateriel!]?.toString() ?? '0',
            ) ??
            0;
        double theoreticalStock = 1; // Valeur par défaut pour un matériel (généralement 1)
        double ecart = physicalStock - theoreticalStock;

        inventaireMateriels.add(
          InventaireMateriel(
            materiel: materiel,
            stockTheorique: theoreticalStock,
            stockPhysique: physicalStock,
            ecart: ecart,
          ),
        );
      }
    }

    // Appel au service API
    InventaireService service = InventaireService();
    bool success = await service.faireInventaireImmo(
      materiels: inventaireMateriels,
      employes: List.from(selectedEmployees),
    );

    if (success) {
      InventaireImmo newInventory = InventaireImmo(
        id: DateTime.now().millisecondsSinceEpoch,
        date: selectedDate,
        materiels: inventaireMateriels,
        employes: List.from(selectedEmployees),
      );

      setState(() {
        inventoryData.add(newInventory);
        showInventoryForm = false;
        selectedEmployees.clear();
        selectedMateriels.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inventaire enregistré avec succès !')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de l\'enregistrement de l\'inventaire.')),
      );
    }
  } catch (e) {
    print('Erreur : $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erreur : $e')),
    );
  }
}


  void cancelInventory() {
    setState(() {
      showInventoryForm = false;
      selectedEmployees.clear();
      selectedMateriels.clear();
    });
  }

  void removeInventoryItem(int id) {
    setState(() {
      inventoryData.removeWhere((inventory) => inventory.id == id);
    });
  }

  int get totalItems {
    return inventoryData.fold(0, (sum, inventory) => sum + inventory.materiels.length);
  }

  int get correctItems {
    return inventoryData.fold(0, (sum, inventory) => 
      sum + inventory.materiels.where((item) => item.ecart == 0).length);
  }

  int get discrepancyItems {
    return inventoryData.fold(0, (sum, inventory) => 
      sum + inventory.materiels.where((item) => item.ecart != 0).length);
  }

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.grey[100],
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              SizedBox(height: 20),
              if (!showInventoryForm) _buildNewInventoryForm(),
              SizedBox(height: 10),
              if (showInventoryForm) _buildInventoryForm(),
              _buildInventoryList(),
            ],
          ),
        ),
      ),
    ),
  );
}

// Header section
Widget _buildHeader() {
  return Container(
    width: double.infinity,
    padding: EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          spreadRadius: 1,
          blurRadius: 10,
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Inventaire immobilisations',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
            fontFamily: 'Poppins',
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Suivi des matériels et contrôle d\'inventaire',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      ],
    ),
  );
}

// New inventory form
Widget _buildNewInventoryForm() {
  return Container(
    width: double.infinity,
    padding: EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          spreadRadius: 1,
          blurRadius: 10,
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nouvel Inventaire',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 24),
        _buildDateSelector(),
        SizedBox(height: 20),
        _buildEmployeeSelector(),
        SizedBox(height: 20),
        _buildMaterielSelector(),
        SizedBox(height: 24),
        _buildStartInventoryButton(),
      ],
    ),
  );
}

// Date selector
Widget _buildDateSelector() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Date d\'inventaire',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.grey[700],
        ),
      ),
      SizedBox(height: 8),
      Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
          style: TextStyle(fontSize: 16, color: Colors.grey[800]),
        ),
      ),
    ],
  );
}

// Employee selector
Widget _buildEmployeeSelector() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Employés participants',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.grey[700],
        ),
      ),
      SizedBox(height: 8),
      Container(
        height: 150,
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListView.builder(
          itemCount: employees.length,
          itemBuilder: (context, index) {
            Employe employee = employees[index];
            return CheckboxListTile(
              title: Text(
                employee.nom,
                style: TextStyle(fontSize: 14),
              ),
              value: selectedEmployees.any((e) => e.idEmploye == employee.idEmploye),
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    selectedEmployees.add(employee);
                  } else {
                    selectedEmployees.removeWhere((e) => e.idEmploye == employee.idEmploye);
                  }
                });
              },
              activeColor: Color(0xFFF9B70D),
              dense: true,
              contentPadding: EdgeInsets.zero,
            );
          },
        ),
      ),
    ],
  );
}

// Materiel selector
Widget _buildMaterielSelector() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Matériels à inventorier',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.grey[700],
        ),
      ),
      SizedBox(height: 8),
      Container(
        height: 200,
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListView.builder(
          itemCount: materiels.length,
          itemBuilder: (context, index) {
            Materiel materiel = materiels[index];
            return CheckboxListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          materiel.designation ?? 'N/A',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                        Text(
                          'Code: ${materiel.code ?? 'N/A'}',
                          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Ref: ${materiel.reference ?? 'N/A'}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
              value: selectedMateriels.any((m) => m.idMateriel == materiel.idMateriel),
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    selectedMateriels.add(materiel);
                  } else {
                    selectedMateriels.removeWhere((m) => m.idMateriel == materiel.idMateriel);
                  }
                });
              },
              activeColor: Color(0xFFF9B70D),
              dense: true,
              contentPadding: EdgeInsets.zero,
            );
          },
        ),
      ),
    ],
  );
}

// Start inventory button
Widget _buildStartInventoryButton() {
  return ElevatedButton(
    onPressed: startInventory,
    style: ElevatedButton.styleFrom(
      backgroundColor: Color(0xFFF9B70D),
      foregroundColor: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    child: Text(
      'Démarrer l\'inventaire',
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    ),
  );
}

// Inventory form (physical stock input)
Widget _buildInventoryForm() {
  return Container(
    width: double.infinity,
    padding: EdgeInsets.all(24),
    margin: EdgeInsets.only(bottom: 20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          spreadRadius: 1,
          blurRadius: 10,
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Saisie des Stocks Physiques',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 24),
        _buildInventoryInfo(),
        SizedBox(height: 20),
        ..._buildMaterielInputs(),
        SizedBox(height: 24),
        _buildInventoryActions(),
      ],
    ),
  );
}

// Inventory information panel
Widget _buildInventoryInfo() {
  return Container(
    width: double.infinity,
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.blue[50],
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Informations de l\'inventaire',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.blue[800],
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Date: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
          style: TextStyle(fontSize: 14, color: Colors.blue[700]),
        ),
        Text(
          'Employés: ${selectedEmployees.map((e) => e.nom).join(', ')}',
          style: TextStyle(fontSize: 14, color: Colors.blue[700]),
        ),
        Text(
          'Matériels à inventorier: ${selectedMateriels.length}',
          style: TextStyle(fontSize: 14, color: Colors.blue[700]),
        ),
      ],
    ),
  );
}

// Materiel inputs for physical stock
List<Widget> _buildMaterielInputs() {
  return selectedMateriels.map((materiel) {
    double theoreticalStock = 1; // Valeur par défaut pour un matériel
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            materiel.designation ?? 'N/A',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[900],
            ),
          ),
          Text(
            'Code: ${materiel.code ?? 'N/A'} | Stock théorique: ${theoreticalStock.toInt()}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildPhysicalStockInput(materiel),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildVarianceDisplay(materiel, theoreticalStock),
              ),
            ],
          ),
        ],
      ),
    );
  }).toList();
}

  Widget _buildPhysicalStockInput(Materiel materiel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Stock physique compté',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 4),
      
        TextField(
          controller: physicalStockControllers[materiel.idMateriel!],
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
          ],
          decoration: InputDecoration(
            hintText: 'Quantité',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Color(0xFFF9B70D)),
            ),  
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
          onChanged: (value) {
            setState(() {
              physicalStocks[materiel.idMateriel!] = double.tryParse(value) ?? 0;
            });
          },
        ),
      ],
    );
  }
// Variance display
  Widget _buildVarianceDisplay(Materiel materiel, double theoreticalStock) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Écart',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.grey[700],
        ),
      ),
      SizedBox(height: 4),
      Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Builder(
          builder: (context) {
            double physicalStock = physicalStocks[materiel.idMateriel!] ?? 0;
            double variance = physicalStock - theoreticalStock;
            Color varianceColor = variance == 0
                ? Colors.green[600]!
                : variance > 0
                    ? Colors.blue[600]!
                    : Colors.red[600]!;
            String varianceText = variance > 0 ? '+${variance.toStringAsFixed(1)}' : '${variance.toStringAsFixed(1)}';
            if (variance == 0 && physicalStock == 0) varianceText = '-';
            
            return Text(
              varianceText,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: varianceColor,
              ),
            );
          },
        ),
      ),
    ],
  );
}

// Inventory action buttons
Widget _buildInventoryActions() {
  return Row(
    children: [
      ElevatedButton(
        onPressed: saveInventory,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFFF9B70D),
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          'Enregistrer l\'inventaire',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      SizedBox(width: 12),
      ElevatedButton(
        onPressed: cancelInventory,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[500],
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          'Annuler',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    ],
  );
}

// Inventory list section
Widget _buildInventoryList() {
  return Container(
    width: double.infinity,
    padding: EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          spreadRadius: 1,
          blurRadius: 10,
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Inventaires Réalisés',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 24),
        _buildInventoryTable(),
        SizedBox(height: 32),
        _buildSummaryCards(),
      ],
    ),
  );
}

// Inventory table
Widget _buildInventoryTable() {
  if (inventoryData.isNotEmpty) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: MaterialStateProperty.all(
          Color.fromARGB(154, 131, 130, 129),
        ),
        columns: _buildTableColumns(),
        rows: _buildInventoryRows(),
      ),
    );
  } else {
    return Center(
      child: Text(
        'Aucun inventaire réalisé pour le moment',
        style: TextStyle(
          fontSize: 16,
          color: Colors.grey[500],
        ),
      ),
    );
  }
}

// Table columns
List<DataColumn> _buildTableColumns() {
  return [
    DataColumn(
      label: Text(
        'Date',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: const Color.fromARGB(255, 0, 0, 0),
        ),
      ),
    ),
    DataColumn(
      label: Text(
        'Employés',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: const Color.fromARGB(255, 0, 0, 0),
        ),
      ),
    ),
    DataColumn(
      label: Text(
        'Nombre matériel',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: const Color.fromARGB(255, 0, 0, 0),
        ),
      ),
    ),
    DataColumn(
      label: Text(
        'Actions',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: const Color.fromARGB(255, 0, 0, 0),
        ),
      ),
    ),
  ];
}
List<DataColumn> _buildTableDetailsColumns() {
  return [  
    DataColumn(
      label: Text(
        'Code matériel',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: const Color.fromARGB(255, 0, 0, 0),
        ),
      ),
    ),
    DataColumn(
      label: Text(
        'Désignation',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: const Color.fromARGB(255, 0, 0, 0),
        ),
      ),
    ),
    DataColumn(
      label: Text(
        'Stock Théorique',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: const Color.fromARGB(255, 0, 0, 0),
        ),
      ),
    ),
    DataColumn(
      label: Text(
        'Stock Physique',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: const Color.fromARGB(255, 0, 0, 0),
        ),
      ),
    ),
    DataColumn(
      label: Text(
        'Écart',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: const Color.fromARGB(255, 0, 0, 0),
        ),
      ),
    ),
    DataColumn(
      label: Text(
        'Statut',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: const Color.fromARGB(255, 0, 0, 0),
        ),
      ),
    ),
  ];
}

Widget _buildSummaryCards() {
  return Row(
    children: [
      Expanded(
        child: _buildSummaryCard(
          value: '$totalItems',
          label: 'Matériels inventoriés',
          color: Colors.blue,
        ),
      ),
      SizedBox(width: 12),
      Expanded(
        child: _buildSummaryCard(
          value: '$correctItems',
          label: 'Stocks conformes',
          color: Colors.green,
        ),
      ),
      SizedBox(width: 12),
      Expanded(
        child: _buildSummaryCard(
          value: '$discrepancyItems',
          label: 'Écarts détectés',
          color: Colors.red,
        ),
      ),
    ],
  );
}

// Individual summary card
Widget _buildSummaryCard({
  required String value,
  required String label,
  required MaterialColor color,
}) {
  return Container(
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: color[50],
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color[600],
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: color[800],
          ),
        ),
      ],
    ),
  );
}
  List<DataRow> _buildInventoryRows() {
    List<DataRow> rows = [];
    
    for (InventaireImmo inventory in inventoryData) {
        rows.add(DataRow(
          cells: [
            DataCell(Text(
              '${inventory.date.day}/${inventory.date.month}/${inventory.date.year}',
              style: TextStyle(fontSize: 14),
            )),
            DataCell(Text(
              (inventory.employes != null)
                  ? inventory.employes!.map((e) => e.nom).join(', ')
                  : '',
              style: TextStyle(fontSize: 14),
            )),
            DataCell(Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  inventory.getNbMateriels().toString(),
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ],
            )),
            DataCell(
              Row(
              children: [
                TextButton(
                onPressed: () => removeInventoryItem(inventory.id),
                child: Icon(
                  Icons.delete,
                  color: Colors.red[600],
                  size: 20,
                ),
                ),
                SizedBox(width: 8),
                TextButton(
                onPressed: () {
                  showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                    title: Text('Détails de l\'inventaire'),
                    content: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                      columns: _buildTableDetailsColumns(),
                      rows: _buildInventoryDetailsRows(inventory),
                      ),
                    ),
                    actions: [
                      TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Fermer'),
                      ),
                    ],
                    );
                  },
                  );
                },
                style: TextButton.styleFrom(
                  foregroundColor: Color(0xFFF9B70D),
                ),
                child: Icon(
                  Icons.info_outline,
                  color: Color(0xFFF9B70D),
                  size: 20,
                ),
                ),
              ],
              ),
            ),
          ],
        ));
      // }
    }
    
    return rows;
  }
  List<DataRow> _buildInventoryDetailsRows(InventaireImmo inventory) {
    List<DataRow> rows = [];
      for (InventaireMateriel inventaireMateriel in inventory.materiels) {
        Color varianceColor = inventaireMateriel.ecart == 0
            ? Colors.green[600]!
            : inventaireMateriel.ecart > 0
                ? Colors.blue[600]!
                : Colors.red[600]!;
        String varianceText = inventaireMateriel.ecart > 0 
            ? '+${inventaireMateriel.ecart.toStringAsFixed(1)}' 
            : inventaireMateriel.ecart.toStringAsFixed(1);

        rows.add(DataRow(
          cells: [
            DataCell(Text(
              inventaireMateriel.materiel.code ?? 'N/A',
              style: TextStyle(fontSize: 14),
            )),
            DataCell(
                Text(
                  inventaireMateriel.materiel.designation ?? 'N/A',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                )),
            DataCell(Text(
              inventaireMateriel.stockTheorique.toStringAsFixed(1),
              style: TextStyle(fontSize: 14),
            )),
            DataCell(Text(
              inventaireMateriel.stockPhysique.toStringAsFixed(1),
              style: TextStyle(fontSize: 14),
            )),
            DataCell(Text(
              varianceText,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: varianceColor,
              ),
            )),
            DataCell(
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: inventaireMateriel.ecart == 0 ? Colors.green[100] : Colors.red[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  inventaireMateriel.ecart == 0 ? 'Conforme' : 'Écart',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: inventaireMateriel.ecart == 0 ? Colors.green[800] : Colors.red[800],
                  ),
                ),
              ),
            ),
          ],
        ));
    }
    
    return rows;
  }
}