
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/article.dart';
import '../services/articleService.dart';
import '../services/bon_de_commandeService.dart';
import '../models/bon_de_commande.dart';
import 'dart:typed_data';
import 'dart:html' as html;

class BonDeCommandeScreen extends StatefulWidget {
  const BonDeCommandeScreen({super.key});

  @override
  State<BonDeCommandeScreen> createState() => _BonDeCommandeScreenState();
}

class _BonDeCommandeScreenState extends State<BonDeCommandeScreen> {
  List<Article> articles = [];
  Article? selectedArticle;
  String quantity = '';
  String descriptionCommande = '';
  final List<Map<String, dynamic>> recapCommande = [];
  final _formKey = GlobalKey<FormState>();
  
  int currentPage = 1;
  int lastPage = 1;
  int itemsPerPage = 10;
  int totalCommandes = 0;
  List<BonDeCommande> commandes = [];
  

  // Getter pour obtenir les commandes paginées de la page courante
  List<BonDeCommande> get paginatedCommandes => commandes;
  
  // Getter pour le nombre total de pages
  int get totalPages => (commandes.length / itemsPerPage).ceil();

  @override
  void initState() {
    super.initState();
    _loadArticles();
    _loadCommandes();
  }

   Future<void> _loadCommandes() async {
    try {
      final paginated = await BonDeCommandeService()
          .getBonDeCommandeWithStatus(page: currentPage, perPage: itemsPerPage);

      setState(() {
        commandes = paginated.data;
        currentPage = paginated.currentPage;
        lastPage = paginated.lastPage;
        totalCommandes = paginated.total;
      });
    } catch (e) {
      print('Erreur: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur de chargement : $e")),
      );
    }
  }

  Future<void> _loadArticles() async {
    try {
      final loadedArticles = await ArticleService().getAllArticles();
      setState(() {
        articles = loadedArticles;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur de chargement des articles: $e")),
      );
    }
  }
  
  void openPdfWeb(Uint8List pdfBytes, String filename) {
    final blob = html.Blob([pdfBytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);

    html.AnchorElement anchor = html.AnchorElement(href: url)
      ..setAttribute("download", filename);
    html.document.body?.append(anchor);
    anchor.click();
    anchor.remove();

    html.Url.revokeObjectUrl(url);
  }

  void ajouterOuMettreAJourArticle() {
    if (_formKey.currentState!.validate()) {
      final int quantiteAjoutee = int.parse(quantity);
      final existingIndex =
          recapCommande.indexWhere((item) => item['article'].idArticle == selectedArticle!.idArticle);

      setState(() {
        if (existingIndex != -1) {
          recapCommande[existingIndex]['quantite'] += quantiteAjoutee;
        } else {
          recapCommande.add({
            'article': selectedArticle,
            'quantite': quantiteAjoutee,
          });
        }
        selectedArticle = null;
        quantity = '';
      });
    }
  }

  void supprimerLigne(int index) {
    setState(() => recapCommande.removeAt(index));
  }

  double calculerTotal() {
    return recapCommande.fold(
        0.0, (sum, item) => sum + item['quantite'] * item['article'].prix);
  }

  void validerCommandeFinale() async {
    if (_formKey.currentState!.validate()) {
      if (recapCommande.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Aucun article dans la commande.")),
        );
        return;
      }

      List<Map<String, dynamic>> articlesData = recapCommande.map((item) {
        final article = item['article'];
        final quantite = item['quantite'];
        return {
          'id_article': article.idArticle,
          'quantite': quantite,
        };
      }).toList();

      bool success = await BonDeCommandeService().addBonDeCommande(
        description: descriptionCommande,
        idStatusCommande: 1,
        articles: articlesData,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Bon de commande créé avec succès !")),
        );
        setState(() {
          recapCommande.clear();
          descriptionCommande = '';
        });
        // Recharger les commandes après création
        _loadCommandes();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erreur lors de la création du bon de commande.")),
        );
      }
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
                _loadCommandes();
              },
      ),
      IconButton(
        icon: const Icon(Icons.chevron_left),
        onPressed: currentPage == 1
            ? null
            : () {
                setState(() => currentPage--);
                _loadCommandes();
              },
      ),

      // 🔥 Current page avec background color
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
                _loadCommandes();
              },
      ),
      IconButton(
        icon: const Icon(Icons.last_page),
        onPressed: currentPage >= lastPage
            ? null
            : () {
                setState(() => currentPage = lastPage);
                _loadCommandes();
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
            _loadCommandes();
          }
        },
      ),
    ],
  );
}

 
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            color: Colors.white,
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Créer un bon de commande',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Form(
                    key: _formKey,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth < 600) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              DropdownButtonFormField<Article>(
                                value: selectedArticle,
                                isExpanded: true,
                                selectedItemBuilder: (context) => articles.map((article) {
                                  return Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      article.intitule,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  );
                                }).toList(),
                                items: articles.map((article) {
                                  return DropdownMenuItem<Article>(
                                    value: article,
                                    child: ConstrainedBox(
                                      constraints: const BoxConstraints(maxWidth: 350),
                                      child: Text(
                                        article.intitule,
                                        softWrap: true,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) => setState(() => selectedArticle = val),
                                decoration: const InputDecoration(
                                  labelText: 'Article',
                                  border: OutlineInputBorder(),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Color.fromARGB(243, 62, 61, 62)),
                                  ),
                                ),
                                validator: (value) {
                                  if ((value == null) && (recapCommande.isEmpty)) {
                                    return 'Choisir un article';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        labelText: 'Quantité',
                                        border: OutlineInputBorder(),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: Color.fromARGB(243, 62, 61, 62)),
                                        ),
                                      ),
                                      onChanged: (val) => quantity = val,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) return 'Quantité requise';
                                        if (int.tryParse(value) == null || int.parse(value) <= 0) {
                                          return 'Quantité invalide';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  SizedBox(
                                    width: 60,
                                    child: ElevatedButton(
                                      onPressed: ajouterOuMettreAJourArticle,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFF9B70D),
                                        padding: const EdgeInsets.symmetric(vertical: 18),
                                      ),
                                      child: const Text('+',
                                          style: TextStyle(color: Colors.white, fontSize: 18)),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        } else {
                          return Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: DropdownButtonFormField<Article>(
                                  value: selectedArticle,
                                  isExpanded: true,
                                  selectedItemBuilder: (context) => articles.map((article) {
                                    return Align(
                                      alignment: Alignment.centerLeft,
                                      child: ConstrainedBox(
                                        constraints: const BoxConstraints(maxHeight: 80),
                                        child: Text(
                                          article.intitule,
                                          softWrap: true,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  items: articles.map((article) {
                                    return DropdownMenuItem<Article>(
                                      value: article,
                                      child: ConstrainedBox(
                                        constraints: const BoxConstraints(maxWidth: 350),
                                        child: Text(
                                          article.intitule,
                                          softWrap: true,
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (val) => setState(() => selectedArticle = val),
                                  decoration: const InputDecoration(
                                    labelText: 'Article',
                                    border: OutlineInputBorder(),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Color.fromARGB(243, 62, 61, 62)),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                                  ),
                                  validator: (value) {
                                    if ((value == null) && (recapCommande.isEmpty)) {
                                      return 'Choisir un article';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Quantité',
                                    border: OutlineInputBorder(),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Color.fromARGB(243, 62, 61, 62)),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                                  ),
                                  onChanged: (val) => quantity = val,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) return 'Quantité requise';
                                    if (int.tryParse(value) == null || int.parse(value) <= 0) {
                                      return 'Quantité invalide';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              SizedBox(
                                width: 50,
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: ajouterOuMettreAJourArticle,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFF9B70D),
                                    padding: const EdgeInsets.all(0),
                                  ),
                                  child: const Text('+',
                                      style: TextStyle(color: Colors.white, fontSize: 18)),
                                ),
                              ),
                            ],
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 30),
                  if (recapCommande.isNotEmpty) ...[
                    Text(
                      'Récapitulatif de la commande',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowColor: WidgetStateProperty.all(const Color.fromARGB(154, 131, 130, 129)),
                          headingTextStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          columnSpacing: 24,
                          columns: const [
                            DataColumn(label: Text('Article')),
                            DataColumn(label: Text('PU')),
                            DataColumn(label: Text('Quantité')),
                            DataColumn(label: Text('Montant')),
                            DataColumn(label: Text('')),
                          ],
                          rows: List.generate(recapCommande.length, (index) {
                            final item = recapCommande[index];
                            final article = item['article'] as Article;
                            final quantite = item['quantite'];
                            final montant = article.prix! * quantite;

                            return DataRow(cells: [
                              DataCell(
                                SizedBox(
                                  width: 200,
                                  child: Text(
                                    article.intitule,
                                    softWrap: true,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              DataCell(Text('${article.prix}')),
                              DataCell(Text('$quantite')),
                              DataCell(Text('${montant.toStringAsFixed(2)}')),
                              DataCell(
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                                  onPressed: () => supprimerLigne(index),
                                ),
                              ),
                            ]);
                          }),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final descriptionField = TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color.fromARGB(243, 62, 61, 62)),
                            ),
                          ),
                          onChanged: (val) => descriptionCommande = val,
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Description requise';
                            return null;
                          },
                        );

                        final totalText = Text(
                          'Total: ${calculerTotal().toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        );

                        final validateBtn = ElevatedButton.icon(
                          onPressed: validerCommandeFinale,
                          icon: const Icon(Icons.check_circle, color: Colors.white),
                          label: const Text('Valider la commande', style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            backgroundColor: const Color(0xFFF9B70D),
                          ),
                        );

                        if (constraints.maxWidth < 360) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              descriptionField,
                              const SizedBox(height: 12),
                              totalText,
                              const SizedBox(height: 8),
                              SizedBox(width: double.infinity, child: validateBtn),
                            ],
                          );
                        }

                        return Wrap(
                          spacing: 16,
                          runSpacing: 8,
                          alignment: WrapAlignment.end,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            SizedBox(
                              width: constraints.maxWidth > 800 ? 520 : constraints.maxWidth * 0.55,
                              child: descriptionField,
                            ),
                            ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: constraints.maxWidth * 0.25),
                              child: totalText,
                            ),
                            validateBtn,
                          ],
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            color: Colors.white,
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Historique des bons de commande',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'Total: ${commandes.length} commande(s)',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(const Color.fromARGB(154, 131, 130, 129)),
                        headingTextStyle: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        columnSpacing: 24,
                        columns: const [
                          DataColumn(label: Text('ID')),
                          DataColumn(label: Text('Description')),
                          DataColumn(label: Text('Status')),
                          DataColumn(label: Text('Date')),
                          DataColumn(label: Text('Actions')),
                        ],
                        rows: paginatedCommandes.map((cmd) {
                          return DataRow(cells: [
                            DataCell(Text(cmd.idBonDeCommande.toString())),
                            DataCell(
                              SizedBox(
                                width: 200,
                                child: Text(
                                  cmd.description,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                              ),
                            ),
                            DataCell(Text(cmd.status_commande)),
                            DataCell(Text(cmd.dateBonDeCommande.toString())),
                            DataCell(
                              IconButton(
                                icon: const Icon(Icons.download, color: Color(0xFFF9B70D)),
                                onPressed: () async {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Impression de la facture...')),
                                  );
                                  try {
                                    final bonDeCommandeService = BonDeCommandeService();
                                    final pdfBytes = await bonDeCommandeService.generatePdf('facture', cmd.idBonDeCommande ?? 0);
                                    openPdfWeb(pdfBytes, 'BC-${cmd.idBonDeCommande}');
                                  } catch (e) {
                                    print('Erreur : $e');
                                  }
                                },
                              ),
                            ),
                          ]);
                        }).toList(),
                      ),
                    ),
                  ),
                  // Contrôles de pagination
                  _buildPaginationControls(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}