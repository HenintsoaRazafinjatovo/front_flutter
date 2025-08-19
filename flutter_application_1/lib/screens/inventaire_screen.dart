import 'package:flutter/material.dart';
import '../models/article.dart' show Article;
import '../models/inventaire_article.dart' show InventaireArticle;
import '../models/inventaire.dart' show Inventaire;
import '../models/employe.dart' show Employe;
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

class InventoryManagementScreen extends StatefulWidget {
  @override
  _InventoryManagementScreenState createState() =>
      _InventoryManagementScreenState();
}

class _InventoryManagementScreenState extends State<InventoryManagementScreen> {
  DateTime selectedDate = DateTime.now();
  List<Employe> selectedEmployees = [];
  List<Article> selectedArticles = [];
  List<Inventaire> inventoryData = [];
  bool showInventoryForm = false;
  
  // Données exemple - normalement récupérées depuis une base de données
  final List<Employe> employees = [
    Employe(idEmploye: 1, nom: 'Marie Dubois', idDirection: 1),
    Employe(idEmploye: 2, nom: 'Jean Martin', idDirection: 1),
    Employe(idEmploye: 3, nom: 'Sophie Laurent', idDirection: 2),
    Employe(idEmploye: 4, nom: 'Pierre Moreau', idDirection: 2),
    Employe(idEmploye: 5, nom: 'Claire Bernard', idDirection: 3),
  ];

  final List<Article> articles = [
    Article(idArticle: 1, intitule: 'PV de stockage', seuilMin: 150, code: 'PVS001', prix: 25.0),
    Article(idArticle: 2, intitule: 'Fiche de pret', seuilMin: 75, code: 'FP002', prix: 15.0),
    Article(idArticle: 3, intitule: 'Carnet de membre', seuilMin: 45, code: 'CM003', prix: 30.0),
    Article(idArticle: 4, intitule: 'Écran 24 pouces', seuilMin: 30, code: 'ECR024', prix: 450.0),
    Article(idArticle: 5, intitule: 'Acte de cautionnement', seuilMin: 60, code: 'AC005', prix: 20.0),
    Article(idArticle: 6, intitule: 'Contrat depot a terme', seuilMin: 25, code: 'CDT006', prix: 18.0),
    Article(idArticle: 7, intitule: 'Fanambarana fanonerana', seuilMin: 12, code: 'FF007', prix: 12.0),
    Article(idArticle: 8, intitule: 'Registre de transmission', seuilMin: 18, code: 'RT008', prix: 35.0),
  ];

  Map<int, TextEditingController> physicalStockControllers = {};
  Map<int, double> physicalStocks = {};

  @override
  void initState() {
    super.initState();
    // Initialiser les contrôleurs pour chaque article
    articles.forEach((article) {
      if (article.idArticle != null) {
        physicalStockControllers[article.idArticle!] = TextEditingController();
      }
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
        if (article.idArticle != null) {
          physicalStockControllers[article.idArticle!]?.clear();
        }
      });
    });
  }

  void saveInventory() {
    List<InventaireArticle> inventaireArticles = [];
    
    selectedArticles.forEach((article) {
      if (article.idArticle != null) {
        double physicalStock = double.tryParse(
          physicalStockControllers[article.idArticle!]?.text ?? '0'
        ) ?? 0;
        double theoreticalStock = article.seuilMin;
        double ecart = physicalStock - theoreticalStock;

        inventaireArticles.add(InventaireArticle(
          article: article,
          stockTheorique: theoreticalStock,
          stockPhysique: physicalStock,
          ecart: ecart,
        ));
      }
    });

    Inventaire newInventory = Inventaire(
      id: DateTime.now().millisecondsSinceEpoch,
      date: selectedDate,
      articles: inventaireArticles,
      employes: List.from(selectedEmployees),
    );

    setState(() {
      inventoryData.add(newInventory);
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
      inventoryData.removeWhere((inventory) => inventory.id == id);
    });
  }

  int get totalItems {
    return inventoryData.fold(0, (sum, inventory) => sum + inventory.articles.length);
  }

  int get correctItems {
    return inventoryData.fold(0, (sum, inventory) => 
      sum + inventory.articles.where((item) => item.ecart == 0).length);
  }

  int get discrepancyItems {
    return inventoryData.fold(0, (sum, inventory) => 
      sum + inventory.articles.where((item) => item.ecart != 0).length);
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
                        'Gestion d\'Inventaire',
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
                            itemCount: articles.length,
                            itemBuilder: (context, index) {
                              Article article = articles[index];
                              return CheckboxListTile(
                                title: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            article.intitule,
                                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                          ),
                                          Text(
                                            'Code: ${article.code}',
                                            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      'Seuil: ${article.seuilMin.toInt()}',
                                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                                    ),
                                  ],
                                ),
                                value: selectedArticles.any((a) => a.idArticle == article.idArticle),
                                onChanged: (bool? value) {
                                  setState(() {
                                    if (value == true) {
                                      selectedArticles.add(article);
                                    } else {
                                      selectedArticles.removeWhere((a) => a.idArticle == article.idArticle);
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
                            'Démarrer l\'inventaire',
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
                                'Employés: ${selectedEmployees.map((e) => e.nom).join(', ')}',
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
                          double theoreticalStock = article.seuilMin;
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
                                  article.intitule,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[900],
                                  ),
                                ),
                                Text(
                                  'Code: ${article.code} | Seuil minimum: ${theoreticalStock.toInt()}',
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
                                            controller: physicalStockControllers[article.idArticle!],
                                            keyboardType: TextInputType.numberWithOptions(decimal: true),
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
                                                physicalStocks[article.idArticle!] = double.tryParse(value) ?? 0;
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
                                                double physicalStock = physicalStocks[article.idArticle!] ?? 0;
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

                // Liste des inventaires
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
                        'Inventaires Réalisés',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 24),

                      // Table des inventaires
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
                                  'Article',
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
                            ],
                            rows: _buildInventoryRows(),
                          ),
                        ),
                      ] else ...[
                        Center(
                          child: Text(
                            'Aucun inventaire réalisé pour le moment',
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

  List<DataRow> _buildInventoryRows() {
    List<DataRow> rows = [];
    
    for (Inventaire inventory in inventoryData) {
      for (InventaireArticle inventaireArticle in inventory.articles) {
        Color varianceColor = inventaireArticle.ecart == 0
            ? Colors.green[600]!
            : inventaireArticle.ecart > 0
                ? Colors.blue[600]!
                : Colors.red[600]!;
        String varianceText = inventaireArticle.ecart > 0 
            ? '+${inventaireArticle.ecart.toStringAsFixed(1)}' 
            : '${inventaireArticle.ecart.toStringAsFixed(1)}';

        rows.add(DataRow(
          cells: [
            DataCell(Text(
              '${inventory.date.day}/${inventory.date.month}/${inventory.date.year}',
              style: TextStyle(fontSize: 14),
            )),
            DataCell(Text(
              inventory.employes.map((e) => e.nom).join(', '),
              style: TextStyle(fontSize: 14),
            )),
            DataCell(Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  inventaireArticle.article.intitule,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                Text(
                  inventaireArticle.article.code,
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            )),
            DataCell(Text(
              '${inventaireArticle.stockTheorique.toStringAsFixed(1)}',
              style: TextStyle(fontSize: 14),
            )),
            DataCell(Text(
              '${inventaireArticle.stockPhysique.toStringAsFixed(1)}',
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
                  color: inventaireArticle.ecart == 0 ? Colors.green[100] : Colors.red[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  inventaireArticle.ecart == 0 ? 'Conforme' : 'Écart',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: inventaireArticle.ecart == 0 ? Colors.green[800] : Colors.red[800],
                  ),
                ),
              ),
            ),
            DataCell(
              TextButton(
                onPressed: () => removeInventoryItem(inventory.id),
                child: Icon(
                  Icons.delete,
                  color: Colors.red[600],
                  size: 20,
                ),
              ),
            ),
          ],
        ));
      }
    }
    
    return rows;
  }
}