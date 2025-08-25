import 'package:flareline_template/screens/admin_commande_screen.dart';
import 'package:flareline_template/screens/bon_de_sortie_screen.dart';
import 'package:flareline_template/screens/calendrier_screen.dart';
import 'package:flareline_template/screens/inventaire_screen.dart';
import 'package:flareline_template/screens/mouvement_stock_screen.dart';
import 'package:flareline_template/screens/login_screen.dart';
import 'package:flareline_template/screens/statistique_screen.dart';
import 'package:flareline_template/screens/article_screen.dart';
import 'package:flareline_template/screens/facture_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/bon_de_commande_screen.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import 'package:animate_do/animate_do.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int selectedIndex = 0;
  bool isCollapsed = false;
  bool _playAnimation = false;
  final List<Map<String, dynamic>> navItems = [
    {'icon': Icons.shopping_cart_outlined, 'label': 'Commandes'},
    {'icon': Icons.bar_chart, 'label': 'Statistiques'},
    {'icon': Icons.inventory_rounded, 'label': 'Inventaire'},
    {'icon': Icons.calendar_month, 'label': 'Calendrier'},
    {'icon': Icons.blind_outlined, 'label': 'Mouvement'},
    {'icon': Icons.production_quantity_limits, 'label': 'Articles'},
    {'icon': Icons.article, 'label': 'Factures'},
    {'icon': Icons.task_outlined, 'label': 'Admin commande'},
    {'icon': Icons.task_outlined, 'label': 'Bon de sortie'},

  ];

  Widget _buildScreen() {
    switch (selectedIndex) {
      case 0:
        return const BonDeCommandeScreen();
      case 1:
        return const StatistiqueScreen();
      case 2:
        return  InventoryManagementScreen();
      case 3:
        return const CalendrierLogistiqueScreen();
      case 4:
        return const MouvementStockScreen();
      case 5:
        return  ArticleScreen();
      case 6:
        return FactureScreen();
      case 7:
        return const AdminCommandeScreen();
      case 8:
        return const BonDeSortieScreen();
      default:
        return const MouvementStockScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // final screenWidth = 20000;

    final sidebarWidth = isCollapsed ? 80.0 : (screenWidth * 0.3).clamp(160.0, 240.0);

    return SafeArea(
      child: Scaffold(
        body: Row(
          children: [
            // Sidebar
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: sidebarWidth,
              color: const Color.fromARGB(255, 255, 255, 255),
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  // En-tête : logo + bouton collapse
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: isCollapsed
                          ? MainAxisAlignment.center
                          : MainAxisAlignment.spaceBetween,
                      children: [
                            if (!isCollapsed)
                            Flexible(
                              child: SizedBox(
                                height: 45,
                                child: Image.asset(
                                  'assets/logo1.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                        IconButton(
                          icon: Icon(
                            isCollapsed ? Icons.keyboard_arrow_right : Icons.keyboard_arrow_left,
                            color: Colors.black54,
                          ),
                          onPressed: () {
                            setState(() => isCollapsed = !isCollapsed);
                          },
                          tooltip: isCollapsed ? 'Expand sidebar' : 'Collapse sidebar',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Menu de navigation
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: navItems.length,
                      itemBuilder: (context, index) {
                        final item = navItems[index];
                        final bool isSelected = selectedIndex == index;

                        return InkWell(
                          onTap: () => setState(() => selectedIndex = index),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  // ? const Color.fromARGB(243, 217, 15, 52)
                                  ? Colors.transparent

                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  item['icon'],
                                  color: isSelected
                                      ? const Color.fromARGB(243, 217, 15, 52)
                                      : Colors.black54,
                                ),
                                if (!isCollapsed) ...[
                                  const SizedBox(width: 16),
                                  Flexible(
                                    fit: FlexFit.loose,
                                    child: Text(
                                      item['label'],
                                      style: GoogleFonts.urbanist(
                                        fontSize: 16,
                                        fontWeight:
                                            isSelected ? FontWeight.bold : FontWeight.normal,
                                        color: isSelected
                                            // ? const Color.fromARGB(255, 255, 255, 255)
                                             ? const Color.fromARGB(243, 217, 15, 52)
                                            : Colors.black87,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      softWrap: false,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Zone de contenu principale avec Top Bar
            Expanded(
              child: Column(
                children: [
                  // Top Bar
                  Container(
                    height: 60,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Barre de recherche large
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: "Rechercher...",
                              hintStyle: const TextStyle(color: Colors.grey),
                              prefixIcon: const Icon(Icons.search),
                              filled: true,
                              fillColor: const Color(0xFFF0F2F5),
                              contentPadding: const EdgeInsets.symmetric(vertical: 0),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ShakeX(
                          animate: _playAnimation,
                          duration: const Duration(milliseconds: 600),
                          child: IconButton(
                            icon: const Icon(Icons.notifications_none),
                            onPressed: () async {
                              // Jouer le son
                              final player = AudioPlayer();
                              await player.play(AssetSource('sounds/notification.mp3'));

                              // Vibration si disponible
                              if (await Vibration.hasVibrator() ?? false) {
                                Vibration.vibrate(duration: 150);
                              }

                              // Déclencher l’animation
                              setState(() {
                                _playAnimation = true;
                              });

                              // Arrêter l’animation après un court délai
                              Future.delayed(const Duration(milliseconds: 700), () {
                                if (mounted) {
                                  setState(() {
                                    _playAnimation = false;
                                  });
                                }
                              });
                            },
                            tooltip: 'Notifications',
                          ),
                        ),

                        // Avatar profil avec menu déroulant
                        PopupMenuButton<String>(
                          icon: const CircleAvatar(
                            radius: 18,
                            backgroundImage: AssetImage('assets/profile.jpg'),
                          ),
                          onSelected: (value) {
                            if (value == 'logout') {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('Déconnexion'),
                                    content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(),
                                        child: const Text('Annuler'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pushReplacement(
                                            MaterialPageRoute(
                                              builder: (context) => const LoginScreen(),
                                            ),
                                          );
                                        },
                                        child: const Text('Déconnexion'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            } else if (value == 'profile') {
                              
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(value: 'profile', child: Text('Profil')),
                            const PopupMenuItem(value: 'logout', child: Text('Déconnexion')),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Contenu principal
                  Expanded(
                    child: Container(
                      color: const Color(0xFFF8F9FA),
                      padding: const EdgeInsets.all(24),
                      child: _buildScreen(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
