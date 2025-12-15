import 'package:flareline_template/models/bon_de_commande.dart';
import 'package:flareline_template/models/bon_de_livraison.dart';
import 'package:flareline_template/models/agence.dart';
import 'package:flareline_template/services/bon_de_livraisonService.dart';
import 'package:flareline_template/services/bon_de_commandeService.dart';
import 'package:flareline_template/services/agenceService.dart';
import 'package:flareline_template/models/mvtStockArticle.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const BonDeLivraisonScreen());
}

class BonDeLivraisonScreen extends StatelessWidget {
  const BonDeLivraisonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestion Bon de Livraison',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: Colors.grey[50],
      ),
      home: const DeliveryNotesScreen(),
    );
  }
}

class DeliveryNotesScreen extends StatefulWidget {
  const DeliveryNotesScreen({super.key});

  @override
  _DeliveryNotesScreenState createState() => _DeliveryNotesScreenState();
}

class _DeliveryNotesScreenState extends State<DeliveryNotesScreen> {
  final Color buttonColor = const Color(0xFFF9B70D);
  final Color headerColor = const Color.fromARGB(154, 131, 130, 129);

  int currentPage = 1;
  int lastPage = 1;
  int itemsPerPage = 10;
  int totalLivraisons = 0;

  List<BonDeLivraison> livraisons = [];
  List<BonDeCommande> orders = [];
  List<BonDeLivraison> filteredDeliveryNotes = [];
  List<Agence> agences = [];
  DateTime? dateFilter;
  int? agencyFilter;
  BonDeCommande? selectedOrder;
  String message = "";

  List<BonDeLivraison> get paginatedLivraisons => livraisons;

  // Getter pour le nombre total de pages
  int get totalPages => (livraisons.length / itemsPerPage).ceil();

  @override
  void initState() {
    super.initState();
    _loadLivraisons();
    _loadCommandes();
    _loadAgences();
  }

  Future<void> _loadLivraisons() async {
    try {
      final loadedLivraisons = await BonDeLivraisonService().getBonDeLivraisonWithDetails(page: currentPage, perPage: itemsPerPage    
      );
      setState(() {
        livraisons = loadedLivraisons.data;
        totalLivraisons = loadedLivraisons.total;
        lastPage = loadedLivraisons.lastPage;
        currentPage = loadedLivraisons.currentPage;
        filteredDeliveryNotes = List.from(livraisons);
      });
    } catch (e) {
      print('Erreur de chargement des bons de livraison: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur de chargement des bons de livraison: $e")),
      );
    }
  }
  Future<void> _loadAgences() async {
    try {
      final loadedAgences = await AgenceService().getAgences();
      setState(() {
        agences = loadedAgences;
      });
    } catch (e) {
      print('Erreur de chargement des agences: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur de chargement des agences: $e")),
      );
    }
  }
  Future<void> _loadCommandes() async {
    try {
      final loadedCommandes = await BonDeCommandeService().getBonDeCommandeWithoutBonDeLivraison();
      setState(() {
        orders = loadedCommandes;
      });
    } catch (e) {
      print('Erreur de chargement des commandes: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur de chargement des commandes: $e")),
      );
    }
  }
  void openPdf(Uint8List pdfBytes, String filename) async {
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$filename.pdf');
    await file.writeAsBytes(pdfBytes, flush: true);

    // Ouvre le PDF
    await OpenFile.open(file.path);
  }
  void openPdfWeb(Uint8List pdfBytes, String filename) {
    final blob = html.Blob([pdfBytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);

    html.AnchorElement(href: url)
      ..setAttribute("download", filename)
      ..click();

    html.Url.revokeObjectUrl(url);
  }
  void _showCreateModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CreateDeliveryNoteDialog(
          orders: orders,
          buttonColor: buttonColor,
          onDeliveryNoteCreated: (BonDeLivraison note) {
            setState(() {
              filteredDeliveryNotes.add(note);
            });
          },
        );
      },
    );
  }

  void _showViewModal(BonDeLivraison note) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ViewDeliveryNoteDialog(
          note: note,
          buttonColor: buttonColor,
          headerColor: headerColor,
          openPdfWeb: openPdfWeb,
        );
      },
    );
  }

  void _applyFilters() {
    setState(() {
      filteredDeliveryNotes = livraisons.where((note) {
        final bool dateMatch = dateFilter == null ||
            DateFormat('dd/MM/yyyy').format(note.dateBonDeLivraison) ==
                DateFormat('dd/MM/yyyy').format(dateFilter!);
        final bool agencyMatch = agencyFilter == null ||
            note.agence?.idAgence == agencyFilter;
        return dateMatch && agencyMatch;
      }).toList();
    });
  }

  void _clearFilters() {
    setState(() {
      dateFilter = null;
      agencyFilter = null;
      filteredDeliveryNotes = List.from(livraisons);
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
                  _loadLivraisons();
                },
        ),
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: currentPage == 1
              ? null
              : () {
                  setState(() => currentPage--);
                  _loadLivraisons();
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
                  _loadLivraisons();
                },
        ),
        IconButton(
          icon: const Icon(Icons.last_page),
          onPressed: currentPage >= lastPage
              ? null
              : () {
                  setState(() => currentPage = lastPage);
                  _loadLivraisons();
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
              _loadLivraisons();
            }
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.grey[50]!, Colors.grey[100]!],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Header
                Container(
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
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bon de livraison',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Gestion des livraisons de stock',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: _showCreateModal,
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text(
                          'Créer Bon de livraison',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonColor,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Delivery Notes List - WRAPPED IN EXPANDED AND SINGLECHILDSCROLLVIEW
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
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
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Liste des bons de livraison',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Filters - Responsive layout
                          LayoutBuilder(
                            builder: (context, constraints) {
                              if (constraints.maxWidth > 768) {
                                // Desktop layout
                                return Row(
                                  children: [
                                    Expanded(
                                      child: InkWell(
                                        onTap: () async {
                                          final date = await showDatePicker(
                                            context: context,
                                            initialDate: dateFilter ?? DateTime.now(),
                                            firstDate: DateTime(2020),
                                            lastDate: DateTime(2030),
                                          );
                                          if (date != null) {
                                            setState(() {
                                              dateFilter = date;
                                            });
                                          }
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                          decoration: BoxDecoration(
                                            border: Border.all(color: Colors.grey[300]!),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                                              const SizedBox(width: 8),
                                              Text(
                                                dateFilter == null
                                                    ? 'Sélectionner une date'
                                                    : DateFormat('dd/MM/yyyy').format(dateFilter!),
                                                style: TextStyle(color: Colors.grey[700]),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: DropdownButtonFormField<int>(
                                        value: agencyFilter,
                                        decoration: InputDecoration(
                                          hintText: 'Toutes les agences',
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        ),
                                        items: [
                                          const DropdownMenuItem<int>(
                                            value: null,
                                            child: Text('Toutes les agences'),
                                          ),
                                          ...agences.map((agence) => DropdownMenuItem<int>(
                                                value: agence.idAgence,
                                                child: Text(agence.codeAgence ?? ''),
                                              )),
                                        ],
                                        onChanged: (value) {
                                          setState(() {
                                            agencyFilter = value;
                                          });
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    ElevatedButton(
                                      onPressed: _applyFilters,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: buttonColor,
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      ),
                                      child: const Text('Filtrer', style: TextStyle(color: Colors.white)),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton(
                                      onPressed: _clearFilters,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.grey[500],
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      ),
                                      child: const Text('Réinitialiser', style: TextStyle(color: Colors.white)),
                                    ),
                                  ],
                                );
                              } else {
                                // Mobile layout
                                return Column(
                                  children: [
                                    InkWell(
                                      onTap: () async {
                                        final date = await showDatePicker(
                                          context: context,
                                          initialDate: dateFilter ?? DateTime.now(),
                                          firstDate: DateTime(2020),
                                          lastDate: DateTime(2030),
                                        );
                                        if (date != null) {
                                          setState(() {
                                            dateFilter = date;
                                          });
                                        }
                                      },
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.grey[300]!),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                                            const SizedBox(width: 8),
                                            Text(
                                              dateFilter == null
                                                  ? 'Sélectionner une date'
                                                  : DateFormat('dd/MM/yyyy').format(dateFilter!),
                                              style: TextStyle(color: Colors.grey[700]),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    DropdownButtonFormField<int>(
                                      value: agencyFilter,
                                      decoration: InputDecoration(
                                        hintText: 'Toutes les agences',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      ),
                                      items: [
                                        const DropdownMenuItem<int>(
                                          value: null,
                                          child: Text('Toutes les agences'),
                                        ),
                                        ...agences.map((agence) => DropdownMenuItem<int>(
                                              value: agence.idAgence,
                                              child: Text(agence.codeAgence ?? ''),
                                            )),
                                      ],
                                      onChanged: (value) {
                                        setState(() {
                                          agencyFilter = value;
                                        });
                                      },
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: _applyFilters,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: buttonColor,
                                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                            ),
                                            child: const Text('Filtrer', style: TextStyle(color: Colors.white)),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: _clearFilters,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.grey[500],
                                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                            ),
                                            child: const Text('Réinitialiser', style: TextStyle(color: Colors.white)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              }
                            },
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Table Container with fixed height for vertical scrolling
                          Container(
                            height: 400, // Fixed height to enable vertical scrolling
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Container(
                                constraints: BoxConstraints(
                                  minWidth: MediaQuery.of(context).size.width - 370,
                                ),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  child: DataTable(
                                    columnSpacing: 20,
                                    horizontalMargin: 20,
                                    headingRowColor: MaterialStateProperty.all(headerColor),
                                    showCheckboxColumn: false,
                                    columns: const [
                                      DataColumn(
                                        label: Expanded(
                                          child: Text('Reference', 
                                            style: TextStyle(fontWeight: FontWeight.w600),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Expanded(
                                          child: Text('Date', 
                                            style: TextStyle(fontWeight: FontWeight.w600),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Expanded(
                                          child: Text('Agence', 
                                            style: TextStyle(fontWeight: FontWeight.w600),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Expanded(
                                          child: Text('Articles', 
                                            style: TextStyle(fontWeight: FontWeight.w600),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Expanded(
                                          child: Text('Actions', 
                                            style: TextStyle(fontWeight: FontWeight.w600),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ],
                                    rows: filteredDeliveryNotes.map((note) {
                                      return DataRow(
                                        cells: [
                                          DataCell(
                                            Center(
                                              child: Text(
                                                '${note.reference}', 
                                                style: const TextStyle(fontWeight: FontWeight.w500)
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            Center(
                                              child: Text(DateFormat('dd/MM/yyyy').format(note.dateBonDeLivraison)),
                                            ),
                                          ),
                                          DataCell(
                                            Center(
                                              child: Text(note.agence?.codeAgence ?? ""),
                                            ),
                                          ),
                                          DataCell(
                                            Center(
                                              child: Text('${note.articles?.length ?? 0} article${(note.articles?.length ?? 0) > 1 ? 's' : ''}'),
                                            ),
                                          ),
                                          DataCell(
                                            Center(
                                              child: ElevatedButton(
                                                onPressed: () => _showViewModal(note),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: buttonColor,
                                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                  minimumSize: const Size(80, 0),
                                                ),
                                                child: const Text('Voir', style: TextStyle(color: Colors.white, fontSize: 12)),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildPaginationControls(),
                        ],
                      ),
                    ),
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

// --- Les autres classes (CreateDeliveryNoteDialog et ViewDeliveryNoteDialog) restent identiques ---
class CreateDeliveryNoteDialog extends StatefulWidget {
  final List<BonDeCommande> orders;
  final Color buttonColor;
  final Function(BonDeLivraison) onDeliveryNoteCreated;

  const CreateDeliveryNoteDialog({
    super.key,
    required this.orders,
    required this.buttonColor,
    required this.onDeliveryNoteCreated,
  });

  @override
  _CreateDeliveryNoteDialogState createState() => _CreateDeliveryNoteDialogState();
}

class _CreateDeliveryNoteDialogState extends State<CreateDeliveryNoteDialog> {
  BonDeCommande? selectedOrder;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('➕ Créer un nouveau bon de livraison'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Sélectionner une commande validée', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            DropdownButtonFormField<BonDeCommande>(
              value: selectedOrder,
              decoration: const InputDecoration(
                hintText: '-- Choisir une commande --',
                border: OutlineInputBorder(),
              ),
              items: widget.orders
                  .where((order) => order.status_commande == 'Validée')
                  .map((order) => DropdownMenuItem(
                        value: order,
                        child: Text(
                          '${order.idBonDeCommande} - ${order.agence?.codeAgence ?? ""} (${order.total != null ? NumberFormat.currency(locale: "fr_FR", symbol: "", decimalDigits: 2).format(order.total) : '0.00'}) Ar'
                        ),
                      ))
                  .toList(),
              onChanged: (BonDeCommande? order) {
                setState(() {
                  selectedOrder = order;
                });
              },
            ),
            if (selectedOrder != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Aperçu de la commande ${selectedOrder!.idBonDeCommande}', style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Text('Agence: ${selectedOrder!.agence?.codeAgence ?? ""}'),
                    Text('Date: ${selectedOrder!.dateBonDeCommande != null ? DateFormat('dd/MM/yyyy').format(selectedOrder!.dateBonDeCommande!) : ''}'),
                    Text('Articles: ${(selectedOrder!.articles?.map((item) => '${item.article?.intitule ?? ""} (x${item.quantite})').join(', ')) ?? ''}'),
                    Text('Total: ${NumberFormat.currency(locale: "fr_FR", symbol: "", decimalDigits: 2).format(selectedOrder!.total ?? 0)} Ar'),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: selectedOrder == null
              ? null
              : () async {
                  try {
                    final success = await BonDeLivraisonService()
                        .creerBonDeLivraison(selectedOrder!.idBonDeCommande ?? 0);

                    if (success) {
                      final newNote = BonDeLivraison(
                        idBonDeLivraison: 0,
                        dateBonDeLivraison: DateTime.now(),
                        description: 'Bon de livraison pour la commande #${selectedOrder!.idBonDeCommande}',
                        agence: selectedOrder!.agence,
                        articles: selectedOrder!.articles
                          ?.map((commandeArticle) => MvtStockArticle(
                                idArticle: commandeArticle.idArticle,
                                quantite: commandeArticle.quantite.toDouble(),
                                article: commandeArticle.article,
                                totalArticle: (commandeArticle.quantite.toDouble() *
                                    (commandeArticle.article?.prix ?? 0)),
                              ))
                          .toList(),
                        total: selectedOrder!.total,
                      );
                      widget.onDeliveryNoteCreated(newNote);
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Bon de livraison pour la commande ${selectedOrder!.idBonDeCommande} créé avec succès !'),
                        ),
                      );
                    } else {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Échec de la création du bon de livraison.'),
                        ),
                      );
                    }
                  } catch (e) {
                    print('Erreur lors de la création du bon de livraison: $e');
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erreur lors de la création: $e')),
                    );
                  }
                },
          style: ElevatedButton.styleFrom(backgroundColor: widget.buttonColor),
          child: const Text(
            'Créer le bon de livraison',
            style: TextStyle(color: Colors.white),
          ),
        )
      ],
    );
  }
}

class ViewDeliveryNoteDialog extends StatelessWidget {
  final BonDeLivraison note;
  final Color buttonColor;
  final Color headerColor;
  final void Function(Uint8List, String) openPdfWeb;

  const ViewDeliveryNoteDialog({
    super.key,
    required this.note,
    required this.buttonColor,
    required this.headerColor,
    required this.openPdfWeb,
  });

  @override
  Widget build(BuildContext context) {
    final bonDeLivraisonService = BonDeLivraisonService();
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Bon de livraison ${note.idBonDeLivraison}'),
          ElevatedButton.icon(
            onPressed: () async {
              try {
                final pdfBytes = await bonDeLivraisonService.generatePdf('livraison', note.idBonDeLivraison ?? 0);
                openPdfWeb(pdfBytes, 'BON_DE_LIVRAISON_1');
              } catch (e) {
                print('Erreur : $e');
              }
            },
            icon: const Icon(Icons.print, size: 16, color: Colors.white),
            label: const Text('Imprimer', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Agence: ${note.agence?.codeAgence ?? ""}', style: const TextStyle(fontWeight: FontWeight.w500)),
              Text('Date: ${DateFormat('dd/MM/yyyy').format(note.dateBonDeLivraison)}', style: const TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 16),
              const Text('Articles:', style: TextStyle(fontWeight: FontWeight.w600)),
              ...(note.articles?.map((item) => Text('${item.article?.intitule ?? ""} - x ${item.quantite} ')) ?? []),
              const SizedBox(height: 16),
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
    );
  }
}

