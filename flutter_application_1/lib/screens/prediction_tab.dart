import 'package:flutter/material.dart';
import 'dart:math' as math;

class PredictionTab extends StatefulWidget {
  const PredictionTab({super.key});

  @override
  State<PredictionTab> createState() => _PredictionTabState();
}

class _PredictionTabState extends State<PredictionTab> {
  DateTime? _predictionDate;
  String? _selectedAgency;

  final List<String> agencies = [
    'Agence Aina',
    'Agence Fanavotana',
    'Agence Vonjy',
    'Agence Farimbotsoa',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Prédictions de commandes', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Date de prédiction', style: TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now().add(const Duration(days: 1)),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 730)),
                          );
                          if (date != null) {
                            setState(() {
                              _predictionDate = date;
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                _predictionDate?.toString().substring(0, 10) ?? 'Sélectionner une date',
                                style: TextStyle(color: _predictionDate != null ? Colors.black : Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Agence', style: TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedAgency,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                        hint: const Text('Toutes les agences'),
                        items: agencies.map((agency) => DropdownMenuItem(value: agency, child: Text(agency))).toList(),
                        onChanged: (value) => setState(() => _selectedAgency = value),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _generatePrediction,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF9B70D), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                child: const Text(' Prédire', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _generatePrediction() {
    if (_predictionDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez sélectionner une date')));
      return;
    }

    final isWeekend = _predictionDate!.weekday == DateTime.saturday || _predictionDate!.weekday == DateTime.sunday;
    final basePrediction = isWeekend ? 5 : 15;

    final agencyMultipliers = {
      'Agence Aina': 1.5,
      'Agence Farimbotsoa': 1.2,
      'Agence Vonjy': 0.8,
      'Agence Fanavotana': 1.0,
    };

    final multiplier = _selectedAgency != null ? (agencyMultipliers[_selectedAgency] ?? 1.0) : 1.0;
    final predictedOrders = (basePrediction * multiplier).round();
    final confidence = 75 + math.Random().nextInt(20);
    final predictedRevenue = predictedOrders * (800 + math.Random().nextDouble() * 400);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🔮 Prédiction générée'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date: ${_predictionDate!.toString().substring(0, 10)}'),
            if (_selectedAgency != null) Text('Agence: $_selectedAgency'),
            const SizedBox(height: 16),
            Text('Commandes prédites: $predictedOrders'),
            Text('Confiance: $confidence%'),
            Text('CA estimé: ${predictedRevenue.toStringAsFixed(0)} €'),
          ],
        ),
        actions: [
          TextButton(child: const Text('OK'), onPressed: () => Navigator.of(context).pop()),
        ],
      ),
    );
  }
}
