import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(BonDeSortieScreen());
}

class BonDeSortieScreen extends StatelessWidget {
  const BonDeSortieScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestion Bon de Sortie',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: Colors.grey[50],
      ),
      home: DeliveryNotesScreen(),
    );
  }
}

class DeliveryNotesScreen extends StatefulWidget {
  const DeliveryNotesScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _DeliveryNotesScreenState createState() => _DeliveryNotesScreenState();
}

class _DeliveryNotesScreenState extends State<DeliveryNotesScreen> {
  final Color buttonColor = Color(0xFFF9B70D);
  final Color headerColor = Color.fromARGB(154, 131, 130, 129);
  final Color accentColor = Colors.redAccent;

  List<Order> orders = [
    Order(
      id: 1,
      number: 'CMD-0001',
      date: DateTime.parse('2024-12-15'),
      agency: 'Agence Aina',
      items: [
        OrderItem(name: 'PV de stockage', quantity: 2, unitPrice: 1200, total: 2400),
        OrderItem(name: 'ORDRE DE VIREMENT', quantity: 5, unitPrice: 25, total: 125),
      ],
      total: 2525,
      status: 'Validée',
    ),
    Order(
      id: 2,
      number: 'CMD-0002',
      date: DateTime.parse('2024-12-14'),
      agency: 'Agence Farimbotsoa',
      items: [
        OrderItem(name: 'Fiche de pret', quantity: 3, unitPrice: 300, total: 900),
        OrderItem(name: 'MPP', quantity: 3, unitPrice: 80, total: 240),
      ],
      total: 1140,
      status: 'Validée',
    ),
    Order(
      id: 5,
      number: 'CMD-0005',
      date: DateTime.parse('2024-12-11'),
      agency: 'Agence Aina',
      items: [
        OrderItem(name: 'Bordereau RIA', quantity: 2, unitPrice: 150, total: 300),
        OrderItem(name: 'PV de CIC', quantity: 4, unitPrice: 90, total: 360),
      ],
      total: 660,
      status: 'Validée',
    ),
  ];

  List<DeliveryNote> deliveryNotes = [
    DeliveryNote(
      id: 1,
      number: 'BS-0001',
      date: DateTime.parse('2024-12-16'),
      orderId: 2,
      orderNumber: 'CMD-0002',
      agency: 'Agence Vonjy',
      items: [
        OrderItem(name: 'Carnet vert CAE', quantity: 3, unitPrice: 300, total: 900),
        OrderItem(name: 'Carnet de bord', quantity: 3, unitPrice: 80, total: 240),
      ],
      total: 1140,
      createdBy: 'Équipe Logistique',
    ),
  ];

  List<DeliveryNote> filteredDeliveryNotes = [];
  DateTime? dateFilter;
  String? agencyFilter;
  Order? currentOrder;

  @override
  void initState() {
    super.initState();
    filteredDeliveryNotes = List.from(deliveryNotes);
  }

  void _showCreateModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CreateDeliveryNoteDialog(
          orders: orders,
          buttonColor: buttonColor,
          onDeliveryNoteCreated: (DeliveryNote note) {
            setState(() {
              deliveryNotes.add(note);
              filteredDeliveryNotes = List.from(deliveryNotes);
            });
          },
        );
      },
    );
  }

  void _showViewModal(DeliveryNote note) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ViewDeliveryNoteDialog(
          note: note,
          buttonColor: buttonColor,
          headerColor: headerColor,
        );
      },
    );
  }

  void _applyFilters() {
    setState(() {
      filteredDeliveryNotes = deliveryNotes.where((note) {
        bool dateMatch = dateFilter == null ||
            DateFormat('dd/MM/yyyy').format(note.date) ==
                DateFormat('dd/MM/yyyy').format(dateFilter!);
        bool agencyMatch = agencyFilter == null ||
            agencyFilter!.isEmpty ||
            note.agency == agencyFilter;
        return dateMatch && agencyMatch;
      }).toList();
    });
  }

  void _clearFilters() {
    setState(() {
      dateFilter = null;
      agencyFilter = null;
      filteredDeliveryNotes = List.from(deliveryNotes);
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
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Header
                Container(
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
                  padding: EdgeInsets.all(24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bon de Sortie',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Gestion des sorties de stock',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: _showCreateModal,
                        icon: Icon(Icons.add, color: Colors.white),
                        label: Text(
                          'Créer Bon de Sortie',
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
                
                // Delivery Notes List
                Expanded(
                  child: Container(
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
                    padding: EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Liste des bons de sortie',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                        
                        SizedBox(height: 16),
                        
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
                                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey[300]!),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                                      SizedBox(width: 8),
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
                            SizedBox(width: 16),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: agencyFilter,
                                decoration: InputDecoration(
                                  hintText: 'Toutes les agences',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                                items: [
                                  DropdownMenuItem(value: null, child: Text('Toutes les agences')),
                                  DropdownMenuItem(value: 'Agence Aina', child: Text('Agence Aina')),
                                  DropdownMenuItem(value: 'Agence Farimbotsoa', child: Text('Agence Farimbotsoa')),
                                  DropdownMenuItem(value: 'Agence Vonjy', child: Text('Agence Vonjy')),
                                  DropdownMenuItem(value: 'Agence Fanavotana', child: Text('Agence Fanavotana')),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    agencyFilter = value;
                                  });
                                },
                              ),
                            ),
                            SizedBox(width: 16),
                            ElevatedButton(
                              onPressed: _applyFilters,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: buttonColor,
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                              child: Text('Filtrer', style: TextStyle(color: Colors.white)),
                            ),
                            SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: _clearFilters,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[500],
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                              child: Text('Réinitialiser', style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                        
                        SizedBox(height: 24),
                        
                        // Table
                        Expanded(
                          child: SingleChildScrollView(
                            child: DataTable(
                              headingRowColor: WidgetStateProperty.all(headerColor),
                              showCheckboxColumn: false,
                              columns: [
                                DataColumn(label: Text('N° Bon', style: TextStyle(fontWeight: FontWeight.w600))),
                                DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.w600))),
                                DataColumn(label: Text('Commande', style: TextStyle(fontWeight: FontWeight.w600))),
                                DataColumn(label: Text('Agence', style: TextStyle(fontWeight: FontWeight.w600))),
                                DataColumn(label: Text('Articles', style: TextStyle(fontWeight: FontWeight.w600))),
                                DataColumn(label: Text('Total', style: TextStyle(fontWeight: FontWeight.w600))),
                                DataColumn(label: SizedBox(width: 120, child: Text('Actions', style: TextStyle(fontWeight: FontWeight.w600)))),
                              ],
                              rows: filteredDeliveryNotes.map((note) {
                                return DataRow(
                                  cells: [
                                    DataCell(Text(note.number, style: TextStyle(fontWeight: FontWeight.w500))),
                                    DataCell(Text(DateFormat('dd/MM/yyyy').format(note.date))),
                                    DataCell(Text(note.orderNumber)),
                                    DataCell(Text(note.agency)),
                                    DataCell(Text('${note.items.length} article${note.items.length > 1 ? 's' : ''}')),
                                    DataCell(Text('${note.total.toStringAsFixed(2)} €', style: TextStyle(fontWeight: FontWeight.w500))),
                                    DataCell(
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ElevatedButton(
                                            onPressed: () => _showViewModal(note),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: buttonColor,
                                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                              minimumSize: Size(80, 0),
                                            ),
                                            child: Text('Voir', style: TextStyle(color: Colors.white, fontSize: 12)),
                                          ),
                                          SizedBox(width: 8),
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

// Modèles de données
class Order {
  final int id;
  final String number;
  final DateTime date;
  final String agency;
  final List<OrderItem> items;
  final double total;
  final String status;

  Order({
    required this.id,
    required this.number,
    required this.date,
    required this.agency,
    required this.items,
    required this.total,
    required this.status,
  });
}

class OrderItem {
  final String name;
  final int quantity;
  final double unitPrice;
  final double total;

  OrderItem({
    required this.name,
    required this.quantity,
    required this.unitPrice,
    required this.total,
  });
}

class DeliveryNote {
  final int id;
  final String number;
  final DateTime date;
  final int orderId;
  final String orderNumber;
  final String agency;
  final List<OrderItem> items;
  final double total;
  final String createdBy;

  DeliveryNote({
    required this.id,
    required this.number,
    required this.date,
    required this.orderId,
    required this.orderNumber,
    required this.agency,
    required this.items,
    required this.total,
    required this.createdBy,
  });
}

// Dialog pour créer un nouveau bon de sortie
class CreateDeliveryNoteDialog extends StatefulWidget {
  final List<Order> orders;
  final Color buttonColor;
  final Function(DeliveryNote) onDeliveryNoteCreated;

  const CreateDeliveryNoteDialog({super.key, 
    required this.orders,
    required this.buttonColor,
    required this.onDeliveryNoteCreated,
  });

  @override
  // ignore: library_private_types_in_public_api
  _CreateDeliveryNoteDialogState createState() => _CreateDeliveryNoteDialogState();
}

class _CreateDeliveryNoteDialogState extends State<CreateDeliveryNoteDialog> {
  Order? selectedOrder;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('➕ Créer un nouveau bon de sortie'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sélectionner une commande validée', style: TextStyle(fontWeight: FontWeight.w500)),
            SizedBox(height: 8),
            DropdownButtonFormField<Order>(
              value: selectedOrder,
              decoration: InputDecoration(
                hintText: '-- Choisir une commande --',
                border: OutlineInputBorder(),
              ),
              items: widget.orders
                  .where((order) => order.status == 'Validée')
                  .map((order) => DropdownMenuItem(
                        value: order,
                        child: Text('${order.number} - ${order.agency} (${order.total.toStringAsFixed(2)} €)'),
                      ))
                  .toList(),
              onChanged: (Order? order) {
                setState(() {
                  selectedOrder = order;
                });
              },
            ),
            if (selectedOrder != null) ...[
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Aperçu de la commande ${selectedOrder!.number}',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    SizedBox(height: 8),
                    Text('Agence: ${selectedOrder!.agency}'),
                    Text('Date: ${DateFormat('dd/MM/yyyy').format(selectedOrder!.date)}'),
                    Text('Articles: ${selectedOrder!.items.map((item) => '${item.name} (x${item.quantity})').join(', ')}'),
                    Text('Total: ${selectedOrder!.total.toStringAsFixed(2)} €',
                        style: TextStyle(fontWeight: FontWeight.bold)),
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
          onPressed: selectedOrder == null
              ? null
              : () {
                  final newNote = DeliveryNote(
                    id: DateTime.now().millisecondsSinceEpoch,
                    number: 'BS-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
                    date: DateTime.now(),
                    orderId: selectedOrder!.id,
                    orderNumber: selectedOrder!.number,
                    agency: selectedOrder!.agency,
                    items: List.from(selectedOrder!.items),
                    total: selectedOrder!.total,
                    createdBy: 'Équipe Logistique',
                  );
                  widget.onDeliveryNoteCreated(newNote);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Bon de sortie ${newNote.number} créé avec succès !')),
                  );
                },
          style: ElevatedButton.styleFrom(backgroundColor: widget.buttonColor),
          child: Text('Créer le bon de sortie', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}

// Dialog pour voir les détails d'un bon de sortie
class ViewDeliveryNoteDialog extends StatelessWidget {
  final DeliveryNote note;
  final Color buttonColor;
  final Color headerColor;

  const ViewDeliveryNoteDialog({super.key, 
    required this.note,
    required this.buttonColor,
    required this.headerColor,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Bon de sortie ${note.number}'),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Impression de ${note.number}')),
              );
            },
            icon: Icon(Icons.print, size: 16, color: Colors.white),
            label: Text('Imprimer', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
              // Informations générales
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('N° Bon de sortie', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                              Text(note.number, style: TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Date de sortie', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                              Text(DateFormat('dd/MM/yyyy').format(note.date), style: TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Commande liée', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                              Text(note.orderNumber, style: TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Agence destinataire', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                              Text(note.agency, style: TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Créé par', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                              Text(note.createdBy, style: TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 16),
              
              // Articles
              Text('Articles sortis', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              SizedBox(height: 8),
              
              DataTable(
                headingRowColor: WidgetStateProperty.all(headerColor),
                columns: [
                  DataColumn(label: Text('Article', style: TextStyle(fontWeight: FontWeight.w600))),
                  DataColumn(label: Text('Quantité', style: TextStyle(fontWeight: FontWeight.w600))),
                  DataColumn(label: Text('Prix unitaire', style: TextStyle(fontWeight: FontWeight.w600))),
                  DataColumn(label: Text('Total', style: TextStyle(fontWeight: FontWeight.w600))),
                ],
                rows: note.items.map((item) {
                  return DataRow(
                    cells: [
                      DataCell(Text(item.name)),
                      DataCell(Text(item.quantity.toString())),
                      DataCell(Text('${item.unitPrice.toStringAsFixed(2)} €')),
                      DataCell(Text('${item.total.toStringAsFixed(2)} €', style: TextStyle(fontWeight: FontWeight.w500))),
                    ],
                  );
                }).toList(),
              ),
              
              SizedBox(height: 16),
              Divider(),
              
              // Total
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total de la sortie:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  Text(
                    '${note.total.toStringAsFixed(2)} €',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green[700]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Fermer'),
        ),
      ],
    );
  }
}