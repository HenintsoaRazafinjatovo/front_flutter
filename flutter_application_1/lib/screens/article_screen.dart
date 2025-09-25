import 'package:flareline_template/models/categorie.dart';
import 'package:flutter/material.dart';
import '../models/article.dart';
import '../services/articleService.dart';
import '../services/categorieService.dart';

void main() {
  runApp(ArticleScreen());
}

class ArticleScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: const Color.fromARGB(255, 189, 8, 8),
      title: 'Gestion des Articles',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Poppins',
      ),
      home: GestionArticlesPage(),
    );
  }
}
class GestionArticlesPage extends StatefulWidget {
  const GestionArticlesPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _GestionArticlesPageState createState() => _GestionArticlesPageState();
}

class _GestionArticlesPageState extends State<GestionArticlesPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _intituleController = TextEditingController();
  final TextEditingController _seuilMinController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _prixController = TextEditingController();

  // Contrôleurs de filtres
  final TextEditingController _filterIntituleController = TextEditingController();
  final TextEditingController _filterCodeController = TextEditingController();

  List<Article> articles = [];
  List<Article> filteredArticles = [];
  List<Categorie> categories = [];
  int? _selectedCategorieId;  

  // Couleurs définies
  static const Color buttonColor = Color(0xFFF9B70D);
  static const Color headerRowColor = Color.fromARGB(154, 131, 130, 129);
  static const Color accentColor = Colors.redAccent;

  @override
  void initState() {
    super.initState();
    _loadArticles();
    _loadCategories();
    _filterIntituleController.addListener(_applyFilters);
    _filterCodeController.addListener(_applyFilters);
  }
  Future<void> _loadArticles() async {
    try {
      final loadedArticles = await ArticleService().getArticles();
      setState(() {
        articles = loadedArticles;
        filteredArticles = loadedArticles;
      });
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur de chargement des articles: $e")),
      );
    }
  }
  Future<void> _loadCategories() async {
    try {
      final loadedCategories = await CategorieService().getCategories();
      setState(() {
        categories = loadedCategories;
      });
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur de chargement des catégories: $e")),
      );
    }
  }

  void _applyFilters() {
    setState(() {
      filteredArticles = articles.where((article) {
        bool matchIntitule = _filterIntituleController.text.isEmpty ||
            article.intitule.toLowerCase().contains(_filterIntituleController.text.toLowerCase());
        
        bool matchCode = _filterCodeController.text.isEmpty ||
            article.code.toLowerCase().contains(_filterCodeController.text.toLowerCase());

        return matchIntitule && matchCode;
      }).toList();
    });
  }

  void _clearForm() {
    _intituleController.clear();
    _seuilMinController.clear();
    _codeController.clear();
    _prixController.clear();
  }

  void _resetFilters() {
    _filterIntituleController.clear();
    _filterCodeController.clear();
  }
  Future<void> _saveArticle() async {
  if (_formKey.currentState!.validate()) {
    final intitule = _intituleController.text;
    final seuilMin = double.parse(_seuilMinController.text);
    final code = _codeController.text;
    final prix = double.parse(_prixController.text);
    final categorie = categories.firstWhere((cat) => cat.idCategorie == _selectedCategorieId);

    final newArticle = Article(
      intitule: intitule,
      seuilMin: seuilMin,
      code: code,
      prix: prix,
      categorie: categorie,
    );

    // Appel du service asynchrone pour créer l'article + historique prix
    final success = await ArticleService().addArticle(newArticle);
    if (success) {
      setState(() {
        articles.add(newArticle);
        _applyFilters();
      });

      _clearForm();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Article créé avec succès!',
            style: TextStyle(fontFamily: 'Poppins'),
          ),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
        'Erreur lors de la création de l\'article.',
        style: TextStyle(fontFamily: 'Poppins'),
        ),
        backgroundColor: Colors.red,
      ),
      );
    }
  }
}


  void _editArticle({Article? article}) {
    final codeController = TextEditingController(text: article?.code ?? '');
    final intituleController = TextEditingController(text: article?.intitule ?? '');
     final prixController = TextEditingController(text: article?.prix.toString() ?? '');
    final seuilMinController = TextEditingController(text: article?.seuilMin.toString() ?? '');
    // final categorieController = TextEditingController(text: article?.categorie ?? '');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(article == null ? 'Nouvel article' : 'Modifier article'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: codeController,
                  decoration: const InputDecoration(labelText: 'Code'),
                ),
                TextFormField(
                  controller: intituleController,
                  decoration: const InputDecoration(labelText: 'Intitulé'),
                ),
                TextFormField(
                   controller: prixController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Prix'),
                ),
                TextFormField(
                  controller: seuilMinController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Seuil min'),
                ),
                
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                final newArticle = Article(
                  code: codeController.text,
                  intitule: intituleController.text,
                  prix: double.tryParse(prixController.text) ?? 0.0,
                  seuilMin: int.tryParse(seuilMinController.text)?.toDouble() ?? 0.0,
                );
                Navigator.of(context).pop(newArticle);
              },
              child: const Text('Enregistrer'),
            ),
          ],
        );
      },
    ).then((result) {
      if (result != null && result is Article) {
        setState(() {
          if (article == null) {
            articles.add(result);
          } else {
            final index = articles.indexWhere((a) => a.idArticle == article.idArticle);
            if (index != -1) {
              articles[index] = result;
            }
          }
        });
      }

      // Dispose des contrôleurs après utilisation
      codeController.dispose();
      intituleController.dispose();
      // prixController.dispose();
      seuilMinController.dispose();
    });
  }
  Future<void> _deleteArticle(Article article) async {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          'Confirmer la suppression',
          style: TextStyle(fontFamily: 'Poppins'),
        ),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer l\'article "${article.intitule}" ?',
          style: TextStyle(fontFamily: 'Poppins'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Annuler',
              style: TextStyle(fontFamily: 'Poppins'),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await ArticleService().deleteArticle(article.idArticle?? 0);

              Navigator.of(context).pop(); // Fermer la boîte de dialogue

              if (success) {
                setState(() {
                  articles.remove(article);
                  _applyFilters();
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Article supprimé avec succès!',
                      style: TextStyle(fontFamily: 'Poppins'),
                    ),
                    backgroundColor: accentColor,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Erreur lors de la suppression de l\'article.',
                      style: TextStyle(fontFamily: 'Poppins'),
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: accentColor),
            child: Text(
              'Supprimer',
              style: TextStyle(fontFamily: 'Poppins', color: Colors.white),
            ),
          ),
        ],
      );
    },
  );
}


  void _showDetails(Article article) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Détails de l\'article',
            style: TextStyle(fontFamily: 'Poppins'),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Intitulé:', article.intitule),
              _buildDetailRow('Code:', article.code),
               _buildDetailRow('Prix:', '${article.prix?.toStringAsFixed(2)} '),
              _buildDetailRow('Seuil minimum:', article.seuilMin.toString()),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Fermer',
                style: TextStyle(fontFamily: 'Poppins'),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold, 
              fontSize: 14,
              fontFamily: 'Poppins',
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Gestion des Articles',
          style: TextStyle(fontFamily: 'Poppins',
          fontWeight: FontWeight.bold,
          fontSize: 25,
          ),
        ),
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        foregroundColor: const Color.fromARGB(255, 66, 64, 64),
      ),
        backgroundColor: Color(0xFFF8F9FA),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Formulaire de création
            Card(
              color: Colors.white,
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Text(
                          'Créer un nouvel article',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        SizedBox(height: 16),

                        // Ligne Intitulé + Code
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _intituleController,
                                style: TextStyle(fontFamily: 'Poppins'),
                                decoration: InputDecoration(
                                  labelText: 'Intitulé',
                                  labelStyle: TextStyle(fontFamily: 'Poppins'),
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Veuillez saisir un intitulé';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _codeController,
                                style: TextStyle(fontFamily: 'Poppins'),
                                decoration: InputDecoration(
                                  labelText: 'Code',
                                  labelStyle: TextStyle(fontFamily: 'Poppins'),
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Veuillez saisir un code';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 16),

                        // Ligne Seuil min + Prix
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _seuilMinController,
                                style: TextStyle(fontFamily: 'Poppins'),
                                decoration: InputDecoration(
                                  labelText: 'Seuil minimum',
                                  labelStyle: TextStyle(fontFamily: 'Poppins'),
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Veuillez saisir un seuil minimum';
                                  }
                                  if (int.tryParse(value) == null) {
                                    return 'Veuillez saisir un nombre valide';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _prixController,
                                style: TextStyle(fontFamily: 'Poppins'),
                                decoration: InputDecoration(
                                  labelText: 'Prix',
                                  labelStyle: TextStyle(fontFamily: 'Poppins'),
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.numberWithOptions(decimal: true),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Veuillez saisir un prix';
                                  }
                                  if (double.tryParse(value) == null) {
                                    return 'Veuillez saisir un prix valide';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 16),

                        // Ligne Categorie + Boutons
                        Row(
                        children: [
                          Expanded(
                            flex: 1, // 👈 moitié de l'écran comme les autres champs
                            child: DropdownButtonFormField<int>(
                              value: _selectedCategorieId,
                              items: categories.map((cat) {
                                return DropdownMenuItem<int>(
                                  value: cat.idCategorie,
                                  child: Text(
                                    cat.nomCategorie,
                                    style: TextStyle(fontFamily: 'Poppins'),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedCategorieId = value;
                                });
                              },
                              decoration: InputDecoration(
                                labelText: 'Catégorie',
                                labelStyle: TextStyle(fontFamily: 'Poppins'),
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                              ),
                              validator: (value) {
                                if (value == null) {
                                  return 'Veuillez choisir une catégorie';
                                }
                                return null;
                              },
                            ),
                          ),

                          SizedBox(width: 16),

                          // Boutons prennent l'autre moitié
                          Expanded(
                            flex: 1, // 👈 moitié de l'écran aussi
                            child: Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _saveArticle,
                                    icon: Icon(Icons.add),
                                    label: Text(
                                      'Créer',
                                      style: TextStyle(fontFamily: 'Poppins'),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: buttonColor,
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: _clearForm,
                                    icon: Icon(Icons.clear),
                                    label: Text(
                                      'Effacer',
                                      style: TextStyle(fontFamily: 'Poppins'),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: accentColor,
                                      side: BorderSide(color: accentColor),
                                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    ],

                  ),
                ),
              ),
            ),

            SizedBox(height: 24),

            // Liste des articles avec filtres intégrés
            Card(
              color: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.0),
              
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                 
                        Text(
                          'Liste des Articles (${filteredArticles.length})',
                          style: TextStyle(
                            fontSize: 18, 
                            fontWeight: FontWeight.bold, 
                            color: const Color.fromARGB(255, 56, 54, 54),
                            fontFamily: 'Poppins',
                          ),
                        ),
                        SizedBox(height: 16),
                        // Ligne des filtres
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: TextField(
                                controller: _filterIntituleController,
                                style: TextStyle(fontFamily: 'Poppins'),
                                decoration: InputDecoration(
                                  labelText: 'Filtrer par nom d\'article',
                                  labelStyle: TextStyle(fontFamily: 'Poppins'),
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              flex: 2,
                              child: TextField(
                                controller: _filterCodeController,
                                style: TextStyle(fontFamily: 'Poppins'),
                                decoration: InputDecoration(
                                  labelText: 'Filtrer par code',
                                  labelStyle: TextStyle(fontFamily: 'Poppins'),
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              flex: 1,
                              child: ElevatedButton.icon(
                                onPressed: _resetFilters,
                                icon: Icon(Icons.refresh),
                                label: Text(
                                  'Réinitialiser',
                                  style: TextStyle(fontFamily: 'Poppins'),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: headerRowColor,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                  Divider(height: 1),
                  SizedBox(height: 19),
                  SizedBox(
                    width: double.infinity,
                    child: filteredArticles.isEmpty
                        ? Padding(
                            padding: EdgeInsets.all(32.0),
                            child: Center(
                              child: Text(
                                'Aucun article trouvé',
                                style: TextStyle(
                                  fontSize: 16, 
                                  color: Colors.grey[600],
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                          )
                        : SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              headingRowColor: WidgetStateProperty.all(headerRowColor),
                              headingTextStyle: TextStyle(
                                color: const Color.fromARGB(255, 58, 57, 57), 
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                              ),
                              dataTextStyle: TextStyle(
                                fontFamily: 'Poppins',
                              ),
                              columns: [
                                DataColumn(
                                  label: Text(
                                    'Intitulé',
                                    style: TextStyle(fontFamily: 'Poppins'),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Code',
                                    style: TextStyle(fontFamily: 'Poppins'),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Prix',
                                    style: TextStyle(fontFamily: 'Poppins'),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Seuil Min.',
                                    style: TextStyle(fontFamily: 'Poppins'),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Stock actuel',
                                    style: TextStyle(fontFamily: 'Poppins'),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Actions',
                                    style: TextStyle(fontFamily: 'Poppins'),
                                  ),
                                ),
                              ],
                              rows: filteredArticles.map((article) {
                                return DataRow(
                                  cells: [
                                    DataCell(
                                      Text(
                                        article.intitule,
                                        style: TextStyle(fontFamily: 'Poppins'),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        article.code,
                                        style: TextStyle(fontFamily: 'Poppins'),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        '${article.prix?.toStringAsFixed(2)} ',
                                        style: TextStyle(fontFamily: 'Poppins'),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        article.seuilMin.toString(),
                                        style: TextStyle(fontFamily: 'Poppins'),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        article.stockActuel.toString(),
                                        style: TextStyle(fontFamily: 'Poppins'),
                                      ),
                                    ),
                                    DataCell(
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.visibility, color: const Color.fromARGB(255, 83, 87, 91)),
                                            onPressed: () => _showDetails(article),
                                            tooltip: 'Détails',
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.edit, color: buttonColor),
                                            onPressed: () => _editArticle(article: article),
                                            tooltip: 'Modifier',
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.delete, color: accentColor),
                                            onPressed: () => _deleteArticle(article),
                                            tooltip: 'Supprimer',
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
    );
  }

  @override
  void dispose() {
    _intituleController.dispose();
    _seuilMinController.dispose();
    _codeController.dispose();
    _prixController.dispose();
    _filterIntituleController.dispose();
    _filterCodeController.dispose();
    super.dispose();
  }
}