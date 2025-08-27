// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

// import '../models/article.dart';
// import '../services/articleService.dart';
// import '../services/bon_de_commandeService.dart';
// import '../models/bon_de_commande.dart';

// class BonDeCommandeScreen extends StatefulWidget {
//   const BonDeCommandeScreen({super.key});

//   @override
//   State<BonDeCommandeScreen> createState() => _BonDeCommandeScreenState();
// }

// class _BonDeCommandeScreenState extends State<BonDeCommandeScreen> {
//   List<Article> articles = [];
//   Article? selectedArticle;
//   String quantity = '';
//   String descriptionCommande = '';
//   final List<Map<String, dynamic>> recapCommande = [];
//   final _formKey = GlobalKey<FormState>();

//   List<BonDeCommande> commandes = [];

//   @override
//   void initState() {
//     super.initState();
//     _loadArticles();
//     _loadCommandes();
//   }

//   Future<void> _loadCommandes() async {
//     try {
//       final loadedCommandes = await BonDeCommandeService().getBonDeCommandeWithStatus();
//       setState(() {
//         commandes = loadedCommandes;
//       });
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Erreur de chargement des bons de commande: $e")),
//       );
//     }
//   }
//   Future<void> _loadArticles() async {
//     try {
//       final loadedArticles = await ArticleService().getArticles();
//       setState(() {
//         articles = loadedArticles;
//       });
//     } catch (e) {
//       // ignore: use_build_context_synchronously
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Erreur de chargement des articles: $e")),
//       );
//     }
//   }

//   void ajouterOuMettreAJourArticle() {
//     if (_formKey.currentState!.validate()) {
//       final int quantiteAjoutee = int.parse(quantity);
//       final existingIndex = recapCommande.indexWhere((item) => item['article'].idArticle == selectedArticle!.idArticle);

//       setState(() {
//         if (existingIndex != -1) {
//           recapCommande[existingIndex]['quantite'] += quantiteAjoutee;
//         } else {
//           recapCommande.add({
//             'article': selectedArticle,
//             'quantite': quantiteAjoutee,
//           });
//           print(recapCommande);
//         }
//         selectedArticle = null;
//         quantity = '';
//       });
//     }
//   }

//   void supprimerLigne(int index) {
//     setState(() => recapCommande.removeAt(index));
//   }

//   double calculerTotal() {
//     return recapCommande.fold(0.0, (sum, item) => sum + item['quantite'] * item['article'].prix);
//   }
//   void validerCommandeFinale() async {
//   if (_formKey.currentState!.validate()) {
//     if (recapCommande.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Aucun article dans la commande.")),
//       );
//       return;
//     }

//     // Préparer la liste des articles au format API
//     List<Map<String, dynamic>> articlesData = recapCommande.map((item) {
//       final article = item['article'];
//       final quantite = item['quantite'];
//       return {
//         'id_article': article.idArticle,
//         'quantite': quantite,
//       };
//     }).toList();

//     bool success = await BonDeCommandeService().addBonDeCommande(
//       description: descriptionCommande,
//       idStatusCommande: 1, // tu peux changer selon ton besoin
//       articles: articlesData,
//     );

//     if (success) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Bon de commande créé avec succès !")),
//       );
//       setState(() {
//         recapCommande.clear();
//         descriptionCommande = '';
//       });
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Erreur lors de la création du bon de commande.")),
//       );
//     }
//   }
// }


//   @override
//   Widget build(BuildContext context) {
//   return SingleChildScrollView(
//     padding: const EdgeInsets.all(24),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Card(
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//           color: Colors.white,
//           elevation: 3,
//           child: Padding(
//             padding: const EdgeInsets.all(24),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Créer un bon de commande',
//                   style: GoogleFonts.poppins(
//                     fontSize: 22,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black87,
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 Form(
//                   key: _formKey,
//                   child: Row(
//                     children: [
//                       Expanded(
//                         flex: 3,
//                         child: DropdownButtonFormField<Article>(
//                           value: selectedArticle,
//                           items: articles.map((article) {
//                             return DropdownMenuItem<Article>(
//                               value: article,
//                               child: Text(article.intitule),
//                             );
//                           }).toList(),
//                           onChanged: (val) => setState(() => selectedArticle = val),
//                           decoration: const InputDecoration(
//                             labelText: 'Article',
//                             border: OutlineInputBorder(),
//                             focusedBorder: OutlineInputBorder(
//                               borderSide: BorderSide(color: Color.fromARGB(243, 62, 61, 62)),
//                             ),
//                           ),
//                           // validator: (value) => value == null ? 'Choisir un article' : null,
//                           validator: (value) {
//                             if ((value == null) && (recapCommande.isEmpty)) {
//                               return 'Choisir un article';
//                             }
//                             return null;
//                           },
//                         ),
//                       ),
//                       const SizedBox(width: 16),
//                       Expanded(
//                         flex: 2,
//                         child: TextFormField(
//                           keyboardType: TextInputType.number,
//                           decoration: const InputDecoration(
//                             labelText: 'Quantité',
//                             border: OutlineInputBorder(),
//                             focusedBorder: OutlineInputBorder(
//                               borderSide: BorderSide(color: Color.fromARGB(243, 62, 61, 62)),
//                             ),
//                           ),
//                           onChanged: (val) => quantity = val,
//                           validator: (value) {
//                             if (value == null || value.isEmpty) return 'Quantité requise';
//                             if (int.tryParse(value) == null || int.parse(value) <= 0) return 'Quantité invalide';
//                             return null;
//                           },
//                         ),
//                       ),
//                       const SizedBox(width: 16),
//                       ElevatedButton(
//                         onPressed: ajouterOuMettreAJourArticle,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color(0xFFF9B70D),
//                           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
//                         ),
//                         child: const Text('+', style: TextStyle(color: Colors.white, fontSize: 18)),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 30),
//                 if (recapCommande.isNotEmpty) ...[
//                   Text(
//                     'Récapitulatif de la commande',
//                     style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black87),
//                   ),
//                   const SizedBox(height: 16),
//                   Container(
//                     decoration: BoxDecoration(
//                       border: Border.all(color: Colors.grey.shade300),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: DataTable(
//                       headingRowColor: WidgetStateProperty.all(const Color.fromARGB(154, 131, 130, 129)),
//                       headingTextStyle: const TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                       ),
//                       columnSpacing: 24,
//                       columns: const [
//                         DataColumn(label: Text('Article')),
//                         DataColumn(label: Text('PU')),
//                         DataColumn(label: Text('Quantité')),
//                         DataColumn(label: Text('Montant')),
//                         DataColumn(label: Text('')),
//                       ],
//                       rows: List.generate(recapCommande.length, (index) {
//                         final item = recapCommande[index];
//                         final article = item['article'] as Article;
//                         final quantite = item['quantite'];
//                         final montant = article.prix! * quantite;

//                         return DataRow(cells: [
//                           DataCell(Text(article.intitule)),
//                           DataCell(Text('${article.prix} ')),
//                           DataCell(Text('$quantite')),
//                           DataCell(Text('${montant.toStringAsFixed(2)} ')),
//                           DataCell(
//                             IconButton(
//                               icon: const Icon(Icons.delete, color: Colors.redAccent),
//                               onPressed: () => supprimerLigne(index),
//                             ),
//                           ),
//                         ]);
//                       }),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     children: [
//                       Expanded(
//                         child: TextFormField(
//                           decoration: const InputDecoration(
//                             labelText: 'Description',
//                             border: OutlineInputBorder(),
//                             focusedBorder: OutlineInputBorder(
//                               borderSide: BorderSide(color: Color.fromARGB(243, 62, 61, 62)),
//                             ),
//                           ),
//                            onChanged: (val) => descriptionCommande = val,
//                           // onChanged: (val) => '', // crée une variable String descriptionCommande dans ton state
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'Description requise';
//                             }
//                             return null;
//                           },
//                         ),
//                       ),
//                       const SizedBox(width: 24),
//                       Text(
//                         'Total: ${calculerTotal().toStringAsFixed(2)} ',
//                         style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                       ),
//                       const SizedBox(width: 24),
//                       ElevatedButton.icon(
//                         onPressed: validerCommandeFinale,
//                         icon: const Icon(Icons.check_circle, color: Colors.white),
//                         label: const Text('Valider la commande', style: TextStyle(color: Colors.white)),
//                         style: ElevatedButton.styleFrom(
//                           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//                           backgroundColor: const Color(0xFFF9B70D),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ],
//             ),
//           ),
//         ),

//         const SizedBox(height: 40),

//         Card(
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//           color: Colors.white,
//           elevation: 3,
//           child: Padding(
//             padding: const EdgeInsets.all(24),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Historique des bons de commande',
//                   style: GoogleFonts.poppins(
//                     fontSize: 20,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.black87,
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 Container(
//                   width: double.infinity,
//                   decoration: BoxDecoration(
//                     border: Border.all(color: Colors.grey.shade300),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: DataTable(
//                     headingRowColor: WidgetStateProperty.all(const Color.fromARGB(154, 131, 130, 129)),
//                     headingTextStyle: const TextStyle(
//                       color: Colors.black,
//                       fontWeight: FontWeight.bold,
//                     ),
//                     columnSpacing: 24,
//                     columns: const [
//                       DataColumn(label: Text('ID')),
//                       DataColumn(label: Text('Description')),
//                       DataColumn(label: Text('Status')),
//                       DataColumn(label: Text('Date')),
//                     ],
//                     rows: commandes.map((cmd) {
//                       return DataRow(cells: [
//                         DataCell(Text(cmd.idBonDeCommande.toString())),
//                         DataCell(Text(cmd.description)),
//                         DataCell(Text(cmd.status_commande)),
//                         DataCell(Text(cmd.dateBonDeCommande.toString())),
//                       ]);
//                     }).toList(),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     ),
//   );
// }

// }
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/article.dart';
import '../services/articleService.dart';
import '../services/bon_de_commandeService.dart';
import '../models/bon_de_commande.dart';

class BonDeCommandeScreen extends StatefulWidget {
  const BonDeCommandeScreen({super.key});

  @override
  State<BonDeCommandeScreen> createState() => _BonDeCommandeScreenState();
}

class _BonDeCommandeScreenState extends State<BonDeCommandeScreen> {
  List<Article> articles = [];
  Article? selectedArticle;
  String quantity = '';
  String descriptionCommande = '';
  final List<Map<String, dynamic>> recapCommande = [];
  final _formKey = GlobalKey<FormState>();

  List<BonDeCommande> commandes = [];

  @override
  void initState() {
    super.initState();
    _loadArticles();
    _loadCommandes();
  }

  Future<void> _loadCommandes() async {
    try {
      final loadedCommandes = await BonDeCommandeService().getBonDeCommandeWithStatus();
      setState(() {
        commandes = loadedCommandes;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur de chargement des bons de commande: $e")),
      );
    }
  }

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

  void ajouterOuMettreAJourArticle() {
    if (_formKey.currentState!.validate()) {
      final int quantiteAjoutee = int.parse(quantity);
      final existingIndex =
          recapCommande.indexWhere((item) => item['article'].idArticle == selectedArticle!.idArticle);

      setState(() {
        if (existingIndex != -1) {
          recapCommande[existingIndex]['quantite'] += quantiteAjoutee;
        } else {
          recapCommande.add({
            'article': selectedArticle,
            'quantite': quantiteAjoutee,
          });
        }
        selectedArticle = null;
        quantity = '';
      });
    }
  }

  void supprimerLigne(int index) {
    setState(() => recapCommande.removeAt(index));
  }

  double calculerTotal() {
    return recapCommande.fold(
        0.0, (sum, item) => sum + item['quantite'] * item['article'].prix);
  }

  void validerCommandeFinale() async {
    if (_formKey.currentState!.validate()) {
      if (recapCommande.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Aucun article dans la commande.")),
        );
        return;
      }

      List<Map<String, dynamic>> articlesData = recapCommande.map((item) {
        final article = item['article'];
        final quantite = item['quantite'];
        return {
          'id_article': article.idArticle,
          'quantite': quantite,
        };
      }).toList();

      bool success = await BonDeCommandeService().addBonDeCommande(
        description: descriptionCommande,
        idStatusCommande: 1,
        articles: articlesData,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Bon de commande créé avec succès !")),
        );
        setState(() {
          recapCommande.clear();
          descriptionCommande = '';
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erreur lors de la création du bon de commande.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            color: Colors.white,
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Créer un bon de commande',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Form(
                    key: _formKey,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // Si l'écran est trop petit, utiliser une disposition en colonne
                        if (constraints.maxWidth < 600) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              DropdownButtonFormField<Article>(
                                value: selectedArticle,
                                isExpanded: true,
                                selectedItemBuilder: (context) => articles.map((article) {
                                  return Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      article.intitule,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  );
                                }).toList(),
                                items: articles.map((article) {
                                  return DropdownMenuItem<Article>(
                                    value: article,
                                    child: ConstrainedBox(
                                      constraints: const BoxConstraints(maxWidth: 350),
                                      child: Text(
                                        article.intitule,
                                        softWrap: true,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) => setState(() => selectedArticle = val),
                                decoration: const InputDecoration(
                                  labelText: 'Article',
                                  border: OutlineInputBorder(),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Color.fromARGB(243, 62, 61, 62)),
                                  ),
                                ),
                                validator: (value) {
                                  if ((value == null) && (recapCommande.isEmpty)) {
                                    return 'Choisir un article';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        labelText: 'Quantité',
                                        border: OutlineInputBorder(),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: Color.fromARGB(243, 62, 61, 62)),
                                        ),
                                      ),
                                      onChanged: (val) => quantity = val,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) return 'Quantité requise';
                                        if (int.tryParse(value) == null || int.parse(value) <= 0) {
                                          return 'Quantité invalide';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  SizedBox(
                                    width: 60,
                                    child: ElevatedButton(
                                      onPressed: ajouterOuMettreAJourArticle,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFF9B70D),
                                        padding: const EdgeInsets.symmetric(vertical: 18),
                                      ),
                                      child: const Text('+',
                                          style: TextStyle(color: Colors.white, fontSize: 18)),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        } else {
                          // Utiliser le layout en ligne pour les écrans plus grands
                          return Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: DropdownButtonFormField<Article>(
                                  value: selectedArticle,
                                  isExpanded: true,
                                  selectedItemBuilder: (context) => articles.map((article) {
                                    return Align(
                                      alignment: Alignment.centerLeft,
                                      child: ConstrainedBox(
                                        constraints: const BoxConstraints(maxHeight: 80),
                                        child: Text(
                                          article.intitule,
                                          softWrap: true,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  items: articles.map((article) {
                                    return DropdownMenuItem<Article>(
                                      value: article,
                                      child: ConstrainedBox(
                                        constraints: const BoxConstraints(maxWidth: 350),
                                        child: Text(
                                          article.intitule,
                                          softWrap: true,
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (val) => setState(() => selectedArticle = val),
                                  decoration: const InputDecoration(
                                    labelText: 'Article',
                                    border: OutlineInputBorder(),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Color.fromARGB(243, 62, 61, 62)),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                                  ),
                                  validator: (value) {
                                    if ((value == null) && (recapCommande.isEmpty)) {
                                      return 'Choisir un article';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Quantité',
                                    border: OutlineInputBorder(),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Color.fromARGB(243, 62, 61, 62)),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                                  ),
                                  onChanged: (val) => quantity = val,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) return 'Quantité requise';
                                    if (int.tryParse(value) == null || int.parse(value) <= 0) {
                                      return 'Quantité invalide';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              SizedBox(
                                width: 50,
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: ajouterOuMettreAJourArticle,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFF9B70D),
                                    padding: const EdgeInsets.all(0),
                                  ),
                                  child: const Text('+',
                                      style: TextStyle(color: Colors.white, fontSize: 18)),
                                ),
                              ),
                            ],
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 30),
                  if (recapCommande.isNotEmpty) ...[
                    Text(
                      'Récapitulatif de la commande',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowColor: WidgetStateProperty.all(const Color.fromARGB(154, 131, 130, 129)),
                          headingTextStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          columnSpacing: 24,
                          columns: const [
                            DataColumn(label: Text('Article')),
                            DataColumn(label: Text('PU')),
                            DataColumn(label: Text('Quantité')),
                            DataColumn(label: Text('Montant')),
                            DataColumn(label: Text('')),
                          ],
                          rows: List.generate(recapCommande.length, (index) {
                            final item = recapCommande[index];
                            final article = item['article'] as Article;
                            final quantite = item['quantite'];
                            final montant = article.prix! * quantite;

                            return DataRow(cells: [
                              DataCell(
                                SizedBox(
                                  width: 200,
                                  child: Text(
                                    article.intitule,
                                    softWrap: true,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              DataCell(Text('${article.prix}')),
                              DataCell(Text('$quantite')),
                              DataCell(Text('${montant.toStringAsFixed(2)}')),
                              DataCell(
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                                  onPressed: () => supprimerLigne(index),
                                ),
                              ),
                            ]);
                          }),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // -> Remplacer le LayoutBuilder existant (celui là : LayoutBuilder(builder: (context, constraints) { ... }))
LayoutBuilder(
  builder: (context, constraints) {
    // champ description réutilisable
    final descriptionField = TextFormField(
      decoration: const InputDecoration(
        labelText: 'Description',
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color.fromARGB(243, 62, 61, 62)),
        ),
      ),
      onChanged: (val) => descriptionCommande = val,
      validator: (value) {
        if (value == null || value.isEmpty) return 'Description requise';
        return null;
      },
    );

    final totalText = Text(
      'Total: ${calculerTotal().toStringAsFixed(2)}',
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );

    final validateBtn = ElevatedButton.icon(
      onPressed: validerCommandeFinale,
      icon: const Icon(Icons.check_circle, color: Colors.white),
      label: const Text('Valider la commande', style: TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        backgroundColor: const Color(0xFFF9B70D),
      ),
    );

    // Si vraiment étroit (petits écrans / vues imbriquées), empiler verticalement
    if (constraints.maxWidth < 360) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          descriptionField,
          const SizedBox(height: 12),
          totalText,
          const SizedBox(height: 8),
          SizedBox(width: double.infinity, child: validateBtn),
        ],
      );
    }

    // Pour la plupart des tailles, utiliser Wrap -> permet d'aller à la ligne proprement si besoin
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      alignment: WrapAlignment.end,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // On limite la largeur du champ description pour éviter qu'il "mange" tout
        SizedBox(
          width: constraints.maxWidth > 800 ? 520 : constraints.maxWidth * 0.55,
          child: descriptionField,
        ),
        // Total (avec ellipsis si nécessaire)
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: constraints.maxWidth * 0.25),
          child: totalText,
        ),
        validateBtn,
      ],
    );
  },
),

                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            color: Colors.white,
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Historique des bons de commande',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(const Color.fromARGB(154, 131, 130, 129)),
                        headingTextStyle: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        columnSpacing: 24,
                        columns: const [
                          DataColumn(label: Text('ID')),
                          DataColumn(label: Text('Description')),
                          DataColumn(label: Text('Status')),
                          DataColumn(label: Text('Date')),
                        ],
                        rows: commandes.map((cmd) {
                          return DataRow(cells: [
                            DataCell(Text(cmd.idBonDeCommande.toString())),
                            DataCell(
                              SizedBox(
                                width: 200,
                                child: Text(
                                  cmd.description,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                              ),
                            ),
                            DataCell(Text(cmd.status_commande)),
                            DataCell(Text(cmd.dateBonDeCommande.toString())),
                          ]);
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
    );
  }
}