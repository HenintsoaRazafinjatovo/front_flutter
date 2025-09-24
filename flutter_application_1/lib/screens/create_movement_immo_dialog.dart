import 'package:flutter/material.dart';
import '../models/materiel.dart';
import '../models/mvtStockImmo.dart';
import '../models/direction.dart';
import '../models/attribution.dart';
import '../models/decharge.dart';
import '../models/salle.dart';
import '../services/salleService.dart';
import '../services/mvtStockImmoService.dart';

class CreateMovementImmoDialog extends StatefulWidget {
  final List<Materiel> materiels;
  final List<Direction> directions;
  final Function(List<MvtStockImmo>) onMovementCreated;
  final List<Salle> salles;
  

  const CreateMovementImmoDialog({
    super.key,
    required this.materiels,
    required this.directions,
    required this.onMovementCreated,
    required this.salles,
  });

  @override
  State<CreateMovementImmoDialog> createState() =>
      _CreateMovementImmoDialogState();
}

class _CreateMovementImmoDialogState extends State<CreateMovementImmoDialog> {
  static const Color primaryColor = Color(0xFFF9B70D);

  String selectedMovementType = '';
  String? selectedEntreeSource;
  Direction? selectedDirection;
  Salle? selectedSalle;
  final TextEditingController _descriptionController = TextEditingController();
  bool _isLoading = false;
  bool _submitted = false;


  // Pour les matériels sélectionnés
  List<_MaterielSelection> materielSelections = [];
 

  @override
  void initState() {
    super.initState();
    if (widget.materiels.isNotEmpty) {
      materielSelections.add(_MaterielSelection());
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.add_circle_outline, color: primaryColor),
          SizedBox(width: 8),
          Text('Nouveau mouvement d\'immobilisation'),
        ],
      ),
      content: _isLoading
          ? const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            )
          : SingleChildScrollView(
              child: SizedBox(
                width: 800,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMovementTypeSelection(),
                    const SizedBox(height: 16),
                    if (selectedMovementType == 'entree') ...[
                      _buildEntreeSourceSelection(),
                      const SizedBox(height: 16),
                      _buildDescriptionInput(),
                    ],
                    if (selectedMovementType == 'sortie') ...[
                      _buildDirectionSelection(),
                      const SizedBox(height: 16),
                      _buildSalleSelection(),
                      const SizedBox(height: 16),
                      _buildDescriptionInput(),
                    ],
                    const SizedBox(height: 16),
                    _buildMaterielList(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
      actions: _isLoading
          ? null
          : [
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Annuler')),
              ElevatedButton(
                  onPressed: _createMovement,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                  ),
                  child: const Text(
                    'Effectuer',
                    style: TextStyle(color: Colors.white),
                  )),
            ],
    );
  }

  Widget _buildMovementTypeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Type de mouvement', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: RadioListTile<String>(
                  title: const Row(
                    children: [
                      Icon(Icons.arrow_downward, color: Colors.green, size: 20),
                      SizedBox(width: 8),
                      Text('Entrée'),
                    ],
                  ),
                  value: 'entree',
                  groupValue: selectedMovementType,
                  onChanged: (value) {
                    setState(() {
                      selectedMovementType = value ?? '';
                      selectedDirection = null;
                      selectedSalle = null;
                    });
                  },
                ),
              ),
              Expanded(
                child: RadioListTile<String>(
                  title: const Row(
                    children: [
                      Icon(Icons.arrow_upward, color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Text('Sortie'),
                    ],
                  ),
                  value: 'sortie',
                  groupValue: selectedMovementType,
                  onChanged: (value) {
                    setState(() {
                      selectedMovementType = value ?? '';
                      selectedEntreeSource = null;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
        if (_submitted && selectedMovementType.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text('Veuillez sélectionner un type', style: TextStyle(color: Colors.red)),
          )
      ],
    );
  }

  Widget _buildEntreeSourceSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Source de financement', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('Fond Propre'),
                  value: 'fond_propre',
                  groupValue: selectedEntreeSource,
                  onChanged: (value) => setState(() => selectedEntreeSource = value),
                ),
              ),
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('Subvention'),
                  value: 'subvention',
                  groupValue: selectedEntreeSource,
                  onChanged: (value) => setState(() => selectedEntreeSource = value),
                ),
              ),
            ],
          ),
        ),
        if (_submitted && selectedEntreeSource == null)
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text('Veuillez sélectionner une source', style: TextStyle(color: Colors.red)),
          )
      ],
    );
  }

  Widget _buildDirectionSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Direction', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        DropdownButtonFormField<Direction>(
          value: selectedDirection,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            // prefixIcon: const Icon(Icons.domain),
            errorText: _submitted && selectedDirection == null ? 'Veuillez sélectionner une direction' : null,
          ),
          items: widget.directions
              .map((d) => DropdownMenuItem(value: d, child: Text(d.nom)))
              .toList(),
          onChanged: (value) => setState(() => selectedDirection = value),
        ),
      ],
    );
  }

  Widget _buildSalleSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Salle', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        DropdownButtonFormField<Salle>(
          value: selectedSalle,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            // prefixIcon: const Icon(Icons.meeting_room),
            errorText: _submitted && selectedSalle == null ? 'Veuillez sélectionner une salle' : null,
          ),
          items: widget.salles.map((s) => DropdownMenuItem(
            value: s,
            child: Text('${s.numero.toString()} - ${s.bureau.toString()}'))).toList(),
          onChanged: (value) => setState(() => selectedSalle = value),
        ),
      ],
    );
  }

  Widget _buildDescriptionInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Description', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: _descriptionController,
          maxLines: 3,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            // prefixIcon: const Icon(Icons.description),
            errorText: _submitted && _descriptionController.text.isEmpty
                ? 'Veuillez entrer une description'
                : null,
          ),
          onChanged: (v) => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildMaterielList() {
    return Column(
      children: [
        for (int i = 0; i < materielSelections.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: DropdownButtonFormField<String>(
                    value: materielSelections[i].materielId,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      hintText: 'Choisir un matériel',
                      errorText: _submitted &&
                              (materielSelections[i].materielId == null ||
                                  materielSelections[i].materielId!.isEmpty)
                          ? 'Obligatoire'
                          : null,
                    ),
                    items: widget.materiels
                        .map((m) => DropdownMenuItem(
                              value: m.idMateriel.toString(),
                              child: Text('${m.designation} (${m.code})'),
                            ))
                        .toList(),
                    onChanged: (value) => setState(() {
                      materielSelections[i].materielId = value;
                    }),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      hintText: 'Quantité',
                      errorText: _submitted && materielSelections[i].quantity <= 0
                          ? 'Obligatoire'
                          : null,
                    ),
                    onChanged: (v) => setState(() {
                      materielSelections[i].quantity = int.tryParse(v) ?? 0;
                    }),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => setState(() {
                    materielSelections.removeAt(i);
                  }),
                ),
              ],
            ),
          ),
        TextButton.icon(
          onPressed: () => setState(() {
            materielSelections.add(_MaterielSelection());
          }),
          icon: const Icon(Icons.add),
          label: const Text('Ajouter matériel'),
        ),
      ],
    );
  }

  void _createMovement() async {
    setState(() {
      _submitted = true;
    });

    bool materielValid = materielSelections.every(
        (m) => m.materielId != null && m.materielId!.isNotEmpty && m.quantity > 0);

    if (selectedMovementType.isEmpty ||
        (selectedMovementType == 'entree' && selectedEntreeSource == null) ||
        (selectedMovementType == 'sortie' &&
            (selectedDirection == null || selectedSalle == null)) ||
        _descriptionController.text.isEmpty ||
        !materielValid) return;

    setState(() => _isLoading = true);

    try {
      final mvtStockImmoService = MvtStockImmoService();

      List<MvtStockImmo> mouvements = materielSelections.map((ms) {
        final materiel = widget.materiels
            .firstWhere((m) => m.idMateriel.toString() == ms.materielId);
        return MvtStockImmo(
          idMateriel: materiel.idMateriel,
          // quantite: selectedMovementType == 'sortie'
          //     ? -ms.quantity.toDouble()
          //     : ms.quantity.toDouble(),
          quantite: ms.quantity.toDouble(),
          materiel: materiel,
          designation: _descriptionController.text,
        );
      }).toList();

      if (selectedMovementType == 'entree') {
        int origineId = selectedEntreeSource == 'fond_propre' ? 1 : 2; // exemple
        final success =
            await mvtStockImmoService.createWithOrigine(materiels: mouvements, idOrigine: origineId);
        if (success) {
          // widget.onMovementCreated(mouvements);
          Navigator.of(context).pop();
          _showSnackBar("Entrée créée avec succès", isSuccess: true);
        } else {
          _showSnackBar("Échec de la création de l'entrée");
        }
      } else {
        final attribution = Attribution(
          dateAttribution: DateTime.now(),
          description: _descriptionController.text,
          direction: selectedDirection!.nom,
          idDirection: selectedDirection!.idDirection,
          idMvt: 0,
        );
        final decharge = Decharge(
          idSalle: selectedSalle!.idSalle,
          responsables: [],
          materiels: mouvements,
        );
        final success = await mvtStockImmoService.createWithAttribution(
            materiels: mouvements, attribution: attribution, decharge: decharge);
        if (success) {
          // widget.onMovementCreated(mouvements);
          Navigator.of(context).pop();
          _showSnackBar("Sortie créée avec succès", isSuccess: true);
        } else {
          _showSnackBar("Échec de la création de la sortie");
        }
      }
    } catch (e) {
      print("Erreur création mouvement: $e");
      _showSnackBar("Erreur: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {bool isSuccess = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: isSuccess ? 2 : 4),
      ));
    }
  }
}

class _MaterielSelection {
  String? materielId;
  int quantity = 0;
}
