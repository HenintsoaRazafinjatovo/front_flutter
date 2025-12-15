// import 'package:flutter/material.dart';
// import '../services/bon_de_commandeService.dart';
// import '../models/bon_de_commande.dart';
// import '../models/commande_article.dart';
// import '../models/agence.dart';
// import '../services/agenceService.dart';

// class PredictionTab extends StatefulWidget {
//   const PredictionTab({super.key});

//   @override
//   State<PredictionTab> createState() => _PredictionTabState();
// }

// class _PredictionTabState extends State<PredictionTab> {
//   DateTime? _predictionDate;
//   Agence? _selectedAgence;
//   List<Agence> agences = [];
//   BonDeCommande? _predictionResult;
//   bool _isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadAgences();
//   }

//   Future<void> _loadAgences() async {
//     try {
//       final loadedAgences = await AgenceService().getAgences();
//       setState(() {
//         agences = loadedAgences;
//       });
//     } catch (e) {
//       print('Erreur de chargement des agences: $e');
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text("Erreur de chargement des agences: $e")));
//     }
//   }

//   Future<void> _generatePrediction() async {
//     if (_predictionDate == null || _selectedAgence == null) return;

//     setState(() {
//       _isLoading = true;
//       _predictionResult = null;
//     });

//     try {
//       final result = await BonDeCommandeService().getCommandePrediction(
//         _predictionDate!,
//         _selectedAgence!.idAgence!,
//       );
//       setState(() {
//         _predictionResult = result;
//       });
//     } catch (e) {
//       print('Erreur lors de la récupération de la prédiction : $e');
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text('Erreur : $e')));
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   Widget _buildPredictionTable() {
//     if (_predictionResult == null || _predictionResult!.articles == null || _predictionResult!.articles!.isEmpty) {
//       return const Center(child: Text('Aucune prédiction disponible'));
//     }

//     return SingleChildScrollView(
//       scrollDirection: Axis.horizontal,
//       child: SizedBox(
//         width: MediaQuery.of(context).size.width,
//         child: DataTable(
//           headingRowHeight: 40,
//           dataRowHeight: 50,
//           columnSpacing: 24,
//           headingTextStyle: const TextStyle(fontWeight: FontWeight.bold),
//           dataTextStyle: const TextStyle(color: Colors.black87),
//           columns: const [
//             DataColumn(label: Text('Article')),
//             DataColumn(label: Text('Quantité prédite')),
      
//           ],
//           rows: _predictionResult!.articles!.map((CommandeArticle article) {
//             return DataRow(
//               color: MaterialStateProperty.resolveWith<Color?>(
//                   (Set<MaterialState> states) {
//                 return _predictionResult!.articles!.indexOf(article) % 2 == 0
//                     ? Colors.white
//                     : Colors.grey.shade100;
//               }),
//               cells: [
//                 DataCell(Text(article.article?.intitule ?? '-')),
//                 DataCell(Text(article.quantite.toStringAsFixed(2))),
//               ],
//             );
//           }).toList(),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Prédictions de commandes',
//             style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 16),
//           Row(
//             children: [
//               Expanded(
//                 child: GestureDetector(
//                   onTap: () async {
//                     final date = await showDatePicker(
//                       context: context,
//                       initialDate: DateTime.now().add(const Duration(days: 1)),
//                       firstDate: DateTime.now(),
//                       lastDate: DateTime.now().add(const Duration(days: 730)),
//                     );
//                     if (date != null) setState(() => _predictionDate = date);
//                   },
//                   child: Container(
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       border: Border.all(color: Colors.grey.shade300),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Row(
//                       children: [
//                         const Icon(Icons.calendar_today, size: 16),
//                         const SizedBox(width: 8),
//                         Text(
//                           _predictionDate != null
//                               ? _predictionDate!.toString().substring(0, 10)
//                               : 'Sélectionner une date',
//                           style: TextStyle(
//                               color: _predictionDate != null
//                                   ? Colors.black
//                                   : Colors.grey[600]),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: DropdownButtonFormField<Agence>(
//                   value: _selectedAgence,
//                   decoration: InputDecoration(
//                     border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//                     contentPadding:
//                         const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
//                   ),
//                   hint: const Text('Sélectionner une agence'),
//                   items: agences
//                       .map((agence) => DropdownMenuItem(
//                             value: agence,
//                             child: Text(agence.codeAgence),
//                           ))
//                       .toList(),
//                   onChanged: (value) => setState(() => _selectedAgence = value),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           SizedBox(
//             width: double.infinity,
//             child: ElevatedButton(
//               onPressed: _generatePrediction,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFFF9B70D),
//                 padding: const EdgeInsets.symmetric(vertical: 16),
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//               ),
//               child: const Text('Prédire', style: TextStyle(fontSize: 16, color: Colors.white)),
//             ),
//           ),
//           const SizedBox(height: 24),
//           if (_predictionDate != null && _selectedAgence != null)
//             Padding(
//               padding: const EdgeInsets.only(bottom: 12),
//               child: Row(
//                 children: [
//                   Text(
//                     'Date : ${_predictionDate!.toString().substring(0, 10)}',
//                     style: const TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(width: 24),
//                   Text(
//                     'Agence : ${_selectedAgence?.codeAgence ?? "-"}',
//                     style: const TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                 ],
//               ),
//             ),
//           if (_isLoading)
//             const Center(child: CircularProgressIndicator())
//           else
//             _buildPredictionTable(),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import '../services/bon_de_commandeService.dart';
import '../models/bon_de_commande.dart';
import '../models/commande_article.dart';
import '../models/agence.dart';
import '../services/agenceService.dart';

class PredictionTab extends StatefulWidget {
  const PredictionTab({super.key});

  @override
  State<PredictionTab> createState() => _PredictionTabState();
}

class _PredictionTabState extends State<PredictionTab> {
  DateTime? _predictionDate;
  Agence? _selectedAgence;
  List<Agence> agences = [];
  BonDeCommande? _predictionResult;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAgences();
  }

  Future<void> _loadAgences() async {
    try {
      final loadedAgences = await AgenceService().getAgences();
      if (mounted) {
        setState(() => agences = loadedAgences);
      }
    } catch (e) {
      print('Erreur de chargement des agences: $e');
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Erreur de chargement des agences: $e")));
      }
    }
  }

  Future<void> _selectDate() async {
    try {
      final date = await showDatePicker(
        context: context,
        initialDate: DateTime.now().add(const Duration(days: 1)),
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 730)),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: ThemeData.light(),
            child: child!,
          );
        },
      );
      if (date != null && mounted) {
        setState(() => _predictionDate = date);
      }
    } catch (e) {
      print('Erreur lors de la sélection de la date: $e');
    }
  }

  Future<void> _generatePrediction() async {
    if (_predictionDate == null || _selectedAgence == null) return;

    setState(() {
      _isLoading = true;
      _predictionResult = null;
    });

    try {
      final result = await BonDeCommandeService().getCommandePrediction(
        _predictionDate!,
        _selectedAgence!.idAgence!,
      );
      if (mounted) {
        setState(() => _predictionResult = result);
      }
    } catch (e) {
      print('Erreur lors de la récupération de la prédiction : $e');
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Erreur : $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildPredictionTable() {
    if (_predictionResult == null || _predictionResult!.articles == null || _predictionResult!.articles!.isEmpty) {
      return const Center(child: Text('Aucune prédiction disponible'));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        width: MediaQuery.of(context).size.width,
        child: DataTable(
          headingRowHeight: 40,
          dataRowHeight: 50,
          columnSpacing: 24,
          headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
          dataTextStyle: const TextStyle(color: Colors.black87),
          columns: const [
            DataColumn(label: Text('Article')),
            DataColumn(label: Text('Quantité prédite')),
          ],
          rows: _predictionResult!.articles!.map((CommandeArticle article) {
            return DataRow(
              color: MaterialStateProperty.resolveWith<Color?>(
                (states) => _predictionResult!.articles!.indexOf(article) % 2 == 0
                    ? Colors.white
                    : Colors.grey.shade100,
              ),
              cells: [
                DataCell(Text(article.article?.intitule ?? '-')),
                DataCell(Text(article.quantite.toStringAsFixed(0))),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Prédictions de commandes',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // --- Sélection Date et Agence ---
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: _selectDate,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          _predictionDate != null
                              ? _predictionDate!.toString().substring(0, 10)
                              : 'Sélectionner une date',
                          style: TextStyle(
                            color: _predictionDate != null ? Colors.black : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<Agence>(
                  value: _selectedAgence,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  hint: const Text('Sélectionner une agence'),
                  items: agences.map((agence) => DropdownMenuItem(
                        value: agence,
                        child: Text(agence.codeAgence ?? '-'),
                      )).toList(),
                  onChanged: (value) => setState(() => _selectedAgence = value),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // --- Bouton prédiction ---
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _generatePrediction,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF9B70D),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Prédire', style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ),
          const SizedBox(height: 16),

          // --- Affichage date et agence ---
          if (_predictionDate != null && _selectedAgence != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Text(
                    'Date : ${_predictionDate!.toString().substring(0, 10)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 24),
                  Text(
                    'Agence : ${_selectedAgence?.codeAgence ?? "-"}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

          // --- Tableau de prédiction ---
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else
            _buildPredictionTable(),
        ],
      ),
    );
  }
}