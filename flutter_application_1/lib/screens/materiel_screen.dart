import 'package:flareline_template/models/nature.dart';
import 'package:flutter/material.dart';
import '../models/materiel.dart';
import '../services/materielService.dart';
import '../services/natureService.dart';
import 'dart:typed_data'; 
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:html' as html;
import 'dart:convert';



void main() {
  runApp(MaterielScreen());
}

class MaterielScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
   return MaterialApp(
  color: const Color.fromARGB(255, 189, 8, 8),
  title: 'Gestion des Matériels',
  debugShowCheckedModeBanner: false,
  theme: ThemeData(
    primarySwatch: Colors.blue,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    fontFamily: 'Poppins',
  ),
  localizationsDelegates: [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: const [
    Locale('fr', 'FR'),
    Locale('en', 'US'), // tu peux en ajouter d'autres si besoin
  ],
  home: GestionMaterielsPage(),
);

  }
}

class GestionMaterielsPage extends StatefulWidget {
  const GestionMaterielsPage({super.key});

  @override
  _GestionMaterielsPageState createState() => _GestionMaterielsPageState();
}

class _GestionMaterielsPageState extends State<GestionMaterielsPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _designationController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _referenceController = TextEditingController();

  // Contrôleurs de filtres
  final TextEditingController _filterDesignationController = TextEditingController();
  final TextEditingController _filterCodeController = TextEditingController();

  int currentPage = 1;
  int lastPage = 1;
  int itemsPerPage = 10;
  int totalMateriels = 0;

  List<Materiel> materiels = [];
  List<Materiel> filteredMateriels = [];
  List<Nature> natures = [];
  int? _selectedNatureId;
  DateTime? _selectedDateAcquisition;

   List<Materiel> get paginatedMateriels => materiels;

  // Getter pour le nombre total de pages
  int get totalPages => (materiels.length / itemsPerPage).ceil();

  // Couleurs définies
  static const Color buttonColor = Color(0xFFF9B70D);
  static const Color headerRowColor = Color.fromARGB(154, 131, 130, 129);
  static const Color accentColor = Colors.redAccent;

  @override
  void initState() {
    super.initState();
    _loadMateriels();
    _loadNatures();
    _filterDesignationController.addListener(_applyFilters);
    _filterCodeController.addListener(_applyFilters);
  }

  Future<void> _loadMateriels() async {
    try {
      final loadedMateriels = await MaterielService().getAllMateriels(page: currentPage, perPage: itemsPerPage);
      setState(() {
        materiels = loadedMateriels.data;
        filteredMateriels = loadedMateriels.data;
        currentPage = loadedMateriels.currentPage;
        lastPage = loadedMateriels.lastPage;
        totalMateriels = loadedMateriels.total;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur de chargement des matériels: $e")),
      );
    }
  }

  Future<void> _loadNatures() async {
    try {
      final loadedNatures = await NatureService().getAllNatures();
      setState(() {
        natures = loadedNatures;
      });
    } catch (e) {
      print("Erreur de chargement des natures: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur de chargement des natures: $e")),
      );
    }
  }

  void _applyFilters() {
    setState(() {
      filteredMateriels = materiels.where((materiel) {
        bool matchDesignation = _filterDesignationController.text.isEmpty ||
            (materiel.designation?.toLowerCase().contains(_filterDesignationController.text.toLowerCase()) ?? false);
        
        bool matchCode = _filterCodeController.text.isEmpty ||
            (materiel.code?.toLowerCase().contains(_filterCodeController.text.toLowerCase()) ?? false);

        return matchDesignation && matchCode;
      }).toList();
    });
  }

  void _clearForm() {
    _designationController.clear();
    _codeController.clear();
    _referenceController.clear();
    setState(() {
      _selectedNatureId = null;
      _selectedDateAcquisition = null;
    });
  }

  void _resetFilters() {
    _filterDesignationController.clear();
    _filterCodeController.clear();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateAcquisition ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('fr', 'FR'),
    );
    if (picked != null && picked != _selectedDateAcquisition) {
      setState(() {
        _selectedDateAcquisition = picked;
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
  Future<void> _saveMateriel() async {
  if (_formKey.currentState!.validate()) {
    final designation = _designationController.text;
    final code = _codeController.text;
    final reference = _referenceController.text;
    final nature = natures.firstWhere((nat) => nat.idNature == _selectedNatureId);

    final newMateriel = Materiel(
      designation: designation,
      code: code,
      reference: reference,
      dateAcquisition: _selectedDateAcquisition,
      nature: nature,
      idNature: _selectedNatureId,
    );

    try {
      final response = await MaterielService().createMateriel(newMateriel);

        if (response["success"] == true) {
          setState(() {
            materiels.add(newMateriel);
            _applyFilters();
          });

          _clearForm();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Matériel créé avec succès!', style: TextStyle(fontFamily: 'Poppins')),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          print('Erreur lors de la création du matériel : service a renvoyé false. Message: ${response["error"]}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur lors de la création du matériel.', style: TextStyle(fontFamily: 'Poppins')),
              backgroundColor: Colors.red,
            ),
          );
        }

    } catch (e, stackTrace) {
      // ✅ Log si exception (ex: timeout, 500, etc.)
      print('Exception lors de la création du matériel: $e');
      print('StackTrace: $stackTrace');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Une erreur est survenue : $e',
            style: TextStyle(fontFamily: 'Poppins'),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}


  void _editMateriel({Materiel? materiel}) {
    final designationController = TextEditingController(text: materiel?.designation ?? '');
    final codeController = TextEditingController(text: materiel?.code ?? '');
    final referenceController = TextEditingController(text: materiel?.reference ?? '');
    DateTime? selectedDate = materiel?.dateAcquisition;
    int? selectedNatureId = materiel?.idNature;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(materiel == null ? 'Nouveau matériel' : 'Modifier matériel'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: designationController,
                      decoration: const InputDecoration(labelText: 'Désignation'),
                    ),
                    TextFormField(
                      controller: codeController,
                      decoration: const InputDecoration(labelText: 'Code'),
                    ),
                    TextFormField(
                      controller: referenceController,
                      decoration: const InputDecoration(labelText: 'Référence'),
                    ),
                    SizedBox(height: 16),
                    InkWell(
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate ?? DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setDialogState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Date d\'acquisition',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          selectedDate != null ? _formatDate(selectedDate) : 'Sélectionner une date',
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      value: selectedNatureId,
                      items: natures.map((nature) {
                        return DropdownMenuItem<int>(
                          value: nature.idNature,
                          child: Text(nature.description ?? ''),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedNatureId = value;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Nature',
                        border: OutlineInputBorder(),
                      ),
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
                    final nature = selectedNatureId != null
                        ? natures.firstWhere((n) => n.idNature == selectedNatureId)
                        : null;
                    
                    final newMateriel = Materiel(
                      idMateriel: materiel?.idMateriel,
                      designation: designationController.text,
                      code: codeController.text,
                      reference: referenceController.text,
                      dateAcquisition: selectedDate,
                      idNature: selectedNatureId,
                      nature: nature,
                    );
                    Navigator.of(context).pop(newMateriel);
                  },
                  child: const Text('Enregistrer'),
                ),
              ],
            );
          },
        );
      },
    ).then((result) {
      if (result != null && result is Materiel) {
        setState(() {
          if (materiel == null) {
            materiels.add(result);
          } else {
            final index = materiels.indexWhere((m) => m.idMateriel == materiel.idMateriel);
            if (index != -1) {
              materiels[index] = result;
            }
          }
          _applyFilters();
        });
      }

      designationController.dispose();
      codeController.dispose();
      referenceController.dispose();
    });
  }

  Future<void> _deleteMateriel(Materiel materiel) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Confirmer la suppression',
            style: TextStyle(fontFamily: 'Poppins'),
          ),
          content: Text(
            'Êtes-vous sûr de vouloir supprimer le matériel "${materiel.designation}" ?',
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
                await MaterielService().deleteMateriel(materiel.idMateriel ?? 0);
                
                Navigator.of(context).pop();
                
                setState(() {
                  materiels.remove(materiel);
                  _applyFilters();
                });
              
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Matériel supprimé avec succès!',
                      style: TextStyle(fontFamily: 'Poppins'),
                    ),
                    backgroundColor: accentColor,
                  ),
                );
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

  void _showDetails(Materiel materiel) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Détails du matériel',
            style: TextStyle(fontFamily: 'Poppins'),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Désignation:', materiel.designation ?? ''),
              _buildDetailRow('Code:', materiel.code ?? ''),
              _buildDetailRow('Référence:', materiel.reference ?? ''),
              _buildDetailRow('Date d\'acquisition:', materiel.dateAcquisition != null ? _formatDate(materiel.dateAcquisition) : ''),
              _buildDetailRow('Nature:', materiel.nature?.description ?? ''),
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
  Widget _buildPaginationControls() {
  if (lastPage <= 1) return const SizedBox.shrink();

  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      IconButton(
        icon: const Icon(Icons.first_page),
        onPressed: currentPage == 1
            ? null
            : () {
                setState(() => currentPage = 1);
                _loadMateriels();
              },
      ),
      IconButton(
        icon: const Icon(Icons.chevron_left),
        onPressed: currentPage == 1
            ? null
            : () {
                setState(() => currentPage--);
                _loadMateriels();
              },
      ),

      // Current page avec background color
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFF9B70D),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '$currentPage / $lastPage',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),

      IconButton(
        icon: const Icon(Icons.chevron_right),
        onPressed: currentPage >= lastPage
            ? null
            : () {
                setState(() => currentPage++);
                _loadMateriels();
              },
      ),
      IconButton(
        icon: const Icon(Icons.last_page),
        onPressed: currentPage >= lastPage
            ? null
            : () {
                setState(() => currentPage = lastPage);
                _loadMateriels();
              },
      ),
      const SizedBox(width: 16),
      DropdownButton<int>(
        value: itemsPerPage,
        items: [5, 10, 20, 50].map((value) {
          return DropdownMenuItem<int>(
            value: value,
            child: Text('$value / page'),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() {
              itemsPerPage = value;
              currentPage = 1;
            });
            _loadMateriels();
          }
        },
      ),
    ],
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
          'Gestion des Matériels',
          style: TextStyle(
            fontFamily: 'Poppins',
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
                        'Créer un nouveau matériel',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      SizedBox(height: 16),

                      // Ligne Désignation + Code
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _designationController,
                              style: TextStyle(fontFamily: 'Poppins'),
                              decoration: InputDecoration(
                                labelText: 'Désignation',
                                labelStyle: TextStyle(fontFamily: 'Poppins'),
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Veuillez saisir une désignation';
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

                      // Ligne Référence + Date d'acquisition
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _referenceController,
                              style: TextStyle(fontFamily: 'Poppins'),
                              decoration: InputDecoration(
                                labelText: 'Référence',
                                labelStyle: TextStyle(fontFamily: 'Poppins'),
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Veuillez saisir une référence';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: InkWell(
                              onTap: () => _selectDate(context),
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: 'Date d\'acquisition',
                                  labelStyle: TextStyle(fontFamily: 'Poppins'),
                                  border: OutlineInputBorder(),
                                  suffixIcon: Icon(Icons.calendar_today),
                                ),
                                child: Text(
                                  _selectedDateAcquisition != null
                                      ? _formatDate(_selectedDateAcquisition)
                                      : 'Sélectionner une date',
                                  style: TextStyle(fontFamily: 'Poppins'),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 16),

                      // Ligne Nature + Boutons
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: DropdownButtonFormField<int>(
                              value: _selectedNatureId,
                              items: natures.map((nature) {
                                return DropdownMenuItem<int>(
                                  value: nature.idNature,
                                  child: Text(
                                    nature.description ?? '',
                                    style: TextStyle(fontFamily: 'Poppins'),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedNatureId = value;
                                });
                              },
                              decoration: InputDecoration(
                                labelText: 'Nature',
                                labelStyle: TextStyle(fontFamily: 'Poppins'),
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                              ),
                              validator: (value) {
                                if (value == null) {
                                  return 'Veuillez choisir une nature';
                                }
                                return null;
                              },
                            ),
                          ),

                          SizedBox(width: 16),

                          // Boutons
                          Expanded(
                            flex: 1,
                            child: Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _saveMateriel,
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

            // Liste des matériels avec filtres intégrés
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
                      'Liste des Matériels (${filteredMateriels.length})',
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
                            controller: _filterDesignationController,
                            style: TextStyle(fontFamily: 'Poppins'),
                            decoration: InputDecoration(
                              labelText: 'Filtrer par désignation',
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
                      child: filteredMateriels.isEmpty
                          ? Padding(
                              padding: EdgeInsets.all(32.0),
                              child: Center(
                                child: Text(
                                  'Aucun matériel trouvé',
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
                                      'Désignation',
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
                                      'Référence',
                                      style: TextStyle(fontFamily: 'Poppins'),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Date acq.',
                                      style: TextStyle(fontFamily: 'Poppins'),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Nature',
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
                                rows: filteredMateriels.map((materiel) {
                                  return DataRow(
                                    cells: [
                                      DataCell(
                                        Text(
                                          materiel.designation ?? '',
                                          style: TextStyle(fontFamily: 'Poppins'),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          materiel.code ?? '',
                                          style: TextStyle(fontFamily: 'Poppins'),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          materiel.reference ?? '',
                                          style: TextStyle(fontFamily: 'Poppins'),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          materiel.dateAcquisition != null
                                              ? _formatDate(materiel.dateAcquisition)
                                              : '',
                                          style: TextStyle(fontFamily: 'Poppins'),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          materiel.nature?.description ?? '',
                                          style: TextStyle(fontFamily: 'Poppins'),
                                        ),
                                      ),
                                      DataCell(
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: Icon(Icons.visibility, color: const Color.fromARGB(255, 83, 87, 91)),
                                              onPressed: () => _showDetails(materiel),
                                              tooltip: 'Détails',
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.edit, color: buttonColor),
                                              onPressed: () => _editMateriel(materiel: materiel),
                                              tooltip: 'Modifier',
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.delete, color: accentColor),
                                              onPressed: () => _deleteMateriel(materiel),
                                              tooltip: 'Supprimer',
                                            ),
                                           IconButton(
                                            icon: Icon(Icons.qr_code, color: const Color.fromARGB(255, 49, 34, 34)),
                                            tooltip: 'Imprimer le QR Code',
                                            onPressed: () async {
                                              if (materiel.idMateriel == null) return;

                                              Uint8List? qrImage = await MaterielService().getMaterielQr(materiel.idMateriel!);

                                              if (qrImage != null) {
                                                final base64Image = base64Encode(qrImage);
                                                final imageSrc = 'data:image/png;base64,$base64Image';

                                                // Créer un iframe invisible
                                                final iframe = html.IFrameElement()
                                                  ..style.border = 'none'
                                                  ..style.width = '0px'
                                                  ..style.height = '0px'
                                                  ..srcdoc = '''
                                                    <html>
                                                      <body style="text-align:center;">
                                                        <img src="$imageSrc" />
                                                        <script>
                                                          window.onload = function() {
                                                            window.print();
                                                          }
                                                        </script>
                                                      </body>
                                                    </html>
                                                  ''';

                                                html.document.body!.append(iframe);

                                                // Supprimer l'iframe après un petit délai pour laisser le temps à l'impression
                                                Future.delayed(Duration(seconds: 1), () {
                                                  iframe.remove();
                                                });
                                              } else {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text('Impossible de récupérer le QR code'),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                );
                                              }
                                            },
                                          ),                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                    ),
                  _buildPaginationControls(),
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
    _designationController.dispose();
    _codeController.dispose();
    _referenceController.dispose();
    _filterDesignationController.dispose();
    _filterCodeController.dispose();
    super.dispose();
  }
}