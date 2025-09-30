import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/article.dart';
import '../models/mvt_stock.dart';
import '../models/direction.dart';
import '../services/articleService.dart';
import '../services/directionService.dart';
import '../services/mvt_stockService.dart';
import '../services/attributionService.dart';

class MouvementStockScreen extends StatefulWidget {
  const MouvementStockScreen({super.key});

  @override
  State<MouvementStockScreen> createState() => _MouvementStockScreenState();
}

class _MouvementStockScreenState extends State<MouvementStockScreen> {
  // Couleurs définies
  static const Color primaryColor = Color(0xFFF9B70D);
  static const Color headerColor = Color.fromARGB(154, 131, 130, 129);
  static const Color backgroundColor = Colors.white;
  static const Color redAccent = Color(0xFFE53E3E);

  List<Article> articles = [];
  List<MvtStock> movements = [];
  List<Direction> directions = [];
  Article? selectedArticle;
  String quantity = '';
   Future<void> _loadArticles() async {
    try {
      final loadedArticles = await ArticleService().getAllArticles();
      setState(() {
        articles = loadedArticles;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur de chargement des articles: $e")),
      );
    }
  }
  Future<void> _loadMovements() async {
    try {
      final loadedMovements = await MvtStockService().getMouvementsDetails();
      setState(() {
        movements = loadedMovements;
        filteredMovements = List.from(loadedMovements);
      });
    } catch (e, stackTrace) {
      ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Erreur de chargement des mouvements: $e\n$stackTrace")),
      );
    }
  }
  Future<void> _loadDirections() async {
    try {
      final loadedDirections = await DirectionService().getDirections();
      setState(() {
        directions = loadedDirections;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur de chargement des directions: $e")),
      );
    }
  }

  List<MvtStock> filteredMovements = [];

  // Filtres
  String? selectedArticleFilter;
  String? selectedTypeFilter;
  String? selectedReasonFilter;
  DateTime? dateFromFilter;
  DateTime? dateToFilter;

  @override
  void initState() {
    super.initState();
    _loadMovements();
    _loadArticles();
    _loadDirections();
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
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
                'Gestion des entrees et sorties de stock',
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
                  // value: article.idArticle.toString(),
                  value: article.intitule,

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
            DropdownMenuItem(value: 'entree', child: Text('entree')),
            DropdownMenuItem(value: 'sortie', child: Text('sortie')),
          ],
          onChanged: (value) {
            setState(() {
              selectedTypeFilter = value;
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
          DataColumn(label: Text('Article')),
          DataColumn(label: Text('Quantité')),
          DataColumn(label: Text('Direction')),
          // DataColumn(label: Text('Utilisateur')),
          DataColumn(label: Text('Actions')),
        ],
        rows: filteredMovements.map((movement) {
            final typeColor = movement.type == 'entree'
              ? Colors.green[700]
              : redAccent;
            final quantityColor = movement.type == 'entree'
              ? Colors.green[700]
              : redAccent;

          return DataRow(
            cells: [
              DataCell(Text(DateFormat('dd/MM/yyyy').format(movement.date_mvt))),
              DataCell(
                Text(
                //    movement.type == movement.type ? 'entree' : 'sortie',
                  movement.type,

                  style: TextStyle(
                    color: typeColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              DataCell(Text(movement.article)),
              DataCell(
                Text(
                    '${movement.type == 'entree' ? '+ ' : '- '}${movement.quantite.abs()}',
                  style: TextStyle(
                    color: quantityColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              DataCell(Text(movement.direction?.nom != null ? movement.direction!.nom : '-')),
              // DataCell(Text(movement.user)),
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
        directions: directions,
        onMovementCreated: (newMovement) {
          setState(() {
            movements.add(newMovement);
          final article = articles.firstWhere(
          (a) => a.idArticle == newMovement.article,
          orElse: () => Article(idArticle: 0, intitule: '', seuilMin: 0, code: ''),
        );

        if (newMovement.type == 'entree') {
          article.seuilMin += newMovement.quantite.abs();
        } else {
          article.seuilMin -= newMovement.quantite.abs();
        }
                  filteredMovements = List.from(movements);
          });
        },
      ),
    );
  }

  void _showMovementDetails(MvtStock movement) {
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
                _buildDetailRow('Date:', DateFormat('dd/MM/yyyy').format(movement.date_mvt)),
                // _buildDetailRow('Type:', movement.type == movement.type ? 'entree' : 'sortie'),
                _buildDetailRow('Type:', movement.type ),

                _buildDetailRow('Article:', movement.article),
                _buildDetailRow(
                  'Quantité:',
                  '${movement.type == 'entree' ? '+' : '-'}${movement.quantite.abs()}',
                ),
                // if (movement.direction != null)
                  _buildDetailRow('Direction:', movement.direction != null ? movement.direction!.nom : '-'),
                // _buildDetailRow('Utilisateur:', movement.utilisateur ?? '-'),
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
        final articleMatch = selectedArticleFilter == null || movement.article.toString() == selectedArticleFilter;
        final typeMatch = selectedTypeFilter == null ||
            (selectedTypeFilter == 'entree' && movement.type == 'entree') ||
            (selectedTypeFilter == 'sortie' && movement.type == 'sortie');
        // final reasonMatch = selectedReasonFilter == null || movement.raison == selectedReasonFilter;
        
        // Date filters can be implemented here if needed
        
        return articleMatch && typeMatch;
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
  final List<Direction> directions;
  final Function(MvtStock) onMovementCreated;

  const CreateMovementDialog({
    super.key,
    required this.articles,
    required this.directions,
    required this.onMovementCreated,
  });
  
  // get directions => null;

  @override
  State<CreateMovementDialog> createState() => _CreateMovementDialogState();
}

class _CreateMovementDialogState extends State<CreateMovementDialog> {
  static const Color primaryColor = Color(0xFFF9B70D);

  String selectedMovementType = '';
  String? selectedSortieType;
  Direction? selectedDirection;
  String? selectedArticleId;
  int quantity = 0;
  String comment = '';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('➕ Nouveau mouvement de stock'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 800,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildMovementTypeSelection(),
              const SizedBox(height: 16),
              if (selectedMovementType == 'sortie') ...[
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
              child: RadioListTile<String>(
                title: const Text('📥 entree'),
                value: 'entree',
                groupValue: selectedMovementType,
                onChanged: (value) {
                  setState(() {
                    selectedMovementType = value ?? '';
                    selectedSortieType = null;
                    selectedDirection = null;
                  });
                },
              ),
            ),
            Expanded(
              child: RadioListTile<String>(
                title: const Text('📤 Sortie'),
                value: 'sortie',
                groupValue: selectedMovementType,
                onChanged: (value) {
                  setState(() {
                    selectedMovementType = value ?? '';
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
          value: selectedDirection?.nom,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: '-- Choisir une direction --',
          ),
            items: widget.directions.map((direction) => DropdownMenuItem(
                value: direction.nom,
                child: Text(direction.nom),
              )).toList(),
          onChanged: (value) {
            setState(() {
              selectedDirection = widget.directions.firstWhere((d) => d.nom == value);
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
  bool _canCreateMovement() {
    if (selectedArticleId == null || quantity <= 0) {
      return false;
    }

    if (selectedMovementType == 'sortie') {
      
      if (selectedSortieType == null) return false;
      if (selectedSortieType == 'attribution' && selectedDirection == null) return false;

    }

    return true;
  }

  void _createMovement() async {
    if (!_canCreateMovement()) return;

    // Vérif qu’un article est bien sélectionné
    if (selectedArticleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez sélectionner un article")),
      );
      return;
    }

    // Vérif que la liste n’est pas vide
    if (widget.articles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Aucun article disponible")),
      );
      return;
    }

    // Recherche de l’article
    final article = widget.articles.firstWhere(
      (a) => a.idArticle.toString() == selectedArticleId,
      orElse: () => Article(
        idArticle: 0,
        intitule: '',
        seuilMin: 0,
        code: '',
      ),
    );

    if (article.idArticle == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Article introuvable")),
      );
      return;
    }

    // Calcul quantité (négative si sortie)
    final movementQuantity = selectedMovementType == 'entree'
        ? quantity.toDouble()
        : -quantity.toDouble();

    final articlesData = [
      {
        'id_article': article.idArticle,
        'quantite': movementQuantity.abs(),
      }
    ];

    try {
      bool success = false;

      if (selectedDirection != null && selectedSortieType == 'attribution') {
        final attributionService = Attributionservice();
        success = await attributionService.createAttributionWithMvtStock(
          articles: articlesData,
          description: "Attribution de stock",
          idDirection: selectedDirection!.idDirection!,
        );
      } else {
        final mvtStockService = MvtStockService();
        final type = selectedMovementType == 'entree' ? 1 : 2;
        success = await mvtStockService.createMouvementWithArticles(
          type,
          articlesData,
        );
      }

      if (success) {
        final movement = MvtStock(
        date_mvt: DateTime.now(),
        type: selectedMovementType,
        article: article.idArticle?.toString() ?? '',
        quantite: movementQuantity,
        direction: selectedSortieType == 'attribution' ? selectedDirection : null,
      );


        widget.onMovementCreated(movement);
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Mouvement créé avec succès")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Échec de la création du mouvement")),
        );
      }
    } catch (e) {
      print("Erreur : $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : $e")),
      );
    }
  }

}


