import 'package:flareline_template/models/bon_de_commande.dart';
import 'package:flareline_template/services/bon_de_commandeService.dart';
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
  int currentPage = 1;
  int lastPage = 1;
  int itemsPerPage = 10;
  int totalCommandes = 0;
  List<BonDeCommande> orders = [];
  List<BonDeCommande> ordersEnAttente = [];

 // Getter pour obtenir les commandes paginées de la page courante
  List<BonDeCommande> get paginatedCommandes => orders;
  
  // Getter pour le nombre total de pages
  int get totalPages => (orders.length / itemsPerPage).ceil();
  List<BonDeCommande> get filteredOrders {
    return orders.where((order) {
      final statusMatch = selectedStatusFilter.isEmpty || 
          order.status_commande == selectedStatusFilter;
      final agencyMatch = selectedAgencyFilter.isEmpty || 
          (order.agence?.codeAgence ?? '') == selectedAgencyFilter; // Fix here too
      return statusMatch && agencyMatch;
    }).toList();
  }
  int get pendingCount => orders.where((o) => o.status_commande == 'En attente').length;
  int get validatedCount => orders.where((o) => o.status_commande == 'Validée').length;
  int get rejectedCount => orders.where((o) => o.status_commande == 'Rejetée').length;
  int get totalCount => orders.length;

  Future<void> validateOrder(BonDeCommande order) async {
    try {
      await BonDeCommandeService().validerBonDeCommande(order.idBonDeCommande!);
      setState(() {
        order.status_commande = 'Validee';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Commande ${order.idBonDeCommande} validée avec succès !')),
      );
      // Optionally refresh the lists
       await _loadCommandes();
      await _loadCommandesEnAttente();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la validation : $e')),
      );
    }
  }
   Future<void> _loadCommandes() async {
    try {
      final paginated = await BonDeCommandeService()
          .getBonDeCommandeWithStatus(page: currentPage, perPage: itemsPerPage);
      setState(() {
        orders = paginated.data; // Use the correct property from PaginatedResponse
        currentPage = paginated.currentPage;
        lastPage = paginated.lastPage;
        totalCommandes = paginated.total;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur de chargement des bons de commande: $e")),
      );
    }
  }
  Future<void> _loadCommandesEnAttente() async {
    try {
      final loadedCommandes = await BonDeCommandeService().getBonDeCommandeWithStatusEnAttente();
      setState(() {
        ordersEnAttente = loadedCommandes.cast<BonDeCommande>();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur de chargement des bons de commande: $e")),
      );
    }
  }
  @override
  void initState() {
    super.initState();
     _loadCommandes();
    _loadCommandesEnAttente();
  }
  Future<void> rejectOrder(BonDeCommande order) async {
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
            onPressed: () async {
              Navigator.pop(context);
              try {
                final messenger = ScaffoldMessenger.of(context);
                await BonDeCommandeService().rejeterBonDeCommande(order.idBonDeCommande!);
                if (!mounted) return;
                messenger.showSnackBar(
                  SnackBar(content: Text('Commande ${order.idBonDeCommande} rejetée avec succès !')),
                );
                // await _loadCommandes();
                await _loadCommandesEnAttente();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erreur lors du rejet : $e')),
                );
              }
            },
            child: const Text('Rejeter', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
void showOrderDetails(BonDeCommande order) {
  // Vérifier si un article demandé dépasse le stock disponible
  bool hasInsufficientStock = order.articles?.any((item) {
        final int qte = item.quantite.toInt();
        final int stock = (item.article?.stockActuel ?? 0).toInt();
        return qte > stock;
      }) ??
      false;

  showDialog(
    context: context,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 1000,
        constraints: const BoxConstraints(maxHeight: 600),
        padding: const EdgeInsets.all(24),
        child: Scrollbar(
          thumbVisibility: true,
          child: SingleChildScrollView(
            primary: true,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- HEADER ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Détails de la commande ${order.idBonDeCommande}',
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
                                Text('Réference de commande',
                                    style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.black54)),
                                Text(order.reference.toString(),
                                    style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Date',
                                    style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.black54)),
                                Text(order.dateBonDeCommande.toString(),
                                    style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600)),
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
                                    style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.black54)),
                                Text(order.agence?.codeAgence ?? 'N/A',
                                    style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Status',
                                    style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.black54)),
                                _buildStatusChip(order.status_commande ?? 'En attente'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),


                const SizedBox(height: 20),

               Text(
                  'Articles commandés',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),

                Container(
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
                            Expanded(
                                flex: 3,
                                child: Text('Article',
                                    style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12))),
                            Expanded(
                                flex: 3,
                                child: Text('Qté commandée',
                                    style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12))),
                            Expanded(
                                flex: 3,
                                child: Text('Qté en stock',
                                    style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12))),
                            Expanded(
                                flex: 2,
                                child: Text('Prix unit.',
                                    style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12))),
                            Expanded(
                                flex: 2,
                                child: Text('Total',
                                    style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12))),
                          ],
                        ),
                      ),
                      if (order.articles != null &&
                          order.articles!.isNotEmpty)
                        ...order.articles!.map((item) {
                          bool insufficient =
                              item.quantite >
                              (item.article?.stockActuel ?? 0);
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border(
                                  top: BorderSide(
                                      color: Colors.grey.shade200)),
                              color: insufficient
                                  ? Colors.red.shade50
                                  : null, // 🔴 surligner si insuffisant
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                    flex: 3,
                                    child: Text(
                                        item.article?.intitule ??
                                            'Article non spécifié',
                                        style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: insufficient
                                                ? Colors.red
                                                : Colors.black))),
                                Expanded(
                                    flex: 3,
                                    child: Text('${item.quantite}',
                                        style: GoogleFonts.poppins(
                                            fontSize: 12))),
                                Expanded(
                                    flex: 3,
                                    child: Text(
                                        '${item.article?.stockActuel}',
                                        style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: insufficient
                                                ? Colors.red
                                                : Colors.black))),
                                Expanded(
                                    flex: 2,
                                    child: Text(
                                        '${(item.prixUnitaire ?? item.article?.prix ?? 0.0).toStringAsFixed(2)}',
                                        style: GoogleFonts.poppins(
                                            fontSize: 12))),
                                Expanded(
                                    flex: 2,
                                    child: Text(
                                        '${item.totalArticle.toStringAsFixed(2)}',
                                        style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600))),
                              ],
                            ),
                          );
                        })
                      else
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border(
                                top: BorderSide(
                                    color: Colors.grey.shade200)),
                          ),
                          child: Center(
                            child: Text(
                              'Aucun article trouvé pour cette commande',
                              style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // --- TOTAL ---
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
                        '${order.total?.toStringAsFixed(2) ?? '0.00'}',
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

                // --- ACTIONS ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (order.status_commande == 'En attente') ...[
                      ElevatedButton(
                        onPressed: hasInsufficientStock
                            ? null // 🔴 désactivé uniquement si en attente & stock insuffisant
                            : () {
                                validateOrder(order);
                                Navigator.pop(context);
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: hasInsufficientStock
                              ? Colors.grey
                              : Colors.green.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                        child: const Text('Rejeter'),
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (order.status_commande == 'Validee' &&
                        order.bon_de_sortie == false) ...[
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Bon de sortie créé')),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0C8D68),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                        child: const Text('Bon de sortie'),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ],
                ),

                // ⚠️ Message seulement si stock insuffisant ET commande en attente
                if (order.status_commande == 'En attente' &&
                    hasInsufficientStock) ...[
                  const SizedBox(height: 12),
                  Text(
                    "⚠️ Impossible de valider : quantité demandée supérieure au stock disponible.",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
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
                    ],
                  ),
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
            if (ordersEnAttente.isNotEmpty) ...[
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
                    _buildOrdersTable(ordersEnAttente, showActions: true),
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
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedStatusFilter.isEmpty ? null : selectedStatusFilter,
                          decoration: const InputDecoration(
                            labelText: 'Tous les statuts',
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color.fromARGB(255, 0, 1, 1)),
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            items: [
                            'En attente',
                            'Validée',
                            'Rejetée',
                            ].map((status) {
                            return DropdownMenuItem(
                              value: status,
                              child: Text(status),
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
                  _buildPaginationControls(),
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


  Widget _buildOrdersTable(List<BonDeCommande> orders, {bool showActions = false, bool showStatus = false}) {
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
                Expanded(flex: 4, child: Text('N° Commande', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15))),
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
          
          // Rows - FIXED: Added null check for agence
          ...orders.map((order) => Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                Expanded(flex: 4, child: Text(order.reference ?? ' ', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600))),
                Expanded(
                  flex: 2,
                  child: Text(
                  order.dateBonDeCommande != null
                    ? "${order.dateBonDeCommande.year.toString().padLeft(4, '0')}/${order.dateBonDeCommande.month.toString().padLeft(2, '0')}/${order.dateBonDeCommande.day.toString().padLeft(2, '0')}"
                    : '',
                  style: GoogleFonts.poppins(fontSize: 15),
                  ),
                ),
                // FIXED: Use null-aware operator instead of null assertion operator
                Expanded(flex: 3, child: Text(order.agence?.codeAgence ?? 'N/A', style: GoogleFonts.poppins(fontSize: 15))),
                Expanded(
                  flex: 2,
                  child: Text(
                    '${order.nbArticle ?? 0} article${(order.nbArticle ?? 0) > 1 ? 's' : ''}',
                    style: GoogleFonts.poppins(fontSize: 15),
                  ),
                ),
                Expanded(flex: 2, child: Text('${order.total?.toStringAsFixed(2) ?? '0.00'} ', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600))),
                if (showStatus)
                  Expanded(flex: 2, child: _buildStatusChip(order.status_commande ?? 'En attente')),
                Expanded(
                  flex: 3,
                  child: Row(
                    children: [
                      _buildActionButton(Icons.remove_red_eye,  Color(0xFFF9B70D), () => showOrderDetails(order)),
                      if (showActions && order.status_commande == 'En attente') ...[
                        const SizedBox(width: 4),
                        _buildActionButton(Icons.check_circle, Colors.green, () => validateOrder(order)),
                        const SizedBox(width: 4),
                        _buildActionButton(Icons.cancel, Colors.red, () => rejectOrder(order)),
                      ],
                      // if (order.status_commande == 'Validée') ...[
                      //   const SizedBox(width: 4),
                      //   _buildActionButton(Icons.receipt, const Color(0xFF0C8D68), () {
                      //     ScaffoldMessenger.of(context).showSnackBar(
                      //       const SnackBar(content: Text('Bon de sortie créé')),
                      //     );
                      //   }),
                      // ],
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

  Widget _buildStatusChip(String status) {
    Color backgroundColor = Colors.grey.shade200;
    Color textColor = Colors.black54;
    
    switch (status) {
      case 'En attente':
        backgroundColor = Colors.orange.shade100;
        textColor = Colors.orange.shade700;
        break;
      case 'Validée':
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade700;
        break;
      case 'Rejetée':
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
        status,
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, Color color, VoidCallback onPressed) {
    return SizedBox(
      height: 28,
      width: 28,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
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

