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
  List<BonDeLivraison> livraisons = [];
  List<BonDeCommande> orders = [];
  List<BonDeLivraison> filteredDeliveryNotes = [];
  List<Agence> agences = [];
  DateTime? dateFilter;
  int? agencyFilter;
  BonDeCommande? selectedOrder;
  String message = "";

  @override
  void initState() {
    super.initState();
    _loadLivraisons();
    _loadCommandes();
    _loadAgences();
  }

  Future<void> _loadLivraisons() async {
    try {
      final loadedLivraisons = await BonDeLivraisonService().getBonDeLivraisonWithDetails();
      setState(() {
        livraisons = loadedLivraisons;
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
  // final blob = html.Blob([pdfBytes], 'application/pdf');
  // final url = html.Url.createObjectUrlFromBlob(blob);

  // // Ouvre le PDF dans un nouvel onglet
  // html.window.open(url, filename);

  // // Libère l'URL une fois ouvert
  // html.Url.revokeObjectUrl(url);
    final blob = html.Blob([pdfBytes], 'application/pdf');
  final url = html.Url.createObjectUrlFromBlob(blob);

  html.AnchorElement(href: url)
    ..setAttribute("download", filename) // Nom du fichier
    ..click(); // Simule le clic pour lancer le téléchargement

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
          openPdfWeb: openPdfWeb, // Pass the openPdfWeb function
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
                
                // Delivery Notes List
                Expanded(
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
                        
                        // Filters
                        Row(
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
                                value: agencyFilter, // ⚠️ maintenant c’est un idAgence (int?), pas un String
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
                                        child: Text(agence.codeAgence),
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
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Table
                        Expanded(
                          child: SingleChildScrollView(
                            child: DataTable(
                              headingRowColor: MaterialStateProperty.all(headerColor),
                              showCheckboxColumn: false,
                              columns: const [
                                DataColumn(label: Text('N° Bon', style: TextStyle(fontWeight: FontWeight.w600))),
                                DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.w600))),
                                // DataColumn(label: Text('Commande', style: TextStyle(fontWeight: FontWeight.w600))),
                                DataColumn(label: Text('Agence', style: TextStyle(fontWeight: FontWeight.w600))),
                                DataColumn(label: Text('Articles', style: TextStyle(fontWeight: FontWeight.w600))),
                                DataColumn(label: SizedBox(width: 120, child: Text('Actions', style: TextStyle(fontWeight: FontWeight.w600)))),
                              ],
                              rows: filteredDeliveryNotes.map((note) {
                                return DataRow(
                                  cells: [
                                    DataCell(Text('${note.idBonDeLivraison}', style: const TextStyle(fontWeight: FontWeight.w500))),
                                    DataCell(Text(DateFormat('dd/MM/yyyy').format(note.dateBonDeLivraison))),
                                    // DataCell(Text(note.orderNumber)),
                                    DataCell(Text(note.agence?.codeAgence ?? "")),
                                    DataCell(Text('${note.articles?.length ?? 0} article${(note.articles?.length ?? 0) > 1 ? 's' : ''}')),
                                    DataCell(
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ElevatedButton(
                                            onPressed: () => _showViewModal(note),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: buttonColor,
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                              minimumSize: const Size(80, 0),
                                            ),
                                            child: const Text('Voir', style: TextStyle(color: Colors.white, fontSize: 12)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
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

// --- Dialog pour créer un nouveau bon de livraison ---
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
                        child: Text('${order.idBonDeCommande} - ${order.agence?.codeAgence ?? ""} (${order.total != null ? order.total!.toStringAsFixed(2) : '0.00'} )'),
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
                    Text('Date: ${DateFormat('dd/MM/yyyy').format(selectedOrder!.dateBonDeCommande)}'),
                    Text('Articles: ${(selectedOrder!.articles?.map((item) => '${item.article?.intitule ?? ""} (x${item.quantite})').join(', ')) ?? ''}'),
                    Text('Total: ${selectedOrder!.total != null ? selectedOrder!.total!.toStringAsFixed(2) : '0.00'} ', style: const TextStyle(fontWeight: FontWeight.bold)),
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
            // Appel API pour créer le bon de livraison
            final success = await BonDeLivraisonService()
                .creerBonDeLivraison(selectedOrder!.idBonDeCommande ?? 0);

            if (success) {
              // Ici on ne reçoit plus un BonDeLivraison complet depuis l’API,
              // donc on peut soit reconstruire un objet local minimal,
              // soit simplement notifier le succès.

              // Exemple : créer un objet local factice
              final newNote = BonDeLivraison(
                idBonDeLivraison: 0, // pas d'ID car API ne le retourne pas
                dateBonDeLivraison: DateTime.now(),
                description:
                    'Bon de livraison pour la commande #${selectedOrder!.idBonDeCommande}',
                agence: selectedOrder!.agence,
                articles: selectedOrder!.articles
                  ?.map((commandeArticle) => MvtStockArticle(
                        idArticle: commandeArticle.idArticle,
                        quantite: commandeArticle.quantite.toDouble(), // ⚡ cast en double
                        article: commandeArticle.article, // si CommandeArticle a un champ Article
                        totalArticle: (commandeArticle.quantite.toDouble() *
                            (commandeArticle.article?.prix ?? 0)), // optionnel
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
// --- Dialog pour voir les détails d'un bon de livraison ---
class ViewDeliveryNoteDialog extends StatelessWidget {
  final BonDeLivraison note;
  final Color buttonColor;
  final Color headerColor;
  final void Function(Uint8List, String) openPdfWeb; // Add openPdf callback

  const ViewDeliveryNoteDialog({
    super.key,
    required this.note,
    required this.buttonColor,
    required this.headerColor,
    required this.openPdfWeb, // Require openPdf in constructor
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
            onPressed:  () async {
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
              // Text('Commande: ${note.orderNumber}', style: const TextStyle(fontWeight: FontWeight.w500)),
              Text('Agence: ${note.agence?.codeAgence ?? ""}', style: const TextStyle(fontWeight: FontWeight.w500)),
              Text('Date: ${DateFormat('dd/MM/yyyy').format(note.dateBonDeLivraison)}', style: const TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 16),
              const Text('Articles:', style: TextStyle(fontWeight: FontWeight.w600)),
              ...(note.articles?.map((item) => Text('${item.article?.intitule ?? ""} - x ${item.quantite} ')) ?? []),
              const SizedBox(height: 16),
              // Text('Total: ${note.total!.toStringAsFixed(2)} ', style: const TextStyle(fontWeight: FontWeight.bold)),
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


