import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import 'package:animate_do/animate_do.dart';

import '../screens/admin_commande_screen.dart';
import '../screens/bon_de_commande_screen.dart';
import '../screens/bon_de_livraison_screen.dart';
import '../screens/calendrier_screen.dart';
import '../screens/inventaire_screen.dart';
import '../screens/mouvement_stock_screen.dart';
import '../screens/login_screen.dart';
import '../screens/article_screen.dart';
import '../screens/facture_screen.dart';
import '../screens/materiel_screen.dart';
import '../screens/mouvement_stock_immo_screen.dart';
import '../screens/inventaire_immo_screen.dart';
import '../screens/statistiqueImmo_screen.dart';
import '../screens/decharge_screen.dart';

import '../screens/dashboard_tab.dart';
import '../screens/charts_tab.dart';
import '../screens/prediction_tab.dart';

import '../screens/chatbot_lancher.dart'; // Ton widget ChatbotLauncher

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int selectedIndex = 0;
  String? selectedStatTab;
  bool isCollapsed = false;
  bool _playAnimation = false;
  bool statMenuOpen = false;

  final List<Map<String, dynamic>> navItems = [
    {'icon': Icons.shopping_cart_outlined, 'label': 'Commandes'},
    {
      'icon': Icons.bar_chart,
      'label': 'Statistiques',
      'subItems': [
        {'icon': Icons.dashboard, 'label': 'Récapitulatif', 'widget': const DashboardTab()},
        {'icon': Icons.show_chart, 'label': 'Graphes', 'widget': const ChartsTab()},
        {'icon': Icons.analytics, 'label': 'Prédiction', 'widget': const PredictionTab()},
      ]
    },
    {'icon': Icons.inventory_rounded, 'label': 'Inventaire'},
    {'icon': Icons.calendar_month, 'label': 'Calendrier'},
    {'icon': Icons.blind_outlined, 'label': 'Mouvement'},
    {'icon': Icons.production_quantity_limits, 'label': 'Articles'},
    {'icon': Icons.article, 'label': 'Factures'},
    {'icon': Icons.task_outlined, 'label': 'Admin commande'},
    {'icon': Icons.task_outlined, 'label': 'Bon de livraison'},
    {'icon': Icons.task_outlined, 'label': 'Matériels'},
    {'icon': Icons.task_outlined, 'label': 'Mouvement stock immo'},
    {'icon': Icons.inventory_2_sharp, 'label': 'Inventaire immo'},
    {'icon': Icons.bar_chart, 'label': 'Statistique immo'},
    {'icon': Icons.settings, 'label': 'Decharge'},
  ];

  Widget _buildScreen() {
    if (selectedIndex == 1 && selectedStatTab != null) {
      final subItem = navItems[1]['subItems']
          .firstWhere((item) => item['label'] == selectedStatTab);
      return subItem['widget'];
    }

    switch (selectedIndex) {
      case 0:
        return const BonDeCommandeScreen();
      case 1:
        return Center(child: Text('Sélectionnez un sous-menu Statistiques'));
      case 2:
        return InventoryManagementScreen();
      case 3:
        return const CalendrierLogistiqueScreen();
      case 4:
        return const MouvementStockScreen();
      case 5:
        return ArticleScreen();
      case 6:
        return FactureScreen();
      case 7:
        return const AdminCommandeScreen();
      case 8:
        return const BonDeLivraisonScreen();
      case 9:
        return MaterielScreen();
      case 10:
        return MouvementStockImmoScreen();
        case 11:
        return InventoryImmoManagementScreen();
      case 12:
        return StatistiqueImmoScreen();
      case 13:
        return  DechargeScreen();
      default:
        return const MouvementStockScreen();
    }
  }

  void _handleNotificationClick() async {
    final player = AudioPlayer();
    await player.play(AssetSource('sounds/notification.mp3'));
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 150);
    }

    if (!mounted) return;
    setState(() {
      _playAnimation = true;
    });

    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      setState(() {
        _playAnimation = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final sidebarWidth =
        isCollapsed ? 80.0 : (screenWidth * 0.3).clamp(160.0, 240.0);

    return SafeArea(
      child: Stack(
        children: [
          Scaffold(
            body: Row(
              children: [
                // Sidebar
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: sidebarWidth,
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: [
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
                                isCollapsed
                                    ? Icons.keyboard_arrow_right
                                    : Icons.keyboard_arrow_left,
                                color: Colors.black54,
                              ),
                              onPressed: () {
                                if (!mounted) return;
                                setState(() => isCollapsed = !isCollapsed);
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Menu navigation
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: navItems.length,
                          itemBuilder: (context, index) {
                            final item = navItems[index];
                            final bool isSelected = selectedIndex == index;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                InkWell(
                                  onTap: () {
                                    if (!mounted) return;
                                    setState(() {
                                      if (item['subItems'] != null) {
                                        if (statMenuOpen && selectedIndex == index) {
                                          statMenuOpen = false;
                                          selectedIndex = -1;
                                          selectedStatTab = null;
                                        } else {
                                          selectedIndex = index;
                                          statMenuOpen = true;
                                          selectedStatTab = item['subItems'][0]['label'];
                                        }
                                      } else {
                                        selectedIndex = index;
                                        selectedStatTab = null;
                                        statMenuOpen = false;
                                      }
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.transparent,
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
                                                fontWeight: isSelected
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                                color: isSelected
                                                    ? const Color.fromARGB(243, 217, 15, 52)
                                                    : Colors.black87,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              softWrap: false,
                                            ),
                                          ),
                                        ],
                                        if (item['subItems'] != null && !isCollapsed)
                                          Icon(
                                            statMenuOpen
                                                ? Icons.keyboard_arrow_up
                                                : Icons.keyboard_arrow_down,
                                            size: 20,
                                            color: Colors.black54,
                                          ),
                                      ],
                                    ),
                                  ),
                                ),

                                if (item['subItems'] != null &&
                                    statMenuOpen &&
                                    selectedIndex == index)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 40, top: 4),
                                    child: Column(
                                      children: List.generate(
                                          item['subItems'].length, (subIndex) {
                                        final subItem = item['subItems'][subIndex];
                                        final bool isSubSelected =
                                            selectedStatTab == subItem['label'];
                                        return InkWell(
                                          onTap: () {
                                            if (!mounted) return;
                                            setState(() {
                                              selectedStatTab = subItem['label'];
                                            });
                                          },
                                          child: Container(
                                            margin: const EdgeInsets.symmetric(vertical: 2),
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8, horizontal: 12),
                                            decoration: BoxDecoration(
                                              color: Colors.transparent,
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  subItem['icon'],
                                                  size: 18,
                                                  color: isSubSelected
                                                      ? const Color.fromARGB(243, 217, 15, 52)
                                                      : Colors.black54,
                                                ),
                                                const SizedBox(width: 12),
                                                Text(
                                                  subItem['label'],
                                                  style: GoogleFonts.urbanist(
                                                    fontSize: 14,
                                                    fontWeight: isSubSelected
                                                        ? FontWeight.bold
                                                        : FontWeight.normal,
                                                    color: isSubSelected
                                                        ? const Color.fromARGB(243, 217, 15, 52)
                                                        : Colors.black87,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Contenu principal
                Expanded(
                  child: Column(
                    children: [
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
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: "Rechercher...",
                                  hintStyle: const TextStyle(color: Colors.grey),
                                  prefixIcon: const Icon(Icons.search),
                                  filled: true,
                                  fillColor: const Color(0xFFF0F2F5),
                                  contentPadding:
                                      const EdgeInsets.symmetric(vertical: 0),
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
                                onPressed: _handleNotificationClick,
                              ),
                            ),
                            PopupMenuButton<String>(
                              icon: const CircleAvatar(
                                radius: 18,
                                backgroundImage: AssetImage('assets/profile.jpg'),
                              ),
                              onSelected: (value) {
                                if (!mounted) return;
                                if (value == 'logout') {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text('Déconnexion'),
                                        content: const Text(
                                            'Êtes-vous sûr de vouloir vous déconnecter ?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(),
                                            child: const Text('Annuler'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pushReplacement(
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      const LoginScreen(),
                                                ),
                                              );
                                            },
                                            child: const Text('Déconnexion'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                    value: 'profile', child: Text('Profil')),
                                const PopupMenuItem(
                                    value: 'logout', child: Text('Déconnexion')),
                              ],
                            ),
                          ],
                        ),
                      ),
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

          // Chatbot flottant
          const ChatbotLauncher(),
        ],
      ),
    );
  }
}
