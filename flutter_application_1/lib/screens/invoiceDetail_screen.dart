// ignore: file_names
import 'package:flutter/material.dart';
import '../models/facture.dart';// <-- Add this import for Article
import '../models/mvtStockArticle.dart'; 
import 'package:intl/intl.dart';
import '../services/factureService.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:html' as html;

class InvoiceDetailScreen extends StatelessWidget {
  final Facture invoice;
  final Color buttonColor;
  final Color headerRowColor;
  final Color accentColor;

  const InvoiceDetailScreen({super.key, 
    required this.invoice,
    required this.buttonColor,
    required this.headerRowColor,
    required this.accentColor,
  });
  void openPdfWeb(Uint8List pdfBytes, String filename) {
    final blob = html.Blob([pdfBytes], 'application/pdf');
  final url = html.Url.createObjectUrlFromBlob(blob);

  final anchor = html.AnchorElement(href: url)
    ..setAttribute("download", filename) // Nom du fichier
    ..click(); // Simule le clic pour lancer le téléchargement

  html.Url.revokeObjectUrl(url);

}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(' ${invoice.idFacture}'),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.print),
            onPressed:  () async {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Impression de la facture...')),
                
              );
              try {
              final factureService = FactureService();
              final pdfBytes = await factureService.generatePdf('facture', invoice.idFacture ?? 0);
              openPdfWeb(pdfBytes, 'FACTURE-${invoice.idFacture}');

              } catch (e) {
                print('Erreur : $e');
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec logo SMMEC
            Container(
              padding: EdgeInsets.all(24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo SMMEC
                  Container(
                    padding: EdgeInsets.all(16),
                    // decoration: BoxDecoration(
                    //   color: headerRowColor,
                    //   borderRadius: BorderRadius.circular(8),
                    // ),
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/logo1.png',
                          width: 200,
                          // height: 60,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'FACTURE',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          invoice.reference,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color:buttonColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Date d\'émission',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        DateFormat('dd/MM/yyyy').format(invoice.dateFacture),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Informations expéditeur et destinataire
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(16),
                    margin: EdgeInsets.only(right: 8),
                    // decoration: BoxDecoration(
                    //   color: Colors.grey[50],
                    //   // borderRadius: BorderRadius.circular(8),
                    //   // border: Border.all(color: Colors.grey[300]!),
                    // ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Expéditeur',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'SMMEC - SA',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: accentColor,
                          ),
                        ),
                        Text(
                          'Ampasanimalo',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        Text(
                          'Antananarivo, Madagascar',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Contact: 22-290-69',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        Text(
                          'NIF: 2000013087',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        Text(
                          'STAT: 66191 11 2006 0 00542',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(16),
                    margin: EdgeInsets.only(left: 8),
                    // decoration: BoxDecoration(
                    //   color: Colors.blue[50],
                    //   // borderRadius: BorderRadius.circular(8),
                    //   // border: Border.all(color: Colors.blue[200]!),
                    // ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Destinataire',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          invoice.agence?.codeAgence ?? '',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: accentColor,
                          ),
                        ),
                        SizedBox(height: 4),
                        // Text(
                        //   invoice.agencyAddress,
                        //   style: TextStyle(color: Colors.grey[700]),
                        // ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 24),

            // Traçabilité des documents
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.yellow[50],
                // borderRadius: BorderRadius.circular(8),
                // border: Border.all(color: Colors.yellow[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.link, color: buttonColor),
                      SizedBox(width: 8),
                      Text(
                        'Traçabilité des documents',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: [
                      if (invoice.referenceBonDeCommande != null)
                        _buildTraceabilityItem('Bon de commande', invoice.referenceBonDeCommande!),
                      if (invoice.referenceBonDeLivraison != null)
                        _buildTraceabilityItem('Bon de livraison', invoice.referenceBonDeLivraison!),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // Tableau des articles
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Détail des articles',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      // En-tête du tableau
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: headerRowColor,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                'ID Article',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                'Désignation',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                'Qté',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'Prix unitaire',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'Montant',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Lignes du tableau
                      ...invoice.articles.asMap().entries.map((entry) {
                        int index = entry.key;
                        MvtStockArticle item = entry.value;

                        return Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: index % 2 == 0 ? Colors.white : Colors.grey[50],
                            border: Border(
                              bottom: BorderSide(color: Colors.grey[300]!),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  item.idArticle.toString(),
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(item.article?.intitule ?? ''),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  '${item.quantite}',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  '${item.article?.prix?.toStringAsFixed(2) ?? '0.00'} ',
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  '${item.totalArticle != null ? item.totalArticle!.toStringAsFixed(2) : '0.00'} ',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 24),

            // Totaux
            Row(
              children: [
                Spacer(),
                Container(
                  width: 300,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total HT:',
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            '${invoice.montant != null ? invoice.montant!.toStringAsFixed(2) : '0.00'} ',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'TVA (20%):',
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            '${invoice.montantTva?.toStringAsFixed(2) ?? '0.00'} ',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Divider(thickness: 2, color: Color(0xFF1E40AF)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total TTC:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${invoice.montantTtc?.toStringAsFixed(2) ?? '0.00'} Ar',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E40AF),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 24),

            // Informations de paiement
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Conditions de paiement',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Paiement à 30 jours fin de mois',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  Text(
                    'RIB: FR76 1234 5678 9012 3456 78',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // Boutons d'action
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed:  () async {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Impression de la facture...')),
                        
                      );
                      try {
                      final factureService = FactureService();
                      final pdfBytes = await factureService.generatePdf('facture', invoice.idFacture ?? 0);
                      openPdfWeb(pdfBytes, 'FACTURE-${invoice.idFacture}');

                      } catch (e) {
                        print('Erreur : $e');
                      }
                    },
                    icon: Icon(Icons.print, color: Colors.white),
                    label: Text(
                      'Imprimer',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    label: Text(
                      'Retour à la liste',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[600],
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTraceabilityItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label:',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E40AF),
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}