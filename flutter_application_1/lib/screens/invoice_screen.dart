// import 'package:flareline_template/models/bon_de_livraison.dart';
// import 'package:flutter/material.dart';
// import '../models/facture.dart'; // <-- Add this import for MvtStockArticle
// import '../services/factureService.dart';
// import '../screens/facture_screen.dart';
// import '../screens/invoiceDetail_screen.dart';

// import 'package:intl/intl.dart';

// class InvoiceScreen extends StatefulWidget {
//   const InvoiceScreen({super.key});

//   @override
//   // ignore: library_private_types_in_public_api
//   _InvoiceScreenState createState() => _InvoiceScreenState();
// }

// class _InvoiceScreenState extends State<InvoiceScreen> {
//   List<Facture> invoices = [];
//   List<Facture> filteredInvoices = [];
//   List<BonDeLivraison> receptions = [];
  
//   String? selectedAgency;
//   String? selectedStatus;
//   DateTime? selectedDate;
  
//   // Couleurs personnalisées
//   final Color buttonColor = Color(0xFFF9B70D);
//   final Color headerRowColor = Color.fromARGB(154, 131, 130, 129);
//   final Color accentColor = Colors.redAccent;

// Future<void> _loadFactures() async {
//     try {
//       FactureService factureService = FactureService();
//       List<Facture> fetchedInvoices = await factureService.getFactures();
//       setState(() {
//         invoices = fetchedInvoices;
//         filteredInvoices = List.from(invoices);
//       });
//     } catch (e) {
//       print('Erreur lors de la récupération des factures: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Erreur lors de la récupération des factures')),
//       );
//     }
//   }
//   @override
//   void initState() {
//     super.initState();
//     _loadFactures();
//   }
//   void _showCreateInvoiceDialog() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return CreateInvoiceDialog(
//           receptions: receptions,
//           onInvoiceCreated: (Facture newInvoice) {
//             setState(() {
//               invoices.add(newInvoice);
//               filteredInvoices = List.from(invoices);
//             });
//           },
//         );
//       },
//     );
//   }

//   void _showInvoiceDetails(Facture invoice) {
//     Navigator.of(context).push(
//       MaterialPageRoute(
//         builder: (context) => InvoiceDetailScreen(
//           invoice: invoice,
//           buttonColor: buttonColor,
//           headerRowColor: headerRowColor,
//           accentColor: accentColor,
//         ),
//       ),
//     );
//   }

//   void _applyFilters() {
//     setState(() {
//       filteredInvoices = invoices.where((invoice) {
//         bool dateMatch = selectedDate == null ||
//             invoice.dateFacture == DateFormat('dd/MM/yyyy').format(selectedDate!);
//         bool agencyMatch = selectedAgency == null || invoice.agence?.codeAgence == selectedAgency;
//       return dateMatch && agencyMatch;
//       }).toList();
//     });
//   }

//   void _clearFilters() {
//     setState(() {
//       selectedDate = null;
//       selectedAgency = null;
//       selectedStatus = null;
//       filteredInvoices = List.from(invoices);
//     });
//   }

//   // Color _getStatusColor(String status) {
//   //   switch (status) {
//   //     case 'Brouillon':
//   //       return Colors.grey;
//   //     case 'Émise':
//   //       return Colors.blue;
//   //     case 'Payée':
//   //       return Colors.green;
//   //     case 'Annulée':
//   //       return accentColor;
//   //     default:
//   //       return Colors.grey;
//   //   }
//   // }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       // appBar: AppBar(
//       //   title: Text('SMMEC - Gestion des Factures'),
//       //   backgroundColor: Color(0xFF1E40AF),
//       //   elevation: 0,
//       // ),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // En-tête avec bouton créer facture
//             Container(
//               padding: EdgeInsets.all(24),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(12),
//                 boxShadow: [
//                   BoxShadow(
//                     // ignore: deprecated_member_use
//                     color: Colors.grey.withOpacity(0.1),
//                     spreadRadius: 1,
//                     blurRadius: 5,
//                     offset: Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Factures',
//                         style: TextStyle(
//                           fontSize: 24,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.grey[800],
//                         ),
//                       ),
//                       SizedBox(height: 8),
//                       Text(
//                         'Gestion des factures',
//                         style: TextStyle(
//                           color: Colors.grey[600],
//                           fontSize: 16,
//                         ),
//                       ),
//                     ],
//                   ),
//                   ElevatedButton.icon(
//                     onPressed: _showCreateInvoiceDialog,
//                     icon: Icon(Icons.add, color: Colors.white),
//                     label: Text(
//                       'Créer Facture',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: buttonColor,
//                       padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             SizedBox(height: 24),

//             // Card combinée avec filtres et tableau
//             Container(
//               padding: EdgeInsets.all(24),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(12),
//                 boxShadow: [
//                   BoxShadow(
//                     // ignore: deprecated_member_use
//                     color: Colors.grey.withOpacity(0.1),
//                     spreadRadius: 1,
//                     blurRadius: 5,
//                     offset: Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Section des filtres
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         'Liste des factures',
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.grey[800],
//                         ),
//                       ),
//                       ElevatedButton.icon(
//                         onPressed: _clearFilters,
//                         icon: Icon(Icons.refresh, color: Colors.white, size: 16),
//                         label: Text(
//                           'Réinitialiser',
//                           style: TextStyle(color: Colors.white, fontSize: 12),
//                         ),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: headerRowColor,
//                           minimumSize: Size(100, 32),
//                           padding: EdgeInsets.symmetric(horizontal: 12),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(6),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 16),
                  
//                   // Filtres interactifs
//                   Wrap(
//                     spacing: 16,
//                     runSpacing: 16,
//                     children: [
//                       // Filtre par date
//                       SizedBox(
//                         width: 200,
//                         child: InkWell(
//                           onTap: () async {
//                             final DateTime? picked = await showDatePicker(
//                               context: context,
//                               initialDate: selectedDate ?? DateTime.now(),
//                               firstDate: DateTime(2020),
//                               lastDate: DateTime.now().add(Duration(days: 365)),
//                             );
//                             if (picked != null) {
//                               setState(() {
//                                 selectedDate = picked;
//                               });
//                               _applyFilters();
//                             }
//                           },
//                           child: InputDecorator(
//                             decoration: InputDecoration(
//                               labelText: 'Date',
//                               border: OutlineInputBorder(),
//                               suffixIcon: Icon(Icons.calendar_today),
//                               contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                             ),
//                             child: Text(
//                               selectedDate != null
//                                   ? DateFormat('dd/MM/yyyy').format(selectedDate!)
//                                   : 'Toutes les dates',
//                               style: TextStyle(fontSize: 14),
//                             ),
//                           ),
//                         ),
//                       ),

//                       // Filtre par agence
//                       SizedBox(
//                         width: 200,
//                         child: DropdownButtonFormField<String>(
//                           decoration: InputDecoration(
//                             labelText: 'Agence',
//                             border: OutlineInputBorder(),
//                             contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                           ),
//                           value: selectedAgency,
//                           items: [
//                             DropdownMenuItem<String>(
//                               value: null,
//                               child: Text('Toutes les agences', style: TextStyle(fontSize: 14)),
//                             ),
//                             ...['Agence Paris Centre', 'Agence Lyon Nord', 'Agence Marseille Sud', 'Agence Toulouse Ouest']
//                                 .map((agency) {
//                               return DropdownMenuItem<String>(
//                                 value: agency,
//                                 child: Text(agency, style: TextStyle(fontSize: 14)),
//                               );
//                             }),
//                           ],
//                           onChanged: (value) {
//                             setState(() {
//                               selectedAgency = value;
//                             });
//                             _applyFilters();
//                           },
//                         ),
//                       ),

//                       // Filtre par statut
//                       SizedBox(
//                         width: 180,
//                         child: DropdownButtonFormField<String>(
//                           decoration: InputDecoration(
//                             labelText: 'Statut',
//                             border: OutlineInputBorder(),
//                             contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                           ),
//                           value: selectedStatus,
//                           items: [
//                             DropdownMenuItem<String>(
//                               value: null,
//                               child: Text('Tous les statuts', style: TextStyle(fontSize: 14)),
//                             ),
//                             ...['Brouillon', 'Émise', 'Payée', 'Annulée'].map((status) {
//                               return DropdownMenuItem<String>(
//                                 value: status,
//                                 child: Text(status, style: TextStyle(fontSize: 14)),
//                               );
//                             }),
//                           ],
//                           onChanged: (value) {
//                             setState(() {
//                               selectedStatus = value;
//                             });
//                             _applyFilters();
//                           },
//                         ),
//                       ),
//                     ],
//                   ),
                  
//                   SizedBox(height: 24),
                  
//                   // Tableau des factures
//                   SingleChildScrollView(
//                     scrollDirection: Axis.horizontal,
//                     child: DataTable(
//                       headingRowColor: WidgetStateProperty.all(headerRowColor),
//                       headingTextStyle: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: const Color.fromARGB(255, 49, 49, 49),
//                       ),
//                       columns: [
//                         DataColumn(label: Text('N° Facture')),
//                         DataColumn(label: Text('Date')),
//                         DataColumn(label: Text('Agence')),
//                         DataColumn(label: Text('Articles')),
//                         DataColumn(label: Text('HT')),
//                         DataColumn(label: Text('TTC')),
//                         // DataColumn(label: Text('Statut')),
//                         DataColumn(label: Text('Actions')),
//                       ],
//                       rows: filteredInvoices.map((invoice) {
//                         return DataRow(
//                           cells: [
//                             DataCell(Text(
//                               invoice.idFacture.toString(),
//                               style: TextStyle(fontWeight: FontWeight.w500),
//                             )),
//                             DataCell(Text(DateFormat('dd/MM/yyyy').format(invoice.dateFacture))),
//                             DataCell(Text(invoice.agence?.codeAgence ?? '')),
//                             DataCell(Text('${invoice.articles.length} articles')),
//                             DataCell(Text('${invoice.montant != null ? invoice.montant!.toStringAsFixed(2) : '0.00'} Ar')),
//                             DataCell(Text(
//                               '${invoice.montantTtc != null ? invoice.montantTtc!.toStringAsFixed(2) : '0.00'} Ar',
//                               style: TextStyle(fontWeight: FontWeight.w500),
//                             )),
//                             //DataCell(
//                             //   Container(
//                             //     padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                             //     decoration: BoxDecoration(
//                             //       // ignore: deprecated_member_use
//                             //       color: _getStatusColor(invoice.status).withOpacity(0.2),
//                             //       borderRadius: BorderRadius.circular(12),
//                             //     ),
//                             //     child: Text(
//                             //       invoice.status,
//                             //       style: TextStyle(
//                             //         color: _getStatusColor(invoice.status),
//                             //         fontWeight: FontWeight.bold,
//                             //         fontSize: 12,
//                             //       ),
//                             //     ),
//                             //   ),
//                             // ),
//                             DataCell(
//                               ElevatedButton(
//                                 onPressed: () => _showInvoiceDetails(invoice),
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: buttonColor,
//                                   minimumSize: Size(60, 30),
//                                   padding: EdgeInsets.symmetric(horizontal: 8),
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(6),
//                                   ),
//                                 ),
//                                 child: Text(
//                                   'Voir',
//                                   style: TextStyle(color: Colors.white),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         );
//                       }).toList(),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

// }
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
  int currentPage = 0;
  int itemsPerPage = 10;
  
  // Getter pour obtenir les factures paginées
  List<Facture> get paginatedInvoices {
    final startIndex = currentPage * itemsPerPage;
    final endIndex = (startIndex + itemsPerPage).clamp(0, filteredInvoices.length);
    
    if (startIndex >= filteredInvoices.length) return [];
    return filteredInvoices.sublist(startIndex, endIndex);
  }
  
  // Getter pour le nombre total de pages
  int get totalPages => filteredInvoices.isEmpty ? 0 : (filteredInvoices.length / itemsPerPage).ceil();
  
  // Couleurs personnalisées
  final Color buttonColor = Color(0xFFF9B70D);
  final Color headerRowColor = Color.fromARGB(154, 131, 130, 129);
  final Color accentColor = Colors.redAccent;

  Future<void> _loadFactures() async {
    try {
      FactureService factureService = FactureService();
      List<Facture> fetchedInvoices = await factureService.getFactures();
      setState(() {
        invoices = fetchedInvoices;
        filteredInvoices = List.from(invoices);
        currentPage = 0; // Réinitialiser à la première page
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
        bool dateMatch = selectedDate == null ||
            invoice.dateFacture == DateFormat('dd/MM/yyyy').format(selectedDate!);
        bool agencyMatch = selectedAgency == null || invoice.agence?.codeAgence == selectedAgency;
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
    if (filteredInvoices.isEmpty || totalPages <= 1) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.first_page),
            onPressed: currentPage == 0
                ? null
                : () => setState(() => currentPage = 0),
            tooltip: 'Première page',
          ),
          
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: currentPage == 0
                ? null
                : () => setState(() => currentPage--),
            tooltip: 'Page précédente',
          ),
          
          const SizedBox(width: 16),
          
          ...List.generate(totalPages, (index) {
            if (totalPages <= 7 ||
                index == 0 ||
                index == totalPages - 1 ||
                (index >= currentPage - 1 && index <= currentPage + 1)) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: InkWell(
                  onTap: () => setState(() => currentPage = index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: currentPage == index
                          ? buttonColor
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: currentPage == index ? Colors.white : Colors.black87,
                        fontWeight: currentPage == index
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            } else if (index == currentPage - 2 || index == currentPage + 2) {
              return const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Text('...'),
              );
            }
            return const SizedBox.shrink();
          }),
          
          const SizedBox(width: 16),
          
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: currentPage >= totalPages - 1
                ? null
                : () => setState(() => currentPage++),
            tooltip: 'Page suivante',
          ),
          
          IconButton(
            icon: const Icon(Icons.last_page),
            onPressed: currentPage >= totalPages - 1
                ? null
                : () => setState(() => currentPage = totalPages - 1),
            tooltip: 'Dernière page',
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
                  currentPage = 0;
                });
              }
            },
          ),
        ],
      ),
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
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
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
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
                          Text(
                            'Total: ${filteredInvoices.length} facture(s)',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: _clearFilters,
                        icon: Icon(Icons.refresh, color: Colors.white, size: 16),
                        label: Text(
                          'Réinitialiser',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: headerRowColor,
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
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            child: Text(
                              selectedDate != null
                                  ? DateFormat('dd/MM/yyyy').format(selectedDate!)
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
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          value: selectedAgency,
                          items: [
                            DropdownMenuItem<String>(
                              value: null,
                              child: Text('Toutes les agences', style: TextStyle(fontSize: 14)),
                            ),
                            ...['Agence Paris Centre', 'Agence Lyon Nord', 'Agence Marseille Sud', 'Agence Toulouse Ouest']
                                .map((agency) {
                              return DropdownMenuItem<String>(
                                value: agency,
                                child: Text(agency, style: TextStyle(fontSize: 14)),
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

                      // Filtre par statut
                      SizedBox(
                        width: 180,
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'Statut',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          value: selectedStatus,
                          items: [
                            DropdownMenuItem<String>(
                              value: null,
                              child: Text('Tous les statuts', style: TextStyle(fontSize: 14)),
                            ),
                            ...['Brouillon', 'Émise', 'Payée', 'Annulée'].map((status) {
                              return DropdownMenuItem<String>(
                                value: status,
                                child: Text(status, style: TextStyle(fontSize: 14)),
                              );
                            }),
                          ],
                          onChanged: (value) {
                            setState(() {
                              selectedStatus = value;
                            });
                            _applyFilters();
                          },
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 24),
                  
                  // Tableau des factures
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(headerRowColor),
                      headingTextStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 49, 49, 49),
                      ),
                      columns: [
                        DataColumn(label: Text('N° Facture')),
                        DataColumn(label: Text('Date')),
                        DataColumn(label: Text('Agence')),
                        DataColumn(label: Text('Articles')),
                        DataColumn(label: Text('HT')),
                        DataColumn(label: Text('TTC')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: paginatedInvoices.map((invoice) {
                        return DataRow(
                          cells: [
                            DataCell(Text(
                              invoice.idFacture.toString(),
                              style: TextStyle(fontWeight: FontWeight.w500),
                            )),
                            DataCell(Text(DateFormat('dd/MM/yyyy').format(invoice.dateFacture))),
                            DataCell(Text(invoice.agence?.codeAgence ?? '')),
                            DataCell(Text('${invoice.articles.length} articles')),
                            DataCell(Text('${invoice.montant != null ? invoice.montant!.toStringAsFixed(2) : '0.00'} Ar')),
                            DataCell(Text(
                              '${invoice.montantTtc != null ? invoice.montantTtc!.toStringAsFixed(2) : '0.00'} Ar',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            )),
                            DataCell(
                              ElevatedButton(
                                onPressed: () => _showInvoiceDetails(invoice),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: buttonColor,
                                  minimumSize: Size(60, 30),
                                  padding: EdgeInsets.symmetric(horizontal: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                child: Text(
                                  'Voir',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                  
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