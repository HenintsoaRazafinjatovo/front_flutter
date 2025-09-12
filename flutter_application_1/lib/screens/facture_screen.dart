import 'package:flareline_template/models/bon_de_livraison.dart';
import 'package:flutter/material.dart';
import '../models/facture.dart';
import '../models/article.dart'; // <-- Add this import for Article
import '../models/mvtStockArticle.dart';
import '../screens/invoice_screen.dart';
import '../services/factureService.dart';
import '../services/bon_de_livraisonService.dart';
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
// Dialog pour créer une facture
class CreateInvoiceDialog extends StatefulWidget {
   List<BonDeLivraison> receptions = [];
  final Function(Facture) onInvoiceCreated;

  CreateInvoiceDialog({
    super.key,
    this.receptions = const [],
    required this.onInvoiceCreated,
  });

  @override
  // ignore: library_private_types_in_public_api
  _CreateInvoiceDialogState createState() => _CreateInvoiceDialogState();
}

class _CreateInvoiceDialogState extends State<CreateInvoiceDialog> {
  BonDeLivraison? selectedReception;
  final Color buttonColor = Color(0xFFF9B70D);
  final Color accentColor = Colors.redAccent;
  @override
  void initState() {
    super.initState();
    _loadLivraisons();
  }
   Future<void> _loadLivraisons() async {
    try {
      final loadedLivraisons = await BonDeLivraisonService().getBonDeLivraisonWithDetails();
      setState(() {
        widget.receptions = loadedLivraisons;
      });
    } catch (e) {
      print('Erreur de chargement des bons de livraison: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur de chargement des bons de livraison: $e")),
      );
    }
  }

void _createInvoice() async {
  if (selectedReception == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Veuillez sélectionner un bon de réception')),
    );
    return;
  }

  final idBonDeLivraison = selectedReception!.idBonDeLivraison;

  if (idBonDeLivraison == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('L\'ID du bon de livraison est manquant.')),
    );
    return;
  }

  try {
    final result = await FactureService().creerFactureParBonLivraison(idBonDeLivraison);

    if (result["success"]) {
      // On récupère la facture renvoyée par l’API
      final factureApi = result["facture"];

      // Tu peux mapper la réponse JSON vers ton modèle Facture si besoin
      final newInvoice = Facture(
        idFacture: factureApi["id_facture"],
        reference: factureApi["reference"],
        dateFacture: DateTime.parse(factureApi["date_facture"]),
        agence: selectedReception!.agence,
        description: factureApi["description"],
        articles: (selectedReception!.articles ?? []).map((item) => MvtStockArticle(
          idArticle: item.idArticle,
          quantite: item.quantite,
          article: Article(
            idArticle: item.idArticle,
            intitule: item.article?.intitule ?? '',
            code: item.article?.code ?? '',
            seuilMin: item.article?.seuilMin ?? 0,
          ),
        )).toList(),
        montant: factureApi["montant"],
        montantTva: factureApi["montant_tva"],
        montantTtc: factureApi["montant_ttc"],
      );

      widget.onInvoiceCreated(newInvoice);
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Facture ${newInvoice.reference} créée avec succès !'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      print("Erreur API lors de la création de la facture : ${result["error"]}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur API : ${result["error"]}")),
      );
    }
  } catch (e) {
    print("Exception lors de la création de la facture : $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Exception lors de la création : $e")),
    );
  }
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
            DropdownButtonFormField<BonDeLivraison>(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: '-- Choisir un bon de réception --',
              ),
              value: selectedReception,
              items: widget.receptions.map((reception) {
                return DropdownMenuItem<BonDeLivraison>(
                  value: reception,
                  child: Text('${reception.idBonDeLivraison} - ${reception.reference} (${reception.total != null ? reception.total!.toStringAsFixed(2) : '0.00'} Ar HT)'),
                );
              }).toList(),
              onChanged: (BonDeLivraison? value) {
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
                      'Aperçu du bon de réception ${selectedReception!.idBonDeLivraison}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Agence: ${selectedReception!.agence?.codeAgence ?? ''}'),
                              Text('Date: ${DateFormat('dd/MM/yyyy').format(selectedReception!.dateBonDeLivraison)}'),
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
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Articles: ${selectedReception!.articles?.map((item) => '${item.article?.intitule ?? ''} (x${item.quantite})').join(', ')}',
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
                              Text('${selectedReception!.total?.toStringAsFixed(2) ?? '0.00'} Ar'),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('TVA (20%):'),
                              Text('${(selectedReception!.total != null ? (selectedReception!.total! * 0.20).toStringAsFixed(2) : '0.00')} '),
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
                                '${selectedReception!.total != null ? (selectedReception!.total! * 1.20).toStringAsFixed(2) : '0.00'} Ar',
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

