import 'package:flareline_template/models/bon_de_livraison.dart';
import 'package:flutter/material.dart';
import '../models/facture.dart';
import '../services/factureService.dart';
import '../screens/facture_screen.dart';
import '../screens/invoiceDetail_screen.dart';

import 'package:intl/intl.dart';

class InvoiceScreen extends StatefulWidget {
  const InvoiceScreen({super.key});

  @override
  _InvoiceScreenState createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  List<Facture> invoices = [];
  List<Facture> filteredInvoices = [];
  List<BonDeLivraison> receptions = [];

  String? selectedAgency;
  String? selectedStatus;
  DateTime? selectedDate;

  // Variables pour la pagination
  int currentPage = 1;
  int lastPage = 1;
  int itemsPerPage = 10;
  int totalFactures = 0;

  // Getter pour obtenir les factures paginées
  List<Facture> get paginatedInvoices => filteredInvoices;

  // Getter pour le nombre total de pages
  int get totalPages => filteredInvoices.isEmpty
      ? 0
      : (filteredInvoices.length / itemsPerPage).ceil();

  // Couleurs personnalisées
  final Color buttonColor = Color(0xFFF9B70D);
  final Color headerRowColor = Color.fromARGB(154, 131, 130, 129);
  final Color accentColor = Colors.redAccent;

  final double colNumFacture = 20; // Largeur colonne N° Facture
  final double colDate = 80; // Largeur colonne Date
  final double colAgence = 60; // Largeur colonne Agence
  final double colArticles = 90; // Largeur colonne Articles
  final double colHT = 100; // Largeur colonne HT
  final double colTTC = 100; // Largeur colonne TTC
  final double colActions = 60; // Largeur colonne Actions

  // Calcul de la largeur totale du tableau
  double get tableWidth =>
      colNumFacture +
      colDate +
      colAgence +
      colArticles +
      colHT +
      colTTC +
      colActions +
      (20 * 6);

  Future<void> _loadFactures() async {
    try {
      FactureService factureService = FactureService();
      final response = await factureService.getFactures(
        page: currentPage,
        perPage: itemsPerPage,
      );
      setState(() {
        invoices = response.data;
        filteredInvoices = List.from(invoices);
        currentPage = response.currentPage;
        lastPage = response.lastPage;
        totalFactures = response.total;
      });
    } catch (e) {
      print('Erreur lors de la récupération des factures: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la récupération des factures')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadFactures();
  }

  void _showCreateInvoiceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CreateInvoiceDialog(
          receptions: receptions,
          onInvoiceCreated: (Facture newInvoice) {
            setState(() {
              invoices.add(newInvoice);
              filteredInvoices = List.from(invoices);
              currentPage = 0; // Retour à la première page
            });
          },
        );
      },
    );
  }

  void _showInvoiceDetails(Facture invoice) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => InvoiceDetailScreen(
          invoice: invoice,
          buttonColor: buttonColor,
          headerRowColor: headerRowColor,
          accentColor: accentColor,
        ),
      ),
    );
  }

  void _applyFilters() {
    setState(() {
      filteredInvoices = invoices.where((invoice) {
        bool dateMatch =
            selectedDate == null ||
            invoice.dateFacture ==
                DateFormat('dd/MM/yyyy').format(selectedDate!);
        bool agencyMatch =
            selectedAgency == null ||
            invoice.agence?.codeAgence == selectedAgency;
        return dateMatch && agencyMatch;
      }).toList();
      currentPage = 0; // Retour à la première page après filtrage
    });
  }

  void _clearFilters() {
    setState(() {
      selectedDate = null;
      selectedAgency = null;
      selectedStatus = null;
      filteredInvoices = List.from(invoices);
      currentPage = 0; // Retour à la première page
    });
  }

  // Widget pour la pagination
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
                  _loadFactures();
                },
        ),
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: currentPage == 1
              ? null
              : () {
                  setState(() => currentPage--);
                  _loadFactures();
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
                  _loadFactures();
                },
        ),
        IconButton(
          icon: const Icon(Icons.last_page),
          onPressed: currentPage >= lastPage
              ? null
              : () {
                  setState(() => currentPage = lastPage);
                  _loadFactures();
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
              _loadFactures();
            }
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec bouton créer facture
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: Offset(0, 2),
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
                        'Factures',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Gestion des factures',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: _showCreateInvoiceDialog,
                    icon: Icon(Icons.add, color: Colors.white),
                    label: Text(
                      'Créer Facture',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // Card combinée avec filtres et tableau
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section des filtres
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Liste des factures',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          SizedBox(height: 4),
                    
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: _clearFilters,
                        icon: Icon(
                          Icons.refresh,
                          color: Colors.white,
                          size: 16,
                        ),
                        label: Text(
                          'Filtrer',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonColor,
                          minimumSize: Size(100, 32),
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),

                  // Filtres interactifs
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      // Filtre par date
                      SizedBox(
                        width: 200,
                        child: InkWell(
                          onTap: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now().add(Duration(days: 365)),
                            );
                            if (picked != null) {
                              setState(() {
                                selectedDate = picked;
                              });
                              _applyFilters();
                            }
                          },
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Date',
                              border: OutlineInputBorder(),
                              suffixIcon: Icon(Icons.calendar_today),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            child: Text(
                              selectedDate != null
                                  ? DateFormat(
                                      'dd/MM/yyyy',
                                    ).format(selectedDate!)
                                  : 'Toutes les dates',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                      ),

                      // Filtre par agence
                      SizedBox(
                        width: 200,
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'Agence',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          value: selectedAgency,
                          items: [
                            DropdownMenuItem<String>(
                              value: null,
                              child: Text(
                                'Toutes les agences',
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                            ...[
                              'Agence Paris Centre',
                              'Agence Lyon Nord',
                              'Agence Marseille Sud',
                              'Agence Toulouse Ouest',
                            ].map((agency) {
                              return DropdownMenuItem<String>(
                                value: agency,
                                child: Text(
                                  agency,
                                  style: TextStyle(fontSize: 14),
                                ),
                              );
                            }),
                          ],
                          onChanged: (value) {
                            setState(() {
                              selectedAgency = value;
                            });
                            _applyFilters();
                          },
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 24),

                  Container(
                    width: double.infinity,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth:
                              MediaQuery.of(context).size.width -
                              370, // Occupe toute la largeur
                        ),
                        child: DataTable(
                          columnSpacing: 20,
                          dataRowMinHeight: 48,
                          dataRowMaxHeight: 60,
                          headingRowColor: WidgetStateProperty.all(
                            headerRowColor,
                          ),
                          headingTextStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: const Color.fromARGB(255, 49, 49, 49),
                          ),
                          columns: [
                            DataColumn(
                              label: SizedBox(
                                width: colNumFacture+50,
                                child: Text(
                                  'Reference',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: SizedBox(
                                width: colDate,
                                child: Text(
                                  'Date',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: SizedBox(
                                width: colAgence,
                                child: Text(
                                  'Agence',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: SizedBox(
                                width: colArticles,
                                child: Text(
                                  'Articles',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: SizedBox(
                                width: colHT,
                                child: Text('HT', textAlign: TextAlign.right),
                              ),
                            ),
                            DataColumn(
                              label: SizedBox(
                                width: colTTC,
                                child: Text('TTC', textAlign: TextAlign.right),
                              ),
                            ),
                            DataColumn(
                              label: SizedBox(
                                width: colActions,
                                child: Text(
                                  'Actions',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                          rows: paginatedInvoices.map((invoice) {
                            return DataRow(
                              cells: [
                                DataCell(
                                  SizedBox(
                                    width: colNumFacture+100,
                                    child: Text(
                                      invoice.reference.toString(),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  SizedBox(
                                    width: colDate,
                                    child: Text(
                                      DateFormat(
                                        'dd/MM/yyyy',
                                      ).format(invoice.dateFacture),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  SizedBox(
                                    width: colAgence,
                                    child: Tooltip(
                                      message: invoice.agence?.codeAgence ?? '',
                                      child: Text(
                                        invoice.agence?.codeAgence ?? '',
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  SizedBox(
                                    width: colArticles,
                                    child: Text(
                                      '${invoice.articles.length} articles',
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  SizedBox(
                                    width: colHT,
                                    child: Text(
                                        '${invoice.montant != null ? invoice.montant!.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]} ') : '0.00'} Ar',
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  SizedBox(
                                    width: colTTC,
                                    child: Text(
                                        '${invoice.montantTtc != null ? invoice.montantTtc!.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]} ') : '0.00'} Ar',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  SizedBox(
                                    width: colActions,
                                    child: Center(
                                      child: ElevatedButton(
                                        onPressed: () =>
                                            _showInvoiceDetails(invoice),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: buttonColor,
                                          minimumSize: Size(60, 30),
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 8,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          'Voir',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
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
                  ),

                  SizedBox(height: 16),

                  // Contrôles de pagination
                  _buildPaginationControls(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
