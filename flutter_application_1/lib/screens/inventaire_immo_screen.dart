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
  int currentPage = 1;
  int lastPage = 1;
  int itemsPerPage = 10;
  int totalInventaires = 0;
  List<Employe> selectedEmployees = [];
  List<Materiel> selectedMateriels = [];
  List<InventaireImmo> inventoryData = [];
  List<Employe> employees = [];
  List<Materiel> filteredMateriels = [];
  List<Materiel> materiels = [];

  bool showInventoryForm = false;
  bool showManualSelection = false;
  bool showBarcodeScanning = false;
  Map<int, int> scannedMateriels = {};
  List<Materiel> scannedMaterielsList = [];
  
  // FocusNode pour le scanner de code-barres
  final FocusNode barcodeFocusNode = FocusNode();
  final TextEditingController barcodeController = TextEditingController();
  
  Future<void> _loadMateriels() async {
    try {
      final loadedMateriels = await MaterielService().getAllMaterielsList();
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur de chargement des employés: $e")),
      );
    }
  }

  Future<void> _loadInventory() async {
    try {
      final loadedInventory = await InventaireService().getAllInventairesImmoWithDetails(page: currentPage, perPage: itemsPerPage);
      setState(() {
        inventoryData = loadedInventory.data;
        currentPage = loadedInventory.currentPage;
        lastPage = loadedInventory.lastPage;
        totalInventaires = loadedInventory.total;
      });
    } catch (e) {
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
    barcodeFocusNode.dispose();
    barcodeController.dispose();
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
      showManualSelection = false;
      physicalStocks.clear();
      selectedMateriels.forEach((materiel) {
        if (materiel.idMateriel != null) {
          physicalStockControllers[materiel.idMateriel!]?.clear();
        }
      });
    });
  }

  void startManualInventory() {
    if (selectedEmployees.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez sélectionner au moins un employé')),
      );
      return;
    }
    setState(() {
      showManualSelection = true;
      showBarcodeScanning = false;
    });
  }

  void startBarcodeInventory() {
    if (selectedEmployees.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez sélectionner au moins un employé')),
      );
      return;
    }
    setState(() {
      showBarcodeScanning = true;
      showManualSelection = false;
      scannedMateriels.clear();
      scannedMaterielsList.clear();
      barcodeController.clear();
    });
    // Assurer que le focus est mis après le build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      barcodeFocusNode.requestFocus();
    });
  }

  void handleBarcodeScanned(String barcode) {
    Materiel? foundMateriel;
    try {
      foundMateriel = materiels.firstWhere(
        (m) => m.code == barcode,
      );
    } catch (e) {
      foundMateriel = null;
    }

    if (foundMateriel != null && foundMateriel.idMateriel != null) {
      setState(() {
        if (scannedMateriels.containsKey(foundMateriel!.idMateriel)) {
          scannedMateriels[foundMateriel.idMateriel!] = 
            scannedMateriels[foundMateriel.idMateriel!]! + 1;
        } else {
          scannedMateriels[foundMateriel.idMateriel!] = 1;
          scannedMaterielsList.add(foundMateriel);
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Matériel scanné: ${foundMateriel.designation}'),
          duration: Duration(seconds: 1),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Code barre non trouvé: $barcode'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void removeScannedMateriel(int idMateriel) {
    setState(() {
      scannedMateriels.remove(idMateriel);
      scannedMaterielsList.removeWhere((m) => m.idMateriel == idMateriel);
    });
  }

  void saveBarcodeInventory() async {
    try {
      List<InventaireMateriel> inventaireMateriels = [];

      for (var materiel in scannedMaterielsList) {
        if (materiel.idMateriel != null) {
          double physicalStock = scannedMateriels[materiel.idMateriel!]!.toDouble();
          double theoreticalStock = 1;
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

      InventaireService service = InventaireService();
      bool success = await service.faireInventaireImmo(
        materiels: inventaireMateriels,
        employes: List.from(selectedEmployees),
      );

      if (success) {
        await _loadInventory();

        setState(() {
          showBarcodeScanning = false;
          selectedEmployees.clear();
          scannedMateriels.clear();
          scannedMaterielsList.clear();
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

  void saveInventory() async {
    try {
      List<InventaireMateriel> inventaireMateriels = [];

      for (var materiel in selectedMateriels) {
        if (materiel.idMateriel != null) {
          double physicalStock = double.tryParse(
                physicalStocks[materiel.idMateriel!]?.toString() ?? '0',
              ) ??
              0;
          double theoreticalStock = 1;
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

      InventaireService service = InventaireService();
      bool success = await service.faireInventaireImmo(
        materiels: inventaireMateriels,
        employes: List.from(selectedEmployees),
      );

      if (success) {
        await _loadInventory();

        setState(() {
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
      showManualSelection = false;
      showBarcodeScanning = false;
      selectedEmployees.clear();
      selectedMateriels.clear();
      scannedMateriels.clear();
      scannedMaterielsList.clear();
      barcodeController.clear();
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
                  _loadInventory();
                },
        ),
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: currentPage == 1
              ? null
              : () {
                  setState(() => currentPage--);
                  _loadInventory();
                },
        ),
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
                  _loadInventory();
                },
        ),
        IconButton(
          icon: const Icon(Icons.last_page),
          onPressed: currentPage >= lastPage
              ? null
              : () {
                  setState(() => currentPage = lastPage);
                  _loadInventory();
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
              _loadInventory();
            }
          },
        ),
      ],
    );
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
                if (!showInventoryForm && !showManualSelection && !showBarcodeScanning) 
                  _buildNewInventoryForm(),
                SizedBox(height: 10),
                if (showManualSelection) _buildManualSelectionForm(),
                if (showBarcodeScanning) _buildBarcodeScanningForm(),
                if (showInventoryForm) _buildInventoryForm(),
                _buildInventoryList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
          SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: startManualInventory,
                  icon: Icon(Icons.list_alt),
                  label: Text('Inventaire manuel'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFF9B70D),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: startBarcodeInventory,
                  icon: Icon(Icons.qr_code_scanner),
                  label: Text('Inventaire par code-barre'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildManualSelectionForm() {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sélection manuelle des matériels',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              IconButton(
                onPressed: cancelInventory,
                icon: Icon(Icons.close, color: Colors.grey[600]),
              ),
            ],
          ),
          SizedBox(height: 24),
          _buildMaterielSelector(),
          SizedBox(height: 24),
          Row(
            children: [
              ElevatedButton(
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
          ),
        ],
      ),
    );
  }

  Widget _buildBarcodeScanningForm() {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Inventaire par code-barre',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              IconButton(
                onPressed: cancelInventory,
                icon: Icon(Icons.close, color: Colors.grey[600]),
              ),
            ],
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[700]),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Scannez les codes-barres des matériels avec votre scanner OY20S',
                    style: TextStyle(fontSize: 14, color: Colors.blue[700]),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24),
          TextField(
            controller: barcodeController,
            focusNode: barcodeFocusNode,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Scanner ou saisir le code-barre',
              prefixIcon: Icon(Icons.qr_code_scanner),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.blue[700]!),
              ),
            ),
            onSubmitted: (value) {
              if (value.isNotEmpty) {
                handleBarcodeScanned(value);
                barcodeController.clear();
                // Maintenir le focus après le scan
                Future.delayed(Duration(milliseconds: 50), () {
                  if (barcodeFocusNode.canRequestFocus) {
                    barcodeFocusNode.requestFocus();
                  }
                });
              }
            },
          ),
          SizedBox(height: 24),
          if (scannedMaterielsList.isNotEmpty) ...[
            Text(
              'Matériels scannés (${scannedMaterielsList.length})',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(Colors.grey[200]),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                columns: [
                  DataColumn(label: Text('Matériel')),
                  DataColumn(label: Text('Stock physique')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: scannedMaterielsList.map((materiel) {
                  return DataRow(
                    cells: [
                      DataCell(
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              materiel.designation ?? 'N/A',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            Text(
                              'Code: ${materiel.code ?? 'N/A'}',
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                      DataCell(
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.green[100],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${scannedMateriels[materiel.idMateriel!]}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green[800],
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red[600]),
                          onPressed: () {
                            removeScannedMateriel(materiel.idMateriel!);
                            // Remettre le focus après suppression
                            Future.delayed(Duration(milliseconds: 50), () {
                              if (barcodeFocusNode.canRequestFocus) {
                                barcodeFocusNode.requestFocus();
                              }
                            });
                          },
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 24),
          ],
          if (scannedMaterielsList.isEmpty)
            Container(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.qr_code_scanner, size: 64, color: Colors.grey[400]),
                    SizedBox(height: 16),
                    Text(
                      'Aucun matériel scanné',
                      style: TextStyle(fontSize: 16, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            ),
          Row(
            children: [
              ElevatedButton(
                onPressed: scannedMaterielsList.isEmpty ? null : saveBarcodeInventory,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
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
          ),
        ],
      ),
    );
  }

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

  List<Widget> _buildMaterielInputs() {
    return selectedMateriels.map((materiel) {
      double theoreticalStock = 1;
      if (!physicalStockControllers.containsKey(materiel.idMateriel!)) {
        physicalStockControllers[materiel.idMateriel!] = TextEditingController();
      }
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
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
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
          _buildPaginationControls(),
          SizedBox(height: 32),
          _buildSummaryCards(),
        ],
      ),
    );
  }

  Widget _buildInventoryTable() {
    if (inventoryData.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Text(
            'Aucun inventaire réalisé pour le moment',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: constraints.maxWidth,
            ),
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(
                Color.fromARGB(154, 131, 130, 129),
              ),
              columns: _buildTableColumns(),
              rows: _buildInventoryRows(),
              dataRowMinHeight: 50,
              dataRowMaxHeight: 70,
              horizontalMargin: 16,
              columnSpacing: 20,
              headingTextStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
        );
      },
    );
  }

  List<DataColumn> _buildTableColumns() {
    return [
      DataColumn(
        label: ConstrainedBox(
          constraints: BoxConstraints(minWidth: 120),
          child: Text('Date'),
        ),
      ),
      DataColumn(
        label: ConstrainedBox(
          constraints: BoxConstraints(minWidth: 200),
          child: Text('Employés'),
        ),
      ),
      DataColumn(
        label: ConstrainedBox(
          constraints: BoxConstraints(minWidth: 140),
          child: Text('Nombre matériel'),
        ),
      ),
      DataColumn(
        label: ConstrainedBox(
          constraints: BoxConstraints(minWidth: 120),
          child: Text('Actions'),
        ),
      ),
    ];
  }

  List<DataColumn> _buildTableDetailsColumns() {
    return [  
      DataColumn(
        label: ConstrainedBox(
          constraints: BoxConstraints(minWidth: 120),
          child: Text('Code matériel'),
        ),
      ),
      DataColumn(
        label: ConstrainedBox(
          constraints: BoxConstraints(minWidth: 200),
          child: Text('Désignation'),
        ),
      ),
      DataColumn(
        label: ConstrainedBox(
          constraints: BoxConstraints(minWidth: 120),
          child: Text('Stock Théorique'),
        ),
      ),
      DataColumn(
        label: ConstrainedBox(
          constraints: BoxConstraints(minWidth: 120),
          child: Text('Stock Physique'),
        ),
      ),
      DataColumn(
        label: ConstrainedBox(
          constraints: BoxConstraints(minWidth: 80),
          child: Text('Écart'),
        ),
      ),
      DataColumn(
        label: ConstrainedBox(
          constraints: BoxConstraints(minWidth: 100),
          child: Text('Statut'),
        ),
      ),
    ];
  }

  List<DataRow> _buildInventoryRows() {
    return inventoryData.map((inventory) {
      return DataRow(
        cells: [
          DataCell(
            SizedBox(
              width: 120,
              child: Text(
                '${inventory.date.day}/${inventory.date.month}/${inventory.date.year}',
                style: TextStyle(fontSize: 14),
              ),
            ),
          ),
          DataCell(
            SizedBox(
              width: 200,
              child: Text(
                (inventory.employes != null)
                    ? inventory.employes!.map((e) => e.nom).join(', ')
                    : '',
                style: TextStyle(fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          DataCell(
            SizedBox(
              width: 140,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    inventory.getNbMateriels().toString(),
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
          DataCell(
            SizedBox(
              width: 120,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => removeInventoryItem(inventory.id),
                    icon: Icon(
                      Icons.delete,
                      color: Colors.red[600],
                      size: 20,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  ),
                  SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return Dialog(
                            insetPadding: EdgeInsets.all(16),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: MediaQuery.of(context).size.width * 0.9,
                                maxHeight: MediaQuery.of(context).size.height * 0.8,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Text(
                                      'Détails de l\'inventaire',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.vertical,
                                        child: DataTable(
                                          columns: _buildTableDetailsColumns(),
                                          rows: _buildInventoryDetailsRows(inventory),
                                          dataRowMinHeight: 50,
                                          dataRowMaxHeight: 70,
                                          horizontalMargin: 16,
                                          columnSpacing: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(16),
                                    child: TextButton(
                                      onPressed: () => Navigator.of(context).pop(),
                                      child: Text('Fermer'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                    icon: Icon(
                      Icons.info_outline,
                      color: Color(0xFFF9B70D),
                      size: 20,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }).toList();
  }

  List<DataRow> _buildInventoryDetailsRows(InventaireImmo inventory) {
    return inventory.materiels.map((inventaireMateriel) {
      Color varianceColor = inventaireMateriel.ecart == 0
          ? Colors.green[600]!
          : inventaireMateriel.ecart > 0
              ? Colors.blue[600]!
              : Colors.red[600]!;
      String varianceText = inventaireMateriel.ecart > 0 
          ? '+${inventaireMateriel.ecart.toStringAsFixed(1)}' 
          : inventaireMateriel.ecart.toStringAsFixed(1);

      return DataRow(
        cells: [
          DataCell(
            SizedBox(
              width: 120,
              child: Text(
                inventaireMateriel.materiel.code ?? 'N/A',
                style: TextStyle(fontSize: 14),
              ),
            ),
          ),
          DataCell(
            SizedBox(
              width: 200,
              child: Text(
                inventaireMateriel.materiel.designation ?? 'N/A',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          DataCell(
            SizedBox(
              width: 120,
              child: Text(
                inventaireMateriel.stockTheorique.toStringAsFixed(1),
                style: TextStyle(fontSize: 14),
              ),
            ),
          ),
          DataCell(
            SizedBox(
              width: 120,
              child: Text(
                inventaireMateriel.stockPhysique.toStringAsFixed(1),
                style: TextStyle(fontSize: 14),
              ),
            ),
          ),
          DataCell(
            SizedBox(
              width: 80,
              child: Text(
                varianceText,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: varianceColor,
                ),
              ),
            ),
          ),
          DataCell(
            SizedBox(
              width: 100,
              child: Container(
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
          ),
        ],
      );
    }).toList();
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
}