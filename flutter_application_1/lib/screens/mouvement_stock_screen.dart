import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/article.dart';
import '../services/articleService.dart';

class MouvementStockScreen extends StatefulWidget {
  const MouvementStockScreen({Key? key}) : super(key: key);

  @override
  State<MouvementStockScreen> createState() => _MouvementStockScreenState();
}

class _MouvementStockScreenState extends State<MouvementStockScreen> {
  // Couleurs définies
  static const Color primaryColor = Color(0xFFF9B70D);
  static const Color headerColor = Color.fromARGB(154, 131, 130, 129);
  static const Color backgroundColor = Colors.white;
  static const Color redAccent = Color(0xFFE53E3E);

  // Données
  // List<Article> articles = [
  //   Article(id: 'ART-001', name: 'PV de stockage', stock: 15, unitPrice: 1200),
  //   Article(id: 'ART-002', name: 'Fiche de pret', stock: 25, unitPrice: 25),
  //   Article(id: 'ART-003', name: 'Carnet de pret', stock: 8, unitPrice: 300),
  //   Article(id: 'ART-004', name: 'Acte de cautionnement', stock: 12, unitPrice: 80),
  //   Article(id: 'ART-005', name: 'Contrat depot a terme', stock: 5, unitPrice: 450),
  //   Article(id: 'ART-006', name: 'Fanambarana fanonerana', stock: 20, unitPrice: 60),
  //   Article(id: 'ART-007', name: 'Registre de transmission', stock: 10, unitPrice: 90),
  //   Article(id: 'ART-008', name: 'Registre de passation', stock: 18, unitPrice: 120),
  // ];
  
  List<Article> articles = [];
  Article? selectedArticle;
  String quantity = '';
   Future<void> _loadArticles() async {
    try {
      final loadedArticles = await ArticleService().getArticles();
      setState(() {
        articles = loadedArticles;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur de chargement des articles: $e")),
      );
    }
  }
  

  List<Movement> movements = [];
  List<Movement> filteredMovements = [];

  // Filtres
  String? selectedArticleFilter;
  String? selectedTypeFilter;
  String? selectedReasonFilter;
  DateTime? dateFromFilter;
  DateTime? dateToFilter;

  @override
  void initState() {
    super.initState();
    _initializeSampleData();
    filteredMovements = List.from(movements);
    _loadArticles();
  }

  void _initializeSampleData() {
    movements = [
      Movement(
        id: 1,
        date: DateTime(2024, 12, 20),
        type: MovementType.sortie,
        reason: 'Bon de sortie',
        articleId: 'ART-001',
        articleName: 'PV de stockage',
        quantity: -2,
        direction: null,
        user: 'Jean Dupont',
        comment: 'Livraison agence Lyon',
      ),
      Movement(
        id: 2,
        date: DateTime(2024, 12, 19),
        type: MovementType.entree,
        reason: 'Réception',
        articleId: 'ART-003',
        articleName: 'Carnet de pret',
        quantity: 5,
        direction: null,
        user: 'Marie Martin',
        comment: 'Réception fournisseur',
      ),
      Movement(
        id: 3,
        date: DateTime(2024, 12, 18),
        type: MovementType.sortie,
        reason: 'Attribution',
        articleId: 'ART-002',
        articleName: 'Fiche de pret',
        quantity: -3,
        direction: 'Direction Technique',
        user: 'Pierre Durand',
        comment: 'Attribution équipe développement',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      // appBar: AppBar(
      //   title: const Text(
      //     'Mouvement de Stock',
      //     style: TextStyle(
      //       fontWeight: FontWeight.bold,
      //       color: Color.fromARGB(255, 51, 50, 50),
      //     ),
      //   ),
      //   backgroundColor: Colors.white,
      //   elevation: 2,
      // ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildHistorySection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Text(
                'Gestion des entrées et sorties de stock',
                style: TextStyle(
                  color: Color.fromARGB(255, 3, 3, 3),
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
          ElevatedButton.icon(
            onPressed: () => _showCreateMovementDialog(),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              'Nouveau Mouvement',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Historique des mouvements',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
          _buildFilters(),
          const SizedBox(height: 24),
          _buildMovementsTable(),
        ],
      ),
    );
  }

  Widget _buildFilters() {
  return Wrap(
    spacing: 16,
    runSpacing: 16,
    children: [
      SizedBox(
        width: 400, // 🔧 Augmenté pour éviter le overflow
        child: DropdownButtonFormField<String>(
          value: selectedArticleFilter,
          decoration: const InputDecoration(
            labelText: 'Tous les articles',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          items: [
            const DropdownMenuItem(value: null, child: Text('Tous les articles')),
            ...articles.map((article) => DropdownMenuItem(
                  value: article.idArticle.toString(),
                  child: Text(article.intitule),
                )),
          ],
          onChanged: (value) {
            setState(() {
              selectedArticleFilter = value;
              _applyFilters();
            });
          },
        ),
      ),
      SizedBox(
        width: 180, 
        child: DropdownButtonFormField<String>(
          value: selectedTypeFilter,
          decoration: const InputDecoration(
            labelText: 'Tous les types',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          items: const [
            DropdownMenuItem(value: null, child: Text('Tous les types')),
            DropdownMenuItem(value: 'Entrée', child: Text('Entrée')),
            DropdownMenuItem(value: 'Sortie', child: Text('Sortie')),
          ],
          onChanged: (value) {
            setState(() {
              selectedTypeFilter = value;
              _applyFilters();
            });
          },
        ),
      ),
      SizedBox(
        width: 220, 
        child: DropdownButtonFormField<String>(
          value: selectedReasonFilter,
          decoration: const InputDecoration(
            labelText: 'Toutes les raisons',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          items: const [
            DropdownMenuItem(value: null, child: Text('Toutes les raisons')),
            DropdownMenuItem(value: 'Bon de sortie', child: Text('Bon de sortie')),
            DropdownMenuItem(value: 'Attribution', child: Text('Attribution')),
            DropdownMenuItem(value: 'Réception', child: Text('Réception')),
            DropdownMenuItem(value: 'Inventaire', child: Text('Inventaire')),
          ],
          onChanged: (value) {
            setState(() {
              selectedReasonFilter = value;
              _applyFilters();
            });
          },
        ),
      ),
      // Boutons
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton.icon(
            onPressed: _applyFilters,
            icon: const Icon(Icons.search, color: Colors.white),
            label: const Text(
              'Filtrer',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: _clearFilters,
            icon: const Icon(Icons.refresh, color: Colors.white),
            label: const Text(
              'Réinitialiser',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[600],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    ],
  );
}


  Widget _buildMovementsTable() {
    if (filteredMovements.isEmpty) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        child: const Text(
          'Aucun mouvement trouvé',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 16,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(headerColor),
        headingTextStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        border: TableBorder.all(
          color: Colors.grey[300]!,
          width: 1,
        ),
        columns: const [
          DataColumn(label: Text('Date')),
          DataColumn(label: Text('Type')),
          DataColumn(label: Text('Raison')),
          DataColumn(label: Text('Article')),
          DataColumn(label: Text('Quantité')),
          DataColumn(label: Text('Direction')),
          DataColumn(label: Text('Utilisateur')),
          DataColumn(label: Text('Actions')),
        ],
        rows: filteredMovements.map((movement) {
          final typeColor = movement.type == MovementType.entree 
              ? Colors.green[700] 
              : redAccent;
          final quantityColor = movement.quantity > 0 
              ? Colors.green[700] 
              : redAccent;

          return DataRow(
            cells: [
              DataCell(Text(DateFormat('dd/MM/yyyy').format(movement.date))),
              DataCell(
                Text(
                  movement.type == MovementType.entree ? 'Entrée' : 'Sortie',
                  style: TextStyle(
                    color: typeColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              DataCell(Text(movement.reason)),
              DataCell(Text(movement.articleName)),
              DataCell(
                Text(
                  '${movement.quantity > 0 ? '+' : ''}${movement.quantity}',
                  style: TextStyle(
                    color: quantityColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              DataCell(Text(movement.direction ?? '-')),
              DataCell(Text(movement.user)),
              DataCell(
                ElevatedButton(
                  onPressed: () => _showMovementDetails(movement),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    minimumSize: const Size(80, 32),
                  ),
                  child: const Text(
                    'Détails',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  void _showCreateMovementDialog() {
    showDialog(
      context: context,
      builder: (context) => CreateMovementDialog(
        articles: articles,
        onMovementCreated: (newMovement) {
          setState(() {
            movements.add(newMovement);
            // Mettre à jour le stock
            // ignore: unrelated_type_equality_checks
            final article = articles.firstWhere((a) => a.idArticle == newMovement.articleId);
            if (newMovement.type == MovementType.entree) {
              article.seuilMin += newMovement.quantity.abs();
            } else {
              article.seuilMin -= newMovement.quantity.abs();
            }
            filteredMovements = List.from(movements);
          });
        },
      ),
    );
  }

  void _showMovementDetails(Movement movement) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Détails du mouvement'),
        content: SizedBox(
          width: 600,
          height: 250,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow('Date:', DateFormat('dd/MM/yyyy').format(movement.date)),
                _buildDetailRow('Type:', movement.type == MovementType.entree ? 'Entrée' : 'Sortie'),
                _buildDetailRow('Raison:', movement.reason),
                _buildDetailRow('Article:', movement.articleName),
                _buildDetailRow('Quantité:', '${movement.quantity > 0 ? '+' : ''}${movement.quantity}'),
                if (movement.direction != null)
                  _buildDetailRow('Direction:', movement.direction!),
                _buildDetailRow('Utilisateur:', movement.user),
                if (movement.comment != null)
                  _buildDetailRow('Commentaire:', movement.comment!),
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
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  void _applyFilters() {
    setState(() {
      filteredMovements = movements.where((movement) {
        final articleMatch = selectedArticleFilter == null || movement.articleId == selectedArticleFilter;
        final typeMatch = selectedTypeFilter == null || 
            (selectedTypeFilter == 'Entrée' && movement.type == MovementType.entree) ||
            (selectedTypeFilter == 'Sortie' && movement.type == MovementType.sortie);
        final reasonMatch = selectedReasonFilter == null || movement.reason == selectedReasonFilter;
        
        // Date filters can be implemented here if needed
        
        return articleMatch && typeMatch && reasonMatch;
      }).toList();
    });
  }

  void _clearFilters() {
    setState(() {
      selectedArticleFilter = null;
      selectedTypeFilter = null;
      selectedReasonFilter = null;
      dateFromFilter = null;
      dateToFilter = null;
      filteredMovements = List.from(movements);
    });
  }
}

// Dialog pour créer un nouveau mouvement
class CreateMovementDialog extends StatefulWidget {
  final List<Article> articles;
  final Function(Movement) onMovementCreated;

  const CreateMovementDialog({
    super.key,
    required this.articles,
    required this.onMovementCreated,
  });

  @override
  State<CreateMovementDialog> createState() => _CreateMovementDialogState();
}

class _CreateMovementDialogState extends State<CreateMovementDialog> {
  static const Color primaryColor = Color(0xFFF9B70D);

  MovementType? selectedMovementType;
  String? selectedSortieType;
  String? selectedDirection;
  String? selectedArticleId;
  int quantity = 0;
  String comment = '';

  final List<String> directions = [
    'Direction Générale',
    'Direction Technique',
    'Direction Commerciale',
    'Direction Financière',
    'Direction RH',
    'Direction Logistique',
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('➕ Nouveau mouvement de stock'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 500,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildMovementTypeSelection(),
              const SizedBox(height: 16),
              if (selectedMovementType == MovementType.sortie) ...[
                _buildSortieTypeSelection(),
                const SizedBox(height: 16),
                if (selectedSortieType == 'attribution') ...[
                  _buildDirectionSelection(),
                  const SizedBox(height: 16),
                ],
              ],
              _buildArticleSelection(),
              const SizedBox(height: 16),
              _buildQuantityInput(),
              const SizedBox(height: 16),
              _buildCommentInput(),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _canCreateMovement() ? _createMovement : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
          ),
          child: const Text(
            'Valider',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildMovementTypeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Type de mouvement',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: RadioListTile<MovementType>(
                title: const Text('📥 Entrée'),
                value: MovementType.entree,
                groupValue: selectedMovementType,
                onChanged: (value) {
                  setState(() {
                    selectedMovementType = value;
                    selectedSortieType = null;
                    selectedDirection = null;
                  });
                },
              ),
            ),
            Expanded(
              child: RadioListTile<MovementType>(
                title: const Text('📤 Sortie'),
                value: MovementType.sortie,
                groupValue: selectedMovementType,
                onChanged: (value) {
                  setState(() {
                    selectedMovementType = value;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSortieTypeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Type de sortie',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: RadioListTile<String>(
                title: const Text('📋 Bon de sortie'),
                value: 'bon_sortie',
                groupValue: selectedSortieType,
                onChanged: (value) {
                  setState(() {
                    selectedSortieType = value;
                    selectedDirection = null;
                  });
                },
              ),
            ),
            Expanded(
              child: RadioListTile<String>(
                title: const Text('👥 Attribution'),
                value: 'attribution',
                groupValue: selectedSortieType,
                onChanged: (value) {
                  setState(() {
                    selectedSortieType = value;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDirectionSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Direction concernée',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selectedDirection,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: '-- Choisir une direction --',
          ),
          items: directions.map((direction) => DropdownMenuItem(
                value: direction,
                child: Text(direction),
              )).toList(),
          onChanged: (value) {
            setState(() {
              selectedDirection = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildArticleSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Article',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selectedArticleId,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: '-- Choisir un article --',
          ),
          items: widget.articles.map((article) => DropdownMenuItem(
                value: article.idArticle.toString(),
                child: Text('${article.intitule} (Seuil Min: ${article.seuilMin})'),
              )).toList(),
          onChanged: (value) {
            setState(() {
              selectedArticleId = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildQuantityInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quantité',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextFormField(
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: '0',
          ),
          onChanged: (value) {
            setState(() {
              quantity = int.tryParse(value) ?? 0;
            });
          },
        ),
      ],
    );
  }

  Widget _buildCommentInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Commentaire (optionnel)',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextFormField(
          maxLines: 3,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Ajouter un commentaire...',
          ),
          onChanged: (value) {
            setState(() {
              comment = value;
            });
          },
        ),
      ],
    );
  }

  bool _canCreateMovement() {
    if (selectedMovementType == null || selectedArticleId == null || quantity <= 0) {
      return false;
    }

    if (selectedMovementType == MovementType.sortie) {
      if (selectedSortieType == null) return false;
      if (selectedSortieType == 'attribution' && selectedDirection == null) return false;

      // Vérifier le stock pour les sorties
      // final article = widget.articles.firstWhere((a) => a.idArticle == selectedArticleId);
      // if (quantity > article.seuilMin) return false;
    }

    return true;
  }

  // 
  void _createMovement() {
      if (!_canCreateMovement()) return;

      String reason = '';
      if (selectedMovementType == MovementType.entree) {
        reason = 'Réception';
      } else if (selectedSortieType == 'bon_sortie') {
        reason = 'Bon de sortie';
      } else if (selectedSortieType == 'attribution') {
        reason = 'Attribution';
      }

      // final article = widget.articles.firstWhere(
      //   (a) => a.idArticle.toString() == selectedArticleId,
      //   orElse: () => Article(
      //     idArticle: 0, // Provide a default idArticle value
      //     intitule: '',
      //     seuilMin: 0,
      //     code: ''
      //   ),
      // );

      // if (article.idArticle == '') {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(content: Text("Aucun article correspondant trouvé.")),
      //   );
      //   return;
      // }

      final movementQuantity = selectedMovementType == MovementType.entree ? quantity : -quantity;

      // final movement = Movement(
      //   id: DateTime.now().millisecondsSinceEpoch,
      //   date: DateTime.now(),
      //   type: selectedMovementType!,
      //   reason: reason,
      //   articleId: selectedArticleId!,
      //   // articleName: article.intitule,
      //   quantity: movementQuantity,
      //   direction: selectedSortieType == 'attribution' ? selectedDirection : null,
      //   user: 'Utilisateur Actuel',
      //   comment: comment.isNotEmpty ? comment : null,
      // );

      // widget.onMovementCreated(movement);
      Navigator.of(context).pop();
    }

}

enum MovementType { entree, sortie }

class Movement {
  final int id;
  final DateTime date;
  final MovementType type;
  final String reason;
  final String articleId;
  final String articleName;
  final int quantity;
  final String? direction;
  final String user;
  final String? comment;

  Movement({
    required this.id,
    required this.date,
    required this.type,
    required this.reason,
    required this.articleId,
    required this.articleName,
    required this.quantity,
    this.direction,
    required this.user,
    this.comment,
  });
}