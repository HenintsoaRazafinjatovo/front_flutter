import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminCommandeScreen extends StatefulWidget {
  const AdminCommandeScreen({super.key});

  @override
  State<AdminCommandeScreen> createState() => _AdminCommandeScreenState();
}

class _AdminCommandeScreenState extends State<AdminCommandeScreen> {
  String selectedStatusFilter = '';
  String selectedAgencyFilter = '';
  
  // Données de démonstration
  List<Commande> orders = [
    Commande(
      id: 1,
      number: 'CMD-0001',
      date: '15/12/2024',
      agency: 'Agence Paris Centre',
      items: [
        CommandeItem(name: 'Ordinateur portable', quantity: 2, unitPrice: 1200, total: 2400),
        CommandeItem(name: 'Souris sans fil', quantity: 5, unitPrice: 25, total: 125),
      ],
      total: 2525,
      status: CommandeStatus.enAttente,
    ),
    Commande(
      id: 2,
      number: 'CMD-0002',
      date: '14/12/2024',
      agency: 'Agence Lyon Nord',
      items: [
        CommandeItem(name: 'Écran 24 pouces', quantity: 3, unitPrice: 300, total: 900),
        CommandeItem(name: 'Clavier mécanique', quantity: 3, unitPrice: 80, total: 240),
      ],
      total: 1140,
      status: CommandeStatus.validee,
    ),
    Commande(
      id: 3,
      number: 'CMD-0003',
      date: '13/12/2024',
      agency: 'Agence Marseille Sud',
      items: [
        CommandeItem(name: 'Imprimante laser', quantity: 1, unitPrice: 250, total: 250),
      ],
      total: 250,
      status: CommandeStatus.rejetee,
    ),
    Commande(
      id: 4,
      number: 'CMD-0004',
      date: '12/12/2024',
      agency: 'Agence Toulouse Ouest',
      items: [
        CommandeItem(name: 'Casque audio', quantity: 10, unitPrice: 60, total: 600),
        CommandeItem(name: 'Webcam HD', quantity: 5, unitPrice: 45, total: 225),
      ],
      total: 825,
      status: CommandeStatus.enAttente,
    ),
    Commande(
      id: 5,
      number: 'CMD-0005',
      date: '11/12/2024',
      agency: 'Agence Paris Centre',
      items: [
        CommandeItem(name: 'Tablette graphique', quantity: 2, unitPrice: 150, total: 300),
        CommandeItem(name: 'Disque dur externe', quantity: 4, unitPrice: 90, total: 360),
      ],
      total: 660,
      status: CommandeStatus.validee,
    ),
  ];

  List<Commande> get filteredOrders {
    return orders.where((order) {
      final statusMatch = selectedStatusFilter.isEmpty || 
          order.status.displayName == selectedStatusFilter;
      final agencyMatch = selectedAgencyFilter.isEmpty || 
          order.agency == selectedAgencyFilter;
      return statusMatch && agencyMatch;
    }).toList();
  }

  List<Commande> get pendingOrders {
    return orders.where((order) => order.status == CommandeStatus.enAttente).toList();
  }

  int get pendingCount => orders.where((o) => o.status == CommandeStatus.enAttente).length;
  int get validatedCount => orders.where((o) => o.status == CommandeStatus.validee).length;
  int get rejectedCount => orders.where((o) => o.status == CommandeStatus.rejetee).length;
  int get totalCount => orders.length;

  void validateOrder(Commande order) {
    setState(() {
      order.status = CommandeStatus.validee;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Commande ${order.number} validée avec succès !')),
    );
  }

  void rejectOrder(Commande order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rejeter la commande'),
        content: const Text('Êtes-vous sûr de vouloir rejeter cette commande ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                order.status = CommandeStatus.rejetee;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Commande ${order.number} rejetée')),
              );
            },
            child: const Text('Rejeter', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void showOrderDetails(Commande order) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: 600,
          constraints: const BoxConstraints(maxHeight: 600),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Détails de la commande ${order.number}',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Informations générales
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F7FA),
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
                              Text('Numéro de commande', 
                                style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54)),
                              Text(order.number, 
                                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Date', 
                                style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54)),
                              Text(order.date, 
                                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Agence', 
                                style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54)),
                              Text(order.agency, 
                                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Statut', 
                                style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54)),
                              _buildStatusChip(order.status),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Articles
              Text(
                'Articles commandés',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              
              Flexible(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(flex: 3, child: Text('Article', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 12))),
                            Expanded(flex: 1, child: Text('Qté', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 12))),
                            Expanded(flex: 2, child: Text('Prix unit.', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 12))),
                            Expanded(flex: 2, child: Text('Total', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 12))),
                          ],
                        ),
                      ),
                      ...order.items.map((item) => Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border(top: BorderSide(color: Colors.grey.shade200)),
                        ),
                        child: Row(
                          children: [
                            Expanded(flex: 3, child: Text(item.name, style: GoogleFonts.poppins(fontSize: 12))),
                            Expanded(flex: 1, child: Text('${item.quantity}', style: GoogleFonts.poppins(fontSize: 12))),
                            Expanded(flex: 2, child: Text('${item.unitPrice.toStringAsFixed(2)} €', style: GoogleFonts.poppins(fontSize: 12))),
                            Expanded(flex: 2, child: Text('${item.total.toStringAsFixed(2)} €', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600))),
                          ],
                        ),
                      )).toList(),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Total
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total de la commande:',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      '${order.total.toStringAsFixed(2)} €',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (order.status == CommandeStatus.enAttente) ...[
                    ElevatedButton(
                      onPressed: () {
                        validateOrder(order);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      child: const Text('Valider'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        rejectOrder(order);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      child: const Text('Rejeter'),
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (order.status == CommandeStatus.validee) ...[
                    ElevatedButton(
                      onPressed: () {
                        // Créer bon de sortie
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Bon de sortie créé')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0C8D68),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      child: const Text('📋 Bon de sortie'),
                    ),
                    const SizedBox(width: 8),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void clearFilters() {
    setState(() {
      selectedStatusFilter = '';
      selectedAgencyFilter = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 12, 
                    offset: Offset(0, 6),
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
                        ' Administration - Gestion des Commandes',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Text(
                      //   'Gérez et validez les commandes des agences',
                      //   style: GoogleFonts.poppins(
                      //     fontSize: 16,
                      //     color: Colors.black54,
                      //   ),
                      // ),
                    ],
                  ),
                  // Column(
                  //   crossAxisAlignment: CrossAxisAlignment.end,
                  //   children: [
                  //     Text(
                  //       'Connecté en tant que',
                  //       style: GoogleFonts.poppins(
                  //         fontSize: 12,
                  //         color: Colors.black54,
                  //       ),
                  //     ),
                  //     Text(
                  //       'Équipe Logistique',
                  //       style: GoogleFonts.poppins(
                  //         fontSize: 16,
                  //         fontWeight: FontWeight.w600,
                  //         color: const Color(0xFF0C8D68),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Statistiques
            Row(
              children: [
                Expanded(child: _buildStatCard(Icons.access_time, 'En attente', pendingCount, Colors.orange)),
                const SizedBox(width: 16),
                Expanded(child: _buildStatCard(Icons.check, 'Validées', validatedCount, Colors.green)),
                const SizedBox(width: 16),
                Expanded(child: _buildStatCard(Icons.cancel, 'Rejetées', rejectedCount, Colors.red)),
                const SizedBox(width: 16),
                Expanded(child: _buildStatCard(Icons.inventory_2, 'Total', totalCount, const Color(0xFF0C8D68))),
              ],
            ),

            const SizedBox(height: 24),

            // Commandes en attente
            if (pendingOrders.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 12,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Commandes en attente de validation',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildOrdersTable(pendingOrders, showActions: true),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Toutes les commandes
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Historique complet des commandes',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Filtres
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedStatusFilter.isEmpty ? null : selectedStatusFilter,
                          decoration: const InputDecoration(
                            labelText: 'Tous les statuts',
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF0C8D68)),
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          items: CommandeStatus.values.map((status) {
                            return DropdownMenuItem(
                              value: status.displayName,
                              child: Text(status.displayName),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedStatusFilter = value ?? '';
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedAgencyFilter.isEmpty ? null : selectedAgencyFilter,
                          decoration: const InputDecoration(
                            labelText: 'Toutes les agences',
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF0C8D68)),
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          items: [
                            'Agence Paris Centre',
                            'Agence Lyon Nord',
                            'Agence Marseille Sud',
                            'Agence Toulouse Ouest',
                          ].map((agency) {
                            return DropdownMenuItem(
                              value: agency,
                              child: Text(agency),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedAgencyFilter = value ?? '';
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: clearFilters,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFF9B70D),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        child: const Text('Réinitialiser'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildOrdersTable(filteredOrders, showStatus: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

    Widget _buildStatCard(IconData icon, String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              icon,
              size: 24,
              color: color,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
              Text(
                count.toString(),
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildOrdersTable(List<Commande> orders, {bool showActions = false, bool showStatus = false}) {
    if (orders.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Text(
            'Aucune commande trouvée',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
          
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color.fromARGB(154, 131, 130, 129),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row (
              children: [
                Expanded(flex: 2, child: Text('N° Commande', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15))),
                Expanded(flex: 2, child: Text('Date', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15))),
                Expanded(flex: 3, child: Text('Agence', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15))),
                Expanded(flex: 2, child: Text('Articles', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15))),
                Expanded(flex: 2, child: Text('Total', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15))),
                if (showStatus) 
                  Expanded(flex: 2, child: Text('Statut', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15))),
                Expanded(flex: 3, child: Text('Actions', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15))),
              ],
              
            ),
          ),
          
          // Rows
          ...orders.map((order) => Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                Expanded(flex: 2, child: Text(order.number, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600))),
                Expanded(flex: 2, child: Text(order.date, style: GoogleFonts.poppins(fontSize: 15))),
                Expanded(flex: 3, child: Text(order.agency, style: GoogleFonts.poppins(fontSize: 15))),
                Expanded(flex: 2, child: Text('${order.items.length} article${order.items.length > 1 ? 's' : ''}', style: GoogleFonts.poppins(fontSize: 15))),
                Expanded(flex: 2, child: Text('${order.total.toStringAsFixed(2)} €', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600))),
                if (showStatus)
                  Expanded(flex: 2, child: _buildStatusChip(order.status)),
                Expanded(
                  flex: 3,
                  child: Row(
                    children: [
                      _buildActionButton(Icons.more_horiz_sharp, const Color.fromARGB(255, 132, 134, 134), () => showOrderDetails(order)),
                      if (showActions && order.status == CommandeStatus.enAttente) ...[
                        const SizedBox(width: 4),
                        _buildActionButton(Icons.check_circle, Colors.green, () => validateOrder(order)),
                        const SizedBox(width: 4),
                        _buildActionButton(Icons.cancel, Colors.red, () => rejectOrder(order)),
                      ],
                      if (order.status == CommandeStatus.validee) ...[
                        const SizedBox(width: 4),
                        _buildActionButton(Icons.receipt, const Color(0xFF0C8D68), () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Bon de sortie créé')),
                          );
                        }),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildStatusChip(CommandeStatus status) {
    Color backgroundColor;
    Color textColor;
    
    switch (status) {
      case CommandeStatus.enAttente:
        backgroundColor = Colors.orange.shade100;
        textColor = Colors.orange.shade700;
        break;
      case CommandeStatus.validee:
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade700;
        break;
      case CommandeStatus.rejetee:
        backgroundColor = Colors.red.shade100;
        textColor = Colors.red.shade700;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.displayName,
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  // Widget _buildActionButton(String text, Color color, VoidCallback onPressed) {
  //   return SizedBox(
  //     height: 28,
  //     child: ElevatedButton(
  //       onPressed: onPressed,
  //       style: ElevatedButton.styleFrom(
  //         backgroundColor: color,
  //         foregroundColor: Colors.white,
  //         padding: const EdgeInsets.symmetric(horizontal: 8),
  //         minimumSize: Size.zero,
  //         textStyle: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w500),
  //       ),
  //       child: Text(text),
  //     ),
  //   );
  // }
    Widget _buildActionButton(IconData icon, Color color, VoidCallback onPressed) {
    return SizedBox(
      height: 28,
      width: 28, // Tu peux ajuster la largeur si nécessaire
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6), // facultatif : arrondir un peu le bouton
          ),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 16,
        ),
      ),
    );
  }

}

// Models
class Commande {
  final int id;
  final String number;
  final String date;
  final String agency;
  final List<CommandeItem> items;
  final double total;
  CommandeStatus status;

  Commande({
    required this.id,
    required this.number,
    required this.date,
    required this.agency,
    required this.items,
    required this.total,
    required this.status,
  });
}

class CommandeItem {
  final String name;
  final int quantity;
  final double unitPrice;
  final double total;

  CommandeItem({
    required this.name,
    required this.quantity,
    required this.unitPrice,
    required this.total,
  });
}

enum CommandeStatus {
  enAttente,
  validee,
  rejetee;

  String get displayName {
    switch (this) {
      case CommandeStatus.enAttente:
        return 'En attente';
      case CommandeStatus.validee:
        return 'Validée';
      case CommandeStatus.rejetee:
        return 'Rejetée';
    }
  }
}