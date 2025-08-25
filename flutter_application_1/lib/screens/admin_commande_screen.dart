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
  List<BonDeCommande> orders = [];
  List<BonDeCommande> ordersEnAttente = [];


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
  int get validatedCount => orders.where((o) => o.status_commande == 'Validee').length;
  int get rejectedCount => orders.where((o) => o.status_commande == 'Rejetee').length;
  int get totalCount => orders.length;

  void validateOrder(BonDeCommande order) {
    setState(() {
      order.status_commande = 'Validee';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Commande ${order.idBonDeCommande} validee avec succès !')),
    );
  }
   Future<void> _loadCommandes() async {
    try {
      final loadedCommandes = await BonDeCommandeService().getBonDeCommandeWithStatus();
      setState(() {
        orders = loadedCommandes.cast<BonDeCommande>();
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
  void rejectOrder(BonDeCommande order) {
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
                order.status_commande = 'Rejetee';
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Commande ${order.idBonDeCommande} Rejetee')),
              );
            },
            child: const Text('Rejeter', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // void showOrderDetails(BonDeCommande order) {
  //   showDialog(
  //     context: context,
  //     builder: (context) => Dialog(
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  //       child: Container(
  //         width: 600,
  //         constraints: const BoxConstraints(maxHeight: 600),
  //         padding: const EdgeInsets.all(24),
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //               children: [
  //                 Text(
  //                   'Détails de la commande ${order.idBonDeCommande}',
  //                   style: GoogleFonts.poppins(
  //                     fontSize: 20,
  //                     fontWeight: FontWeight.bold,
  //                     color: Colors.black87,
  //                   ),
  //                 ),
  //                 IconButton(
  //                   onPressed: () => Navigator.pop(context),
  //                   icon: const Icon(Icons.close),
  //                 ),
  //               ],
  //             ),
  //             const SizedBox(height: 20),
              
  //             // Informations générales
  //             Container(
  //               padding: const EdgeInsets.all(16),
  //               decoration: BoxDecoration(
  //                 color: const Color(0xFFF5F7FA),
  //                 borderRadius: BorderRadius.circular(8),
  //               ),
  //               child: Column(
  //                 children: [
  //                   Row(
  //                     children: [
  //                       Expanded(
  //                         child: Column(
  //                           crossAxisAlignment: CrossAxisAlignment.start,
  //                           children: [
  //                             Text('Numéro de commande', 
  //                               style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54)),
  //                             Text(order.idBonDeCommande.toString(), 
  //                               style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
  //                           ],
  //                         ),
  //                       ),
  //                       Expanded(
  //                         child: Column(
  //                           crossAxisAlignment: CrossAxisAlignment.start,
  //                           children: [
  //                             Text('Date', 
  //                               style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54)),
  //                             Text(order.dateBonDeCommande.toString(), 
  //                               style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
  //                           ],
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                   const SizedBox(height: 12),
  //                   Row(
  //                     children: [
  //                       Expanded(
  //                         child: Column(
  //                           crossAxisAlignment: CrossAxisAlignment.start,
  //                           children: [
  //                             Text('Agence', 
  //                               style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54)),
  //                             Text(order.agence?.codeAgence ?? 'N/A', 
  //                               style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
  //                           ],
  //                         ),
  //                       ),
  //                       Expanded(
  //                         child: Column(
  //                           crossAxisAlignment: CrossAxisAlignment.start,
  //                           children: [
  //                             Text('Status', 
  //                               style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54)),
  //                             _buildStatusChip(order.status_commande),
  //                           ],
  //                         ),  
  //                       ),
  //                     ],
  //                   ),
  //                 ],
  //               ),
  //             ),
              
  //             const SizedBox(height: 20),
              
  //             // Articles
  //             Text(
  //               'Articles commandés',
  //               style: GoogleFonts.poppins(
  //                 fontSize: 16,
  //                 fontWeight: FontWeight.bold,
  //                 color: Colors.black87,
  //               ),
  //             ),
  //             const SizedBox(height: 12),
              
  //             Flexible(
  //               child: Container(
  //                 decoration: BoxDecoration(
  //                   border: Border.all(color: Colors.grey.shade300),
  //                   borderRadius: BorderRadius.circular(8),
  //                 ),
  //                 child: Column(
  //                   children: [
  //                     Container(
  //                       padding: const EdgeInsets.all(12),
  //                       decoration: BoxDecoration(
  //                         color: Colors.grey.shade50,
  //                         borderRadius: const BorderRadius.only(
  //                           topLeft: Radius.circular(8),
  //                           topRight: Radius.circular(8),
  //                         ),
  //                       ),
  //                       child: Row(
  //                         children: [
  //                           Expanded(flex: 3, child: Text('Article', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 12))),
  //                           Expanded(flex: 1, child: Text('Qté', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 12))),
  //                           Expanded(flex: 2, child: Text('Prix unit.', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 12))),
  //                           Expanded(flex: 2, child: Text('Total', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 12))),
  //                         ],
  //                       ),
  //                     ),
  //                     // Fix null check for articles with better handling
  //                     if (order.articles != null && order.articles!.isNotEmpty)
  //                       ...order.articles!.map((item) => Container(
  //                         padding: const EdgeInsets.all(12),
  //                         decoration: BoxDecoration(
  //                           border: Border(top: BorderSide(color: Colors.grey.shade200)),
  //                         ),
  //                         child: Row(
  //                           children: [
  //                             // Utiliser intitule de ArticleCommande d'abord, puis celui de Article
  //                             Expanded(flex: 3, child: Text(
  //                               item.article?.intitule ?? item.article?.intitule ?? 'Article non spécifié', 
  //                               style: GoogleFonts.poppins(fontSize: 12)
  //                             )),
  //                             Expanded(flex: 1, child: Text('${item.quantite}', style: GoogleFonts.poppins(fontSize: 12))),
  //                             // Utiliser prixUnitaire de ArticleCommande d'abord, puis prix de Article
  //                             Expanded(flex: 2, child: Text(
  //                               '${(item.prixUnitaire ?? item.article?.prix ?? 0.0).toStringAsFixed(2)} ', 
  //                               style: GoogleFonts.poppins(fontSize: 12)
  //                             )),
  //                             Expanded(flex: 2, child: Text('${item.totalArticle.toStringAsFixed(2)} ', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600))),
  //                           ],
  //                         ),
  //                       )).toList()
  //                     else
  //                       Container(
  //                         padding: const EdgeInsets.all(12),
  //                         decoration: BoxDecoration(
  //                           border: Border(top: BorderSide(color: Colors.grey.shade200)),
  //                         ),
  //                         child: Center(
  //                           child: Text(
  //                             'Aucun article trouvé pour cette commande',
  //                             style: GoogleFonts.poppins(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey),
  //                           ),
  //                         ),
  //                       ),
  //                   ],
  //                 ),
  //               ),
  //             ),
              
  //             const SizedBox(height: 16),
              
  //             // Total
  //             Container(
  //               padding: const EdgeInsets.all(16),
  //               decoration: BoxDecoration(
  //                 border: Border.all(color: Colors.grey.shade300),
  //                 borderRadius: BorderRadius.circular(8),
  //               ),
  //               child: Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                 children: [
  //                   Text(
  //                     'Total de la commande:',
  //                     style: GoogleFonts.poppins(
  //                       fontSize: 16,
  //                       fontWeight: FontWeight.bold,
  //                       color: Colors.black87,
  //                     ),
  //                   ),
  //                   Text(
  //                     '${order.total?.toStringAsFixed(2) ?? '0.00'} ',
  //                     style: GoogleFonts.poppins(
  //                       fontSize: 18,
  //                       fontWeight: FontWeight.bold,
  //                       color: Colors.black87,
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
              
  //             const SizedBox(height: 20),
              
  //             // Actions
  //             Row(
  //               mainAxisAlignment: MainAxisAlignment.end,
  //               children: [
  //                 if (order.status_commande == 'En attente') ...[
  //                   ElevatedButton(
  //                     onPressed: () {
  //                       validateOrder(order);
  //                       Navigator.pop(context);
  //                     },
  //                     style: ElevatedButton.styleFrom(
  //                       backgroundColor: Colors.green.shade600,
  //                       foregroundColor: Colors.white,
  //                       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  //                     ),
  //                     child: const Text('Valider'),
  //                   ),
  //                   const SizedBox(width: 8),
  //                   ElevatedButton(
  //                     onPressed: () {
  //                       Navigator.pop(context);
  //                       rejectOrder(order);
  //                     },
  //                     style: ElevatedButton.styleFrom(
  //                       backgroundColor: Colors.red.shade600,
  //                       foregroundColor: Colors.white,
  //                       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  //                     ),
  //                     child: const Text('Rejeter'),
  //                   ),
  //                   const SizedBox(width: 8),
  //                 ],
  //                 if (order.status_commande == 'Validee') ...[
  //                   ElevatedButton(
  //                     onPressed: () {
  //                       // Créer bon de sortie
  //                       Navigator.pop(context);
  //                       ScaffoldMessenger.of(context).showSnackBar(
  //                         const SnackBar(content: Text('Bon de sortie créé')),
  //                       );
  //                     },
  //                     style: ElevatedButton.styleFrom(
  //                       backgroundColor: const Color(0xFF0C8D68),
  //                       foregroundColor: Colors.white,
  //                       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  //                     ),
  //                     child: const Text('📋 Bon de sortie'),
  //                   ),
  //                   const SizedBox(width: 8),
  //                 ],
  //               ],
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }
  void showOrderDetails(BonDeCommande order) {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 600),
        padding: const EdgeInsets.all(24),
        child: Scrollbar( // ✅ Scrollbar visible
          thumbVisibility: true,
          child: SingleChildScrollView( // ✅ Scroll vertical
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

                // --- INFORMATIONS GÉNÉRALES ---
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
                                    style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.black54)),
                                Text(order.idBonDeCommande.toString(),
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
                                _buildStatusChip(order.status_commande),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // --- ARTICLES ---
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
                                flex: 1,
                                child: Text('Qté',
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
                        ...order.articles!.map((item) => Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border(
                                    top: BorderSide(
                                        color: Colors.grey.shade200)),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                      flex: 3,
                                      child: Text(
                                          item.article?.intitule ??
                                              'Article non spécifié',
                                          style: GoogleFonts.poppins(
                                              fontSize: 12))),
                                  Expanded(
                                      flex: 1,
                                      child: Text('${item.quantite}',
                                          style: GoogleFonts.poppins(
                                              fontSize: 12))),
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
                                              fontWeight:
                                                  FontWeight.w600))),
                                ],
                              ),
                            ))
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
                        onPressed: () {
                          validateOrder(order);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
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
                    if (order.status_commande == 'Validee') ...[
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
                Expanded(child: _buildStatCard(Icons.check, 'Validees', validatedCount, Colors.green)),
                const SizedBox(width: 16),
                Expanded(child: _buildStatCard(Icons.cancel, 'Rejetees', rejectedCount, Colors.red)),
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
                            'Validee',
                            'Rejetee',
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
          
          // Rows - FIXED: Added null check for agence
          ...orders.map((order) => Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                Expanded(flex: 2, child: Text(order.idBonDeCommande.toString(), style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600))),
                Expanded(flex: 2, child: Text(order.dateBonDeCommande.toString(), style: GoogleFonts.poppins(fontSize: 15))),
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
                  Expanded(flex: 2, child: _buildStatusChip(order.status_commande)),
                Expanded(
                  flex: 3,
                  child: Row(
                    children: [
                      _buildActionButton(Icons.more_horiz_sharp, const Color.fromARGB(255, 132, 134, 134), () => showOrderDetails(order)),
                      if (showActions && order.status_commande == 'En attente') ...[
                        const SizedBox(width: 4),
                        _buildActionButton(Icons.check_circle, Colors.green, () => validateOrder(order)),
                        const SizedBox(width: 4),
                        _buildActionButton(Icons.cancel, Colors.red, () => rejectOrder(order)),
                      ],
                      if (order.status_commande == 'Validee') ...[
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

  Widget _buildStatusChip(String status) {
    Color backgroundColor = Colors.grey.shade200;
    Color textColor = Colors.black54;
    
    switch (status) {
      case 'En attente':
        backgroundColor = Colors.orange.shade100;
        textColor = Colors.orange.shade700;
        break;
      case 'Validee':
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade700;
        break;
      case 'Rejetee':
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

