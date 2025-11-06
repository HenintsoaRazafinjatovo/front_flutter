// // ignore: file_names
// import 'package:flutter/material.dart';
// import '../models/decharge.dart';
// import '../models/mvtStockImmo.dart';

// class DechargeDetailScreen extends StatelessWidget {
//   final Decharge decharge;
//   final Color buttonColor;
//   final Color headerRowColor;
//   final Color accentColor;

//   const DechargeDetailScreen({
//     super.key,
//     required this.decharge,
//     required this.buttonColor,
//     required this.headerRowColor,
//     required this.accentColor,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: Text("Décharge ${decharge.numeroSalle ?? ''}"),
//         backgroundColor: Colors.white,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // En-tête
//             Container(
//               padding: const EdgeInsets.all(24),
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Image.asset(
//                     'assets/logo1.png',
//                     width: 120,
//                   ),
//                   const SizedBox(width: 20),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'DÉCHARGE',
//                           style: TextStyle(
//                             fontSize: 28,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.grey[800],
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           'Salle : ${decharge.numeroSalle ?? ''}',
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             color: buttonColor,
//                           ),
//                         ),
//                         Text(
//                           'Bureau : ${decharge.bureau ?? ''}',
//                           style: TextStyle(color: Colors.grey[700]),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // Informations sur la direction et les responsables
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Expanded(
//                   child: Container(
//                     padding: const EdgeInsets.all(16),
//                     margin: const EdgeInsets.only(right: 8),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Direction',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.grey[800],
//                           ),
//                         ),
//                         const SizedBox(height: 12),
//                         Text(
//                           decharge.direction ?? '',
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             color: accentColor,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 Expanded(
//                   child: Container(
//                     padding: const EdgeInsets.all(16),
//                     margin: const EdgeInsets.only(left: 8),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Responsables',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.grey[800],
//                           ),
//                         ),
//                         const SizedBox(height: 12),
//                         for (var resp in decharge.responsables)
//                           Text(
//                             resp,
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               color: accentColor,
//                             ),
//                           ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 24),

//             // Tableau des matériels
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Matériels',
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.grey[800],
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 Container(
//                   decoration: BoxDecoration(
//                     border: Border.all(color: Colors.grey[300]!),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Column(
//                     children: [
//                       // En-tête
//                       Container(
//                         padding: const EdgeInsets.all(12),
//                         decoration: BoxDecoration(
//                           color: headerRowColor,
//                           borderRadius: const BorderRadius.only(
//                             topLeft: Radius.circular(8),
//                             topRight: Radius.circular(8),
//                           ),
//                         ),
//                         child: Row(
//                           children: const [
//                             Expanded(
//                               flex: 3,
//                               child: Text(
//                                 'Désignation',
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ),
//                             Expanded(
//                               flex: 2,
//                               child: Text(
//                                 'État',
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                                 textAlign: TextAlign.center,
//                               ),
//                             ),
//                             Expanded(
//                               flex: 1,
//                               child: Text(
//                                 'Qté',
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                                 textAlign: TextAlign.right,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       // Lignes
//                       ...decharge.materiels.asMap().entries.map((entry) {
//                         int index = entry.key;
//                         MvtStockImmo item = entry.value;

//                         return Container(
//                           padding: const EdgeInsets.all(12),
//                           decoration: BoxDecoration(
//                             color: index % 2 == 0 ? Colors.white : Colors.grey[50],
//                             border: Border(
//                               bottom: BorderSide(color: Colors.grey[300]!),
//                             ),
//                           ),
//                           child: Row(
//                             children: [
//                               Expanded(
//                                 flex: 3,
//                                 child: Text(item.designation ?? ''),
//                               ),
//                               Expanded(
//                                 flex: 2,
//                                 child: Text(
//                                   item.etat ?? '-',
//                                   textAlign: TextAlign.center,
//                                 ),
//                               ),
//                               Expanded(
//                                 flex: 1,
//                                 child: Text(
//                                   item.quantite.toString(),
//                                   textAlign: TextAlign.right,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         );
//                       }),
//                     ],
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 24),

//             // Bouton retour
//             Row(
//               children: [
//                 Expanded(
//                   child: ElevatedButton.icon(
//                     onPressed: () => Navigator.of(context).pop(),
//                     icon: const Icon(Icons.arrow_back, color: Colors.white),
//                     label: const Text(
//                       'Retour à la liste',
//                       style: TextStyle(color: Colors.white),
//                     ),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.grey[600],
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
// ignore: file_names
import 'package:flareline_template/services/dechargeService.dart';
import 'package:flutter/material.dart';
import '../models/decharge.dart';
import '../models/mvtStockImmo.dart';
import 'dart:typed_data';
import 'dart:html' as html;

class DechargeDetailScreen extends StatelessWidget {
  final Decharge decharge;
  final Color buttonColor;
  final Color headerRowColor;
  final Color accentColor;

  const DechargeDetailScreen({
    super.key,
    required this.decharge,
    required this.buttonColor,
    required this.headerRowColor,
    required this.accentColor,
  });
  void openPdfWeb(Uint8List pdfBytes, String filename) {
    final blob = html.Blob([pdfBytes], 'application/pdf');
  final url = html.Url.createObjectUrlFromBlob(blob);

  final anchor = html.AnchorElement(href: url)
    ..setAttribute("download", filename); // Nom du fichier
  html.document.body?.append(anchor);
  anchor.click(); // Simule le clic pour lancer le téléchargement
  anchor.remove();

  html.Url.revokeObjectUrl(url);

}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Décharge ${decharge.numeroSalle ?? ''}"),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête
            Container(
              padding: const EdgeInsets.all(24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    'assets/logo1.png',
                    width: 120,
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'DÉCHARGE',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Salle : ${decharge.numeroSalle ?? ''}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: buttonColor,
                          ),
                        ),
                        Text(
                          'Bureau : ${decharge.bureau ?? ''}',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Informations sur la direction et les responsables
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(right: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Direction',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          decharge.direction ?? '',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: accentColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(left: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Responsables',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 12),
                        for (var resp in decharge.responsables)
                          Text(
                            resp,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: accentColor,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Tableau des matériels
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Matériels',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      // En-tête
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: headerRowColor,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8),
                          ),
                        ),
                        child: Row(
                          children: const [
                            Expanded(
                              flex: 3,
                              child: Text(
                                'Désignation',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  
                                ),
                                // textAlign: TextAlign.center,
                              ),
                            ),
                            // Expanded(
                            //   flex: 2,
                            //   child: Text(
                            //     'État',
                            //     style: TextStyle(
                            //       color: Colors.white,
                            //       fontWeight: FontWeight.bold,
                            //     ),
                            //     textAlign: TextAlign.center,
                            //   ),
                            // ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                'Quantité',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Lignes
                      ...decharge.materiels.asMap().entries.map((entry) {
                        int index = entry.key;
                        MvtStockImmo item = entry.value;

                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: index % 2 == 0 ? Colors.white : Colors.grey[50],
                            border: Border(
                              bottom: BorderSide(color: Colors.grey[300]!),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Text(item.designation ?? '',
                                ),
                              ),
                              // Expanded(
                              //   flex: 2,
                              //   child: Text(
                              //     item.etat ?? '-',
                              //     textAlign: TextAlign.center,
                              //   ),
                              // ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  item.quantite.toString(),
                                  textAlign: TextAlign.center,
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

            const SizedBox(height: 24),

            // Boutons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    label: const Text(
                      'Retour à la liste',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[600],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed:  () async {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Impression de la decharge...')),
                        
                      );
                      try {
                      final dechargeService = DechargeService();
                      final pdfBytes = await dechargeService.generatePdf( decharge.idDecharge ?? 0);
                      openPdfWeb(pdfBytes, 'DEC-${decharge.idDecharge}');

                      } catch (e) {
                        print('Erreur : $e');
                      }
                    },
                    icon: const Icon(Icons.print, color: Colors.white),
                    label: const Text(
                      'Imprimer',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor, // Même couleur que le texte "Salle"
                      padding: const EdgeInsets.symmetric(vertical: 16),
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
}