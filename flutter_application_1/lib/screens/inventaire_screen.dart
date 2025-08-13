import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestion d\'Inventaire',
      theme: ThemeData(
        fontFamily: 'Poppins',
        primarySwatch: Colors.orange,
      ),
      home: InventoryManagementScreen(),
    );
  }
}

class InventoryItem {
  final int id;
  final DateTime date;
  final String employees;
  final String article;
  final int theoreticalStock;
  final int physicalStock;
  final int variance;

  InventoryItem({
    required this.id,
    required this.date,
    required this.employees,
    required this.article,
    required this.theoreticalStock,
    required this.physicalStock,
    required this.variance,
  });
}

class InventoryManagementScreen extends StatefulWidget {
  @override
  _InventoryManagementScreenState createState() =>
      _InventoryManagementScreenState();
}

class _InventoryManagementScreenState extends State<InventoryManagementScreen> {
  DateTime selectedDate = DateTime.now();
  List<String> selectedEmployees = [];
  List<String> selectedArticles = [];
  List<InventoryItem> inventoryData = [];
  bool showInventoryForm = false;
  
  final List<String> employees = [
    'Marie Dubois',
    'Jean Martin',
    'Sophie Laurent',
    'Pierre Moreau',
    'Claire Bernard',
  ];

  final Map<String, int> articles = {
    'PV de stockage': 150,
    'Fiche de pret': 75,
    'Carnet de membre': 45,
    'Écran 24 pouces': 30,
    'Acte de cautionnement': 60,
    'Contrat depot a terme': 25,
    'Fanambarana fanonerana': 12,
    'Registre de transmission': 18,
  };

  Map<String, TextEditingController> physicalStockControllers = {};
  Map<String, int> physicalStocks = {};

  @override
  void initState() {
    super.initState();
    // Initialiser les contrôleurs pour chaque article
    articles.keys.forEach((article) {
      physicalStockControllers[article] = TextEditingController();
    });
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
    if (selectedArticles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez sélectionner au moins un article')),
      );
      return;
    }

    setState(() {
      showInventoryForm = true;
      physicalStocks.clear();
      selectedArticles.forEach((article) {
        physicalStockControllers[article]?.clear();
      });
    });
  }

  void saveInventory() {
    List<InventoryItem> newItems = [];
    
    selectedArticles.forEach((article) {
      int physicalStock = int.tryParse(physicalStockControllers[article]?.text ?? '0') ?? 0;
      int theoreticalStock = articles[article] ?? 0;
      int variance = physicalStock - theoreticalStock;

      newItems.add(InventoryItem(
        id: DateTime.now().millisecondsSinceEpoch + newItems.length,
        date: selectedDate,
        employees: selectedEmployees.join(', '),
        article: article,
        theoreticalStock: theoreticalStock,
        physicalStock: physicalStock,
        variance: variance,
      ));
    });

    setState(() {
      inventoryData.addAll(newItems);
      showInventoryForm = false;
      selectedEmployees.clear();
      selectedArticles.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Inventaire enregistré avec succès !')),
    );
  }

  void cancelInventory() {
    setState(() {
      showInventoryForm = false;
      selectedEmployees.clear();
      selectedArticles.clear();
    });
  }

  void removeInventoryItem(int id) {
    setState(() {
      inventoryData.removeWhere((item) => item.id == id);
    });
  }

  int get totalItems => inventoryData.length;
  int get correctItems => inventoryData.where((item) => item.variance == 0).length;
  int get discrepancyItems => inventoryData.where((item) => item.variance != 0).length;

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
                // Header
                Container(
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
                        ' Gestion d\'Inventaire',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                          fontFamily: 'Poppins',
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Suivi des stocks et contrôle d\'inventaire',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),

                // Formulaire d'inventaire
                if (!showInventoryForm) ...[
                  Container(
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

                        // Date
                        Text(
                          'Date d\'inventaire',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(height: 8),
                        GestureDetector(
                          onTap: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2030),
                            );
                            if (picked != null && picked != selectedDate) {
                              setState(() {
                                selectedDate = picked;
                              });
                            }
                          },
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),

                        // Employés
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
                              return CheckboxListTile(
                                title: Text(
                                  employees[index],
                                  style: TextStyle(fontSize: 14),
                                ),
                                value: selectedEmployees.contains(employees[index]),
                                onChanged: (bool? value) {
                                  setState(() {
                                    if (value == true) {
                                      selectedEmployees.add(employees[index]);
                                    } else {
                                      selectedEmployees.remove(employees[index]);
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
                        SizedBox(height: 20),

                        // Articles
                        Text(
                          'Articles à inventorier',
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
                            itemCount: articles.keys.length,
                            itemBuilder: (context, index) {
                              String article = articles.keys.elementAt(index);
                              int stock = articles[article]!;
                              return CheckboxListTile(
                                title: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        article,
                                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                    Text(
                                      'Stock théo: $stock',
                                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                                    ),
                                  ],
                                ),
                                value: selectedArticles.contains(article),
                                onChanged: (bool? value) {
                                  setState(() {
                                    if (value == true) {
                                      selectedArticles.add(article);
                                    } else {
                                      selectedArticles.remove(article);
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
                        SizedBox(height: 24),

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
                            ' Démarrer l\'inventaire',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                 SizedBox(height: 10),
                // Formulaire de saisie des stocks
                if (showInventoryForm) ...[
                  Container(
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
                          'Saisie des Stocks Physiques',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                        SizedBox(height: 24),

                        // Informations de l'inventaire
                        Container(
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
                                'Employés: ${selectedEmployees.join(', ')}',
                                style: TextStyle(fontSize: 14, color: Colors.blue[700]),
                              ),
                              Text(
                                'Articles à inventorier: ${selectedArticles.length}',
                                style: TextStyle(fontSize: 14, color: Colors.blue[700]),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),

                        // Articles à inventorier
                        ...selectedArticles.map((article) {
                          int theoreticalStock = articles[article]!;
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
                                  article,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[900],
                                  ),
                                ),
                                Text(
                                  'Stock théorique: $theoreticalStock',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
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
                                            controller: physicalStockControllers[article],
                                            keyboardType: TextInputType.number,
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
                                                physicalStocks[article] = int.tryParse(value) ?? 0;
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
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
                                                int physicalStock = physicalStocks[article] ?? 0;
                                                int variance = physicalStock - theoreticalStock;
                                                Color varianceColor = variance == 0
                                                    ? Colors.green[600]!
                                                    : variance > 0
                                                        ? Colors.blue[600]!
                                                        : Colors.red[600]!;
                                                String varianceText = variance > 0 ? '+$variance' : '$variance';
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
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }).toList(),

                        SizedBox(height: 24),
                        Row(
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
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                ],

                // Liste des articles inventoriés
                Container(
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
                        'Articles Inventoriés',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 24),

                      // Table
                      if (inventoryData.isNotEmpty) ...[
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            headingRowColor: MaterialStateProperty.all(
                              Color.fromARGB(154, 131, 130, 129),
                            ),
                            columns: [
                              DataColumn(
                                label: Text(
                                  'Date',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Employés',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Article',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Stock Théorique',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Stock Physique',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Écart',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Statut',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Actions',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                            ],
                            rows: inventoryData.map((item) {
                              Color varianceColor = item.variance == 0
                                  ? Colors.green[600]!
                                  : item.variance > 0
                                      ? Colors.blue[600]!
                                      : Colors.red[600]!;
                              String varianceText = item.variance > 0 ? '+${item.variance}' : '${item.variance}';

                              return DataRow(
                                cells: [
                                  DataCell(Text(
                                    '${item.date.day}/${item.date.month}/${item.date.year}',
                                    style: TextStyle(fontSize: 14),
                                  )),
                                  DataCell(Text(
                                    item.employees,
                                    style: TextStyle(fontSize: 14),
                                  )),
                                  DataCell(Text(
                                    item.article,
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                  )),
                                  DataCell(Text(
                                    '${item.theoreticalStock}',
                                    style: TextStyle(fontSize: 14),
                                  )),
                                  DataCell(Text(
                                    '${item.physicalStock}',
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
                                        color: item.variance == 0 ? Colors.green[100] : Colors.red[100],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        item.variance == 0 ? ' Conforme' : 'Écart',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: item.variance == 0 ? Colors.green[800] : Colors.red[800],
                                        ),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    TextButton(
                                      onPressed: () => removeInventoryItem(item.id),
                                      child: Icon(
                                        Icons.delete,
                                        color: Colors.red[600],
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ] else ...[
                        Center(
                          child: Text(
                            'Aucun article inventorié pour le moment',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[500],
                            ),
                          ),
                        ),
                      ],

                      SizedBox(height: 32),

                      // Résumé
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    '$totalItems',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue[600],
                                    ),
                                  ),
                                  Text(
                                    'Articles inventoriés',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.blue[800],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.green[50],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    '$correctItems',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green[600],
                                    ),
                                  ),
                                  Text(
                                    'Stocks conformes',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.green[800],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.red[50],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    '$discrepancyItems',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red[600],
                                    ),
                                  ),
                                  Text(
                                    'Écarts détectés',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.red[800],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}