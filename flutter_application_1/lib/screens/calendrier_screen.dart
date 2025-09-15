import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/evenement.dart';
import '../models/type_evenement.dart';

class CalendrierLogistiqueScreen extends StatefulWidget {
  const CalendrierLogistiqueScreen({super.key});

  @override
  State<CalendrierLogistiqueScreen> createState() => _CalendrierLogistiqueScreenState();
}

class _CalendrierLogistiqueScreenState extends State<CalendrierLogistiqueScreen> {
  // Couleurs de la nouvelle charte graphique
  static const Color primaryRed = Color.fromARGB(255, 201, 15, 49);
  static const Color primaryYellow = Color(0xFFF9B70D);
  static const Color darkGray = Color(0xFF374151);
  static const Color lightGray = Color(0xFF9CA3AF);
  static const Color backgroundColor = Colors.white;

  DateTime currentDate = DateTime.now();
  DateTime? selectedDate;
  
  List<Evenement> events = [];

  void previousMonth() {
    setState(() {
      currentDate = DateTime(currentDate.year, currentDate.month - 1, 1);
    });
  }

  void nextMonth() {
    setState(() {
      currentDate = DateTime(currentDate.year, currentDate.month + 1, 1);
    });
  }

  void goToToday() {
    setState(() {
      currentDate = DateTime.now();
    });
  }

  void selectDate(DateTime date) {
    setState(() {
      selectedDate = date;
    });
    _showDayDetails(date);
  }

  List<Evenement> getEventsForDate(DateTime date) {
    return events.where((event) {
      return event.dateEvenement.year == date.year &&
          event.dateEvenement.month == date.month &&
          event.dateEvenement.day == date.day;
    }).toList();
  }

  void _showDayDetails(DateTime date) {
    final dayEvents = getEventsForDate(date);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: darkGray.withOpacity(0.05),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDateLong(date),
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: darkGray,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: darkGray),
                  ),
                ],
              ),
            ),
            
            // Events list
            Expanded(
              child: dayEvents.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.event_busy, size: 64, color: lightGray),
                          const SizedBox(height: 16),
                          Text(
                            'Aucun événement prévu',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: lightGray,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: dayEvents.length,
                      itemBuilder: (context, index) {
                        final event = dayEvents[index];
                        return _buildEventCard(event);
                      },
                    ),
            ),
            
            // Add event button
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _showAddEventDialog(date);
                  },
                  icon: const Icon(Icons.add, color: backgroundColor),
                  label: Text(
                    'Ajouter un événement',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: backgroundColor,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryYellow,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddEventDialog([DateTime? defaultDate]) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final timeController = TextEditingController();
    DateTime selectedEventDate = defaultDate ?? selectedDate ?? DateTime.now();
    // TypeEvenement selectedType = TypeEvenement.livraison;
    TypeEvenement selectedType = TypeEvenement.values.firstWhere((type) => type.description == "Livraison");
    String selectedAgency = 'Agence Aina';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.add_circle, color: primaryRed),
            const SizedBox(width: 8),
            Text(
              'Nouvel événement',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: darkGray,
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Titre
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Titre',
                    labelStyle: GoogleFonts.poppins(color: darkGray),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: primaryRed),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Type
                StatefulBuilder(
                  builder: (context, setDialogState) => DropdownButtonFormField<TypeEvenement>(
                    value: selectedType,
                    decoration: InputDecoration(
                      labelText: 'Type',
                      labelStyle: GoogleFonts.poppins(color: darkGray),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: primaryRed),
                      ),
                    ),
                    items: TypeEvenement.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Row(
                          children: [
                            Text(type.emoji ?? ''),
                            const SizedBox(width: 8),
                            Text(type.description, style: GoogleFonts.poppins()),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedType = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                
                // Date
                StatefulBuilder(
                  builder: (context, setDialogState) => InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedEventDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (date != null) {
                        setDialogState(() {
                          selectedEventDate = date;
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Date',
                        labelStyle: GoogleFonts.poppins(color: darkGray),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: primaryRed),
                        ),
                      ),
                      child: Text(
                        _formatDate(selectedEventDate),
                        style: GoogleFonts.poppins(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Heure
                TextField(
                  controller: timeController,
                  decoration: InputDecoration(
                    labelText: 'Heure (optionnel)',
                    labelStyle: GoogleFonts.poppins(color: darkGray),
                    hintText: '09:00',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: primaryRed),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Agence
                StatefulBuilder(
                  builder: (context, setDialogState) => DropdownButtonFormField<String>(
                    value: selectedAgency,
                    decoration: InputDecoration(
                      labelText: 'Agence',
                      labelStyle: GoogleFonts.poppins(color: darkGray),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: primaryRed),
                      ),
                    ),
                    items: [
                      'Agence Aina',
                      'Agence Farimbotsoa',
                      'Agence Vonjy',
                      'Agence Fanavotana',
                      'Toutes les agences',
                    ].map((agency) {
                      return DropdownMenuItem(
                        value: agency,
                        child: Text(agency, style: GoogleFonts.poppins()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedAgency = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                
                // Description
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Description (optionnel)',
                    labelStyle: GoogleFonts.poppins(color: darkGray),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: primaryRed),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Annuler',
              style: GoogleFonts.poppins(color: lightGray),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                final newEvent = Evenement(
                  idEvenement: events.length + 1,
                  titre: titleController.text,
                  typeEvenement: selectedType,
                  dateEvenement: selectedEventDate,
                  // time: timeController.text.isNotEmpty ? timeController.text : null,
                  description: descriptionController.text.isNotEmpty ? descriptionController.text : null,
                  // agency: selectedAgency,
                );
                
                setState(() {
                  events.add(newEvent);
                });
                
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Événement ajouté avec succès !'),
                    backgroundColor: primaryRed,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryYellow,
              foregroundColor: backgroundColor,
            ),
            child: Text('Ajouter', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(Evenement event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        // ignore: deprecated_member_use
        border: Border.all(color: (event.typeEvenement.color ?? Colors.transparent).withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: event.typeEvenement.color?.withOpacity(0.1) ?? Colors.transparent,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: event.typeEvenement.color?.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  event.typeEvenement.emoji ?? '',
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.titre ?? 'Sans titre',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: darkGray,
                      ),
                    ),
                    Text(
                      '⏰ ${event.dateEvenement.hour.toString().padLeft(2, '0')}:${event.dateEvenement.minute.toString().padLeft(2, '0')}',
                      style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: lightGray,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _deleteEvent(event.idEvenement!),
                icon: const Icon(Icons.delete_outline, color: primaryRed, size: 20),
              ),
            ],
          ),
          // if (event.agency != null) ...[
          //   const SizedBox(height: 8),
          //   Row(
          //     children: [
          //       Icon(Icons.business, size: 14, color: lightGray),
          //       const SizedBox(width: 4),
          //       Text(
          //         event.agency!,
          //         style: GoogleFonts.poppins(
          //           fontSize: 12,
          //           color: lightGray,
          //         ),
          //       ),
          //     ],
          //   ),
          // ],
          if (event.description != null) ...[
            const SizedBox(height: 8),
            Text(
              event.description!,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: darkGray,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _deleteEvent(int eventId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Supprimer l\'événement',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: darkGray,
          ),
        ),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer cet événement ?',
          style: GoogleFonts.poppins(color: darkGray),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler', style: GoogleFonts.poppins(color: lightGray)),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                events.removeWhere((event) => event.idEvenement == eventId);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Événement supprimé'),
                  backgroundColor: primaryRed,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryRed,
              foregroundColor: backgroundColor,
            ),
            child: Text('Supprimer', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatDateLong(DateTime date) {
    const months = [
      'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
      'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
    ];
    const weekdays = [
      'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'
    ];
    
    final weekday = weekdays[date.weekday - 1];
    final day = date.day;
    final month = months[date.month - 1];
    final year = date.year;
    
    return '$weekday $day $month $year';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: backgroundColor,
      backgroundColor: Color(0xFFF8F9FA),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: darkGray.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Calendrier Logistique',
                        style: GoogleFonts.poppins(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 23, 23, 23),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Planification des livraisons, inventaires et événements',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: lightGray,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showAddEventDialog(),
                    icon: const Icon(Icons.add, color: backgroundColor),
                    label: Text(
                      'Ajouter Événement',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: backgroundColor,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryYellow,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Navigation du calendrier
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: darkGray.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Navigation
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: previousMonth,
                            icon: const Icon(Icons.chevron_left, color: darkGray, size: 28),
                            style: IconButton.styleFrom(
                              // ignore: deprecated_member_use
                              backgroundColor: darkGray.withOpacity(0.1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          SizedBox(
                            width: 200,
                            child: Text(
                              '${_getMonthName(currentDate.month)} ${currentDate.year}',
                              style: GoogleFonts.poppins(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: darkGray,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(width: 16),
                          IconButton(
                            onPressed: nextMonth,
                            icon: const Icon(Icons.chevron_right, color: darkGray, size: 28),
                            style: IconButton.styleFrom(
                              // ignore: deprecated_member_use
                              backgroundColor: darkGray.withOpacity(0.1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: goToToday,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryRed,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Aujourd\'hui',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Légende
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: TypeEvenement.values.map((type) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              // ignore: deprecated_member_use
                              color: type.color?.withOpacity(0.3) ?? Colors.transparent,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            type.description,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: darkGray,
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // En-têtes des jours
                  Row(
                    children: ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim']
                        .map((day) => Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                child: Text(
                                  day,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: lightGray,
                                  ),
                                ),
                              ),
                            ))
                        .toList(),
                  ),

                  const SizedBox(height: 8),

                  // Grille du calendrier
                   _buildCalendarGrid(),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Statistiques
            _buildStatistics(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatistics() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    // Calculs statistiques
    final weekDeliveries = events.where((event) {
      return event.typeEvenement.description == "Livraison" &&
          event.dateEvenement.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
          event.dateEvenement.isBefore(endOfWeek.add(const Duration(days: 1)));
    }).length;

    final upcomingInventories = events.where((event) {
      return event.typeEvenement.description == "Inventaire" &&
          event.dateEvenement.isAfter(now.subtract(const Duration(days: 1)));
    }).length;

    final monthTrainings = events.where((event) {
      return event.typeEvenement.description == "Formation" &&
          event.dateEvenement.isAfter(startOfMonth.subtract(const Duration(days: 1))) &&
          event.dateEvenement.isBefore(endOfMonth.add(const Duration(days: 1)));
    }).length;

    final urgentMaintenance = events.where((event) {
      final urgentDate = now.add(const Duration(days: 3));
      return event.typeEvenement.description == "Maintenance" &&
          event.dateEvenement.isAfter(now.subtract(const Duration(days: 1))) &&
          event.dateEvenement.isBefore(urgentDate.add(const Duration(days: 1)));
    }).length;

    final stats = [
      {
        'title': 'Livraisons cette semaine',
        'value': weekDeliveries,
        'icon': '🚚',
        'color': primaryRed,
      },
      {
        'title': 'Inventaires prévus',
        'value': upcomingInventories,
        'icon': '📦',
        'color': primaryYellow,
      },
      {
        'title': 'Formations ce mois',
        'value': monthTrainings,
        'icon': '🎓',
        'color': darkGray,
      },
      {
        'title': 'Maintenances urgentes',
        'value': urgentMaintenance,
        'icon': '🔧',
        'color': primaryRed,
      },
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 2.5,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: stats.map((stat) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                // ignore: deprecated_member_use
                color: darkGray.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: (stat['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  stat['icon'] as String,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      stat['title'] as String,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: lightGray,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      (stat['value'] as int).toString(),
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: stat['color'] as Color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
      'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
    ];
    return months[month - 1];
  }

   Widget _buildCalendarGrid() {
  final firstDayOfMonth = DateTime(currentDate.year, currentDate.month, 1);
  // final lastDayOfMonth = DateTime(currentDate.year, currentDate.month + 1, 0);

  // Calculer le premier lundi à afficher
  final startDate = firstDayOfMonth.subtract(
    Duration(days: (firstDayOfMonth.weekday - 1) % 7),
  );

  final days = <Widget>[];
  final today = DateTime.now();

  for (int i = 0; i < 42; i++) {
    final date = startDate.add(Duration(days: i));
    final isCurrentMonth = date.month == currentDate.month;
    final isToday = date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;
    final isSelected = selectedDate != null &&
        date.year == selectedDate!.year &&
        date.month == selectedDate!.month &&
        date.day == selectedDate!.day;
    final dayEvents = getEventsForDate(date);

    days.add(
      GestureDetector(
        onTap: () => selectDate(date),
        child: Container(
          height: 100,
          margin: const EdgeInsets.all(1),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected
                // ignore: deprecated_member_use
                ? primaryRed.withOpacity(0.1)
                : isToday
                    // ignore: deprecated_member_use
                    ? primaryYellow.withOpacity(0.2)
                    : backgroundColor,
            border: isSelected
                ? Border.all(color: primaryRed, width: 2)
                : isToday
                    ? Border.all(color: primaryYellow, width: 2)
                    // ignore: deprecated_member_use
                    : Border.all(color: lightGray.withOpacity(0.2)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                date.day.toString(),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                  color: isCurrentMonth
                      ? isToday
                          // ignore: deprecated_member_use
                          ? primaryYellow.withOpacity(0.8)
                          : darkGray
                      : lightGray,
                ),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: dayEvents.take(3).map((event) {
                    return Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 2),
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        // ignore: deprecated_member_use
                        // color: event.typeEvenement.color.withOpacity(0.7),
                        color: event.typeEvenement.description == "Livraison"
                            ? primaryRed.withOpacity(0.7)
                            : event.typeEvenement.description == "Inventaire"
                                ? primaryYellow.withOpacity(0.7)
                                : event.typeEvenement.description == "Formation"
                                    ? darkGray.withOpacity(0.7)
                                    : event.typeEvenement.description == "Maintenance"
                                        ? primaryRed.withOpacity(0.7)
                                        : lightGray.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        event.titre ?? 'Sans titre',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  return GridView.count(
    crossAxisCount: 7,
    physics: const NeverScrollableScrollPhysics(),
    shrinkWrap: true,
    children: days,
  );
}
// Remove duplicate TypeEvenement definition and use the imported one from models/type_evenement.dart
}



