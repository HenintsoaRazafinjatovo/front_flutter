import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(FactureScreen());
}

class FactureScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SMMEC - Gestion des Factures',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: Color(0xFF1E40AF),
        fontFamily: 'Inter',
      ),
      debugShowCheckedModeBanner: false,
      home: InvoiceScreen(),
    );
  }
}

// Modèles de données
class InvoiceItem {
  final String id;
  final String name;
  final int quantity;
  final double unitPrice;
  final double total;
  final String? status;
  final int? quantityReceived;

  InvoiceItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unitPrice,
    required this.total,
    this.status,
    this.quantityReceived,
  });
}

class Invoice {
  final int id;
  final String number;
  final String date;
  final String agency;
  final String agencyAddress;
  final List<InvoiceItem> items;
  final double totalHT;
  final double tva;
  final double totalTTC;
  final String status;
  final String? receptionNumber;
  final String? deliveryNumber;
  final String? deliveryNoteNumber;
  final String? orderNumber;

  Invoice({
    required this.id,
    required this.number,
    required this.date,
    required this.agency,
    required this.agencyAddress,
    required this.items,
    required this.totalHT,
    required this.tva,
    required this.totalTTC,
    required this.status,
    this.receptionNumber,
    this.deliveryNumber,
    this.deliveryNoteNumber,
    this.orderNumber,
  });
}

class Reception {
  final int id;
  final String number;
  final String date;
  final String agency;
  final List<InvoiceItem> items;
  final double total;
  final String status;
  final String? orderNumber;
  final String? deliveryNumber;
  final String? deliveryNoteNumber;

  Reception({
    required this.id,
    required this.number,
    required this.date,
    required this.agency,
    required this.items,
    required this.total,
    required this.status,
    this.orderNumber,
    this.deliveryNumber,
    this.deliveryNoteNumber,
  });
}

class InvoiceScreen extends StatefulWidget {
  const InvoiceScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _InvoiceScreenState createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  List<Invoice> invoices = [];
  List<Invoice> filteredInvoices = [];
  List<Reception> receptions = [];
  
  String? selectedAgency;
  String? selectedStatus;
  DateTime? selectedDate;
  
  // Couleurs personnalisées
  final Color buttonColor = Color(0xFFF9B70D);
  final Color headerRowColor = Color.fromARGB(154, 131, 130, 129);
  final Color accentColor = Colors.redAccent;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    // Données de démonstration pour les bons de réception
    receptions = [
      Reception(
        id: 1,
        number: 'BR-0001',
        date: '18/12/2024',
        agency: 'Agence Lyon Nord',
        items: [
          InvoiceItem(
            id: 'ART-003',
            name: 'Écran 24 pouces',
            quantity: 3,
            quantityReceived: 3,
            unitPrice: 300,
            total: 900,
            status: 'Conforme',
          ),
          InvoiceItem(
            id: 'ART-004',
            name: 'Clavier mécanique',
            quantity: 3,
            quantityReceived: 3,
            unitPrice: 80,
            total: 240,
            status: 'Conforme',
          ),
        ],
        total: 1140,
        status: 'Validé',
        orderNumber: 'CMD-0002',
        deliveryNumber: 'BL-0001',
        deliveryNoteNumber: 'BS-0001',
      ),
    ];

    // Données de démonstration pour les factures
    invoices = [
      Invoice(
        id: 1,
        number: 'FACT-0001',
        date: '19/12/2024',
        agency: 'Agence Lyon Nord',
        agencyAddress: '123 Rue de la République\n69000 Lyon\nFrance',
        items: [
          InvoiceItem(
            id: 'ART-003',
            name: 'Écran 24 pouces',
            quantity: 3,
            unitPrice: 300,
            total: 900,
          ),
          InvoiceItem(
            id: 'ART-004',
            name: 'Clavier mécanique',
            quantity: 3,
            unitPrice: 80,
            total: 240,
          ),
        ],
        totalHT: 1140,
        tva: 228,
        totalTTC: 1368,
        status: 'Émise',
        receptionNumber: 'BR-0001',
        deliveryNumber: 'BL-0001',
        deliveryNoteNumber: 'BS-0001',
        orderNumber: 'CMD-0002',
      ),
    ];

    filteredInvoices = List.from(invoices);
  }

  void _showCreateInvoiceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CreateInvoiceDialog(
          receptions: receptions.where((r) => r.status == 'Validé').toList(),
          onInvoiceCreated: (Invoice newInvoice) {
            setState(() {
              invoices.add(newInvoice);
              filteredInvoices = List.from(invoices);
            });
          },
        );
      },
    );
  }

  void _showInvoiceDetails(Invoice invoice) {
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
            invoice.date == DateFormat('dd/MM/yyyy').format(selectedDate!);
        bool agencyMatch = selectedAgency == null || invoice.agency == selectedAgency;
        bool statusMatch = selectedStatus == null || invoice.status == selectedStatus;
        
        return dateMatch && agencyMatch && statusMatch;
      }).toList();
    });
  }

  void _clearFilters() {
    setState(() {
      selectedDate = null;
      selectedAgency = null;
      selectedStatus = null;
      filteredInvoices = List.from(invoices);
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Brouillon':
        return Colors.grey;
      case 'Émise':
        return Colors.blue;
      case 'Payée':
        return Colors.green;
      case 'Annulée':
        return accentColor;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      // appBar: AppBar(
      //   title: Text('SMMEC - Gestion des Factures'),
      //   backgroundColor: Color(0xFF1E40AF),
      //   elevation: 0,
      // ),
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
                    // ignore: deprecated_member_use
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
                    // ignore: deprecated_member_use
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
                      Text(
                        'Liste des factures',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
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
                        DataColumn(label: Text('Statut')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: filteredInvoices.map((invoice) {
                        return DataRow(
                          cells: [
                            DataCell(Text(
                              invoice.number,
                              style: TextStyle(fontWeight: FontWeight.w500),
                            )),
                            DataCell(Text(invoice.date)),
                            DataCell(Text(invoice.agency)),
                            DataCell(Text('${invoice.items.length} articles')),
                            DataCell(Text('${invoice.totalHT.toStringAsFixed(2)} €')),
                            DataCell(Text(
                              '${invoice.totalTTC.toStringAsFixed(2)} €',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            )),
                            DataCell(
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  // ignore: deprecated_member_use
                                  color: _getStatusColor(invoice.status).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  invoice.status,
                                  style: TextStyle(
                                    color: _getStatusColor(invoice.status),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}

// Dialog pour créer une facture
class CreateInvoiceDialog extends StatefulWidget {
  final List<Reception> receptions;
  final Function(Invoice) onInvoiceCreated;

  const CreateInvoiceDialog({
    super.key,
    required this.receptions,
    required this.onInvoiceCreated,
  });

  @override
  // ignore: library_private_types_in_public_api
  _CreateInvoiceDialogState createState() => _CreateInvoiceDialogState();
}

class _CreateInvoiceDialogState extends State<CreateInvoiceDialog> {
  Reception? selectedReception;
  final Color buttonColor = Color(0xFFF9B70D);
  final Color accentColor = Colors.redAccent;

  String _getAgencyAddress(String agencyName) {
    Map<String, String> addresses = {
      'Agence Paris Centre': '45 Avenue des Champs-Élysées\n75008 Paris\nFrance',
      'Agence Lyon Nord': '123 Rue de la République\n69000 Lyon\nFrance',
      'Agence Marseille Sud': '78 La Canebière\n13001 Marseille\nFrance',
      'Agence Toulouse Ouest': '56 Place du Capitole\n31000 Toulouse\nFrance',
    };
    return addresses[agencyName] ?? 'Adresse non définie';
  }

  void _createInvoice() {
    if (selectedReception == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez sélectionner un bon de réception')),
      );
      return;
    }

    final totalHT = selectedReception!.total;
    final tva = totalHT * 0.20;
    final totalTTC = totalHT + tva;

    final newInvoice = Invoice(
      id: DateTime.now().millisecondsSinceEpoch,
      number: 'FACT-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
      date: DateFormat('dd/MM/yyyy').format(DateTime.now()),
      agency: selectedReception!.agency,
      agencyAddress: _getAgencyAddress(selectedReception!.agency),
      items: selectedReception!.items.map((item) => InvoiceItem(
        id: item.id,
        name: item.name,
        quantity: item.quantityReceived ?? item.quantity,
        unitPrice: item.unitPrice,
        total: (item.quantityReceived ?? item.quantity) * item.unitPrice,
      )).toList(),
      totalHT: totalHT,
      tva: tva,
      totalTTC: totalTTC,
      status: 'Émise',
      receptionNumber: selectedReception!.number,
      deliveryNumber: selectedReception!.deliveryNumber,
      deliveryNoteNumber: selectedReception!.deliveryNoteNumber,
      orderNumber: selectedReception!.orderNumber,
    );

    widget.onInvoiceCreated(newInvoice);
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Facture ${newInvoice.number} créée avec succès !'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('➕ Créer une nouvelle facture'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sélectionner un bon de réception'),
            SizedBox(height: 8),
            DropdownButtonFormField<Reception>(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: '-- Choisir un bon de réception --',
              ),
              value: selectedReception,
              items: widget.receptions.map((reception) {
                return DropdownMenuItem<Reception>(
                  value: reception,
                  child: Text('${reception.number} - ${reception.agency} (${reception.total.toStringAsFixed(2)} € HT)'),
                );
              }).toList(),
              onChanged: (Reception? value) {
                setState(() {
                  selectedReception = value;
                });
              },
            ),
            if (selectedReception != null) ...[
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Aperçu du bon de réception ${selectedReception!.number}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Agence: ${selectedReception!.agency}'),
                              Text('Date: ${selectedReception!.date}'),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            // ignore: deprecated_member_use
                            color: Colors.green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            selectedReception!.status,
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Articles: ${selectedReception!.items.map((item) => '${item.name} (x${item.quantityReceived ?? item.quantity})').join(', ')}',
                    ),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        // ignore: deprecated_member_use
                        color: buttonColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Total HT:'),
                              Text('${selectedReception!.total.toStringAsFixed(2)} €'),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('TVA (20%):'),
                              Text('${(selectedReception!.total * 0.20).toStringAsFixed(2)} €'),
                            ],
                          ),
                          Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total TTC:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '${(selectedReception!.total * 1.20).toStringAsFixed(2)} €',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: buttonColor,
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
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _createInvoice,
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonColor,
          ),
          child: Text(
            'Créer la facture',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}

// Écran de détail de facture
class InvoiceDetailScreen extends StatelessWidget {
  final Invoice invoice;
  final Color buttonColor;
  final Color headerRowColor;
  final Color accentColor;

  const InvoiceDetailScreen({super.key, 
    required this.invoice,
    required this.buttonColor,
    required this.headerRowColor,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(' ${invoice.number}'),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.print),
            onPressed: () {
              // Logique d'impression
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Impression de la facture...')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec logo SMMEC
            Container(
              padding: EdgeInsets.all(24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo SMMEC
                  Container(
                    padding: EdgeInsets.all(16),
                    // decoration: BoxDecoration(
                    //   color: headerRowColor,
                    //   borderRadius: BorderRadius.circular(8),
                    // ),
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/logo1.png',
                          width: 200,
                          // height: 60,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'FACTURE',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          invoice.number,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color:buttonColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Date d\'émission',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        invoice.date,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Informations expéditeur et destinataire
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(16),
                    margin: EdgeInsets.only(right: 8),
                    // decoration: BoxDecoration(
                    //   color: Colors.grey[50],
                    //   // borderRadius: BorderRadius.circular(8),
                    //   // border: Border.all(color: Colors.grey[300]!),
                    // ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Expéditeur',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'SMMEC - SA',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: accentColor,
                          ),
                        ),
                        Text(
                          'Ampasanimalo',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        Text(
                          'Antananarivo, Madagascar',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Contact: 22-290-69',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        Text(
                          'NIF: 2000013087',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        Text(
                          'STAT: 66191 11 2006 0 00542',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(16),
                    margin: EdgeInsets.only(left: 8),
                    // decoration: BoxDecoration(
                    //   color: Colors.blue[50],
                    //   // borderRadius: BorderRadius.circular(8),
                    //   // border: Border.all(color: Colors.blue[200]!),
                    // ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Destinataire',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          invoice.agency,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: accentColor,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          invoice.agencyAddress,
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 24),

            // Traçabilité des documents
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.yellow[50],
                // borderRadius: BorderRadius.circular(8),
                // border: Border.all(color: Colors.yellow[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.link, color: buttonColor),
                      SizedBox(width: 8),
                      Text(
                        'Traçabilité des documents',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: [
                      if (invoice.orderNumber != null)
                        _buildTraceabilityItem('Commande', invoice.orderNumber!),
                      if (invoice.deliveryNoteNumber != null)
                        _buildTraceabilityItem('Bon de sortie', invoice.deliveryNoteNumber!),
                      if (invoice.deliveryNumber != null)
                        _buildTraceabilityItem('Bon de livraison', invoice.deliveryNumber!),
                      if (invoice.receptionNumber != null)
                        _buildTraceabilityItem('Bon de réception', invoice.receptionNumber!),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // Tableau des articles
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Détail des articles',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      // En-tête du tableau
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: headerRowColor,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                'ID Article',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                'Désignation',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                'Qté',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'Prix unitaire',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'Montant',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Lignes du tableau
                      ...invoice.items.asMap().entries.map((entry) {
                        int index = entry.key;
                        InvoiceItem item = entry.value;
                        
                        return Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: index % 2 == 0 ? Colors.white : Colors.grey[50],
                            border: Border(
                              bottom: BorderSide(color: Colors.grey[300]!),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  item.id,
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(item.name),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  '${item.quantity}',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  '${item.unitPrice.toStringAsFixed(2)} €',
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  '${item.total.toStringAsFixed(2)} €',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 24),

            // Totaux
            Row(
              children: [
                Spacer(),
                Container(
                  width: 300,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total HT:',
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            '${invoice.totalHT.toStringAsFixed(2)} €',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'TVA (20%):',
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            '${invoice.tva.toStringAsFixed(2)} €',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Divider(thickness: 2, color: Color(0xFF1E40AF)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total TTC:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${invoice.totalTTC.toStringAsFixed(2)} €',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E40AF),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 24),

            // Informations de paiement
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Conditions de paiement',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Paiement à 30 jours fin de mois',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  Text(
                    'RIB: FR76 1234 5678 9012 3456 78',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // Boutons d'action
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Impression de la facture...')),
                      );
                    },
                    icon: Icon(Icons.print, color: Colors.white),
                    label: Text(
                      'Imprimer',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    label: Text(
                      'Retour à la liste',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[600],
                      padding: EdgeInsets.symmetric(vertical: 16),
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
      ),
    );
  }

  Widget _buildTraceabilityItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label:',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E40AF),
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}