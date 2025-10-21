import 'dart:convert';
import 'package:flareline_template/screens/statistiqueCommande_screen.dart';
import 'package:flareline_template/screens/statistiqueMouvement_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import 'package:animate_do/animate_do.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

// Tes imports d'écrans
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
import '../screens/statistiqueArticle_screen.dart';

import '../screens/dashboard_tab.dart';
import '../screens/charts_tab.dart';
import '../screens/prediction_tab.dart';
import '../screens/authGard_screen.dart';
import '../services/userService.dart';
import '../models/user.dart';

import '../screens/chatbot_lancher.dart'; // Widget ChatbotLauncher

enum ModuleType { stock, immobilisation, agence }

class MainLayout extends StatefulWidget {
  final ModuleType selectedModule;

  const MainLayout({super.key, required this.selectedModule});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int selectedIndex = 0;
  String? selectedStatTab;
  bool isCollapsed = false;
  bool _playAnimation = false;
  bool statMenuOpen = false;
  bool showNotificationPanel = false;

  late WebSocketChannel _channel;
  List<String> notifications = [];

@override
void initState() {
  super.initState();
  _initializeWebSocket();
}

Future<void> _initializeWebSocket() async {
  try {
    // Récupération de l'utilisateur connecté depuis la session
    User? currentUser = await AuthService().getCurrentUser();
    // print(currentUser?.toJson());  
    // ou ton propre moyen de récupérer l'utilisateur
    final userVCode = currentUser?.user_vpercode ?? 'defaultCode';

    // Connexion WebSocket au service Go avec user_vpercode
    _channel = WebSocketChannel.connect(
      Uri.parse('ws://localhost:8080/ws?user=$userVCode'),
    );

    _channel.stream.listen((message) {
      final data = jsonDecode(message);
      final description = data['description'] ?? 'Nouvelle notification';

      if (mounted) {
        setState(() {
          notifications.add(description);
          print('Notifications: $notifications');
          _handleNotificationClick();
        });
      }
    });
  } catch (e) {
    print('Erreur lors de la récupération des notifications: $e');
  }
}

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
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

  List<Map<String, dynamic>> get navItems {
    if (widget.selectedModule == ModuleType.stock) {
      return [
        // {'icon': Icons.shopping_cart_outlined, 'label': 'Commandes'},
        {'icon': Icons.receipt_long, 'label': 'Admin commande'},
        {'icon': Icons.production_quantity_limits, 'label': 'Articles'},
        {'icon': Icons.inventory_rounded, 'label': 'Inventaire'},
        {'icon': Icons.swap_vert, 'label': 'Mouvement'},
        {'icon': Icons.article, 'label': 'Factures'},
        {'icon': Icons.outbox, 'label': 'Bon de livraison'},
        {
          'icon': Icons.bar_chart,
          'label': 'Statistiques',
          'subItems': [
            {'icon': Icons.dashboard, 'label': 'Stock article', 'widget': const StatistiqueArticle()},
            {'icon': Icons.show_chart, 'label': 'Commandes agence', 'widget': const StatistiqueCommande()},
            {'icon': Icons.dashboard, 'label': 'Mouvements', 'widget': const StatistiqueMouvement()},
            {'icon': Icons.analytics, 'label': 'Prédiction', 'widget': const PredictionTab()},
          ]
        },
        {'icon': Icons.calendar_month, 'label': 'Calendrier'},
        
      ];
    } else if(widget.selectedModule == ModuleType.immobilisation) {
      return [
        {'icon': Icons.task_outlined, 'label': 'Matériels'},
        {'icon': Icons.swap_vert, 'label': 'Mouvement stock immo'},
        {'icon': Icons.inventory_2_sharp, 'label': 'Inventaire immo'},
        {'icon': Icons.fact_check_outlined, 'label': 'Decharge'},
        {'icon': Icons.bar_chart, 'label': 'Statistique immo'},
      ];
    }
    else{
      return [
        {'icon': Icons.shopping_cart_outlined, 'label': 'Commandes'},

      ];

    }
  }

  Widget _buildScreen() {
    if (widget.selectedModule == ModuleType.stock) {
      if (selectedIndex == 6 && selectedStatTab != null) {
        final subItem = navItems[6]['subItems']
            .firstWhere((item) => item['label'] == selectedStatTab);
        return subItem['widget'];
      }

      switch (selectedIndex) {
        case 0:
           return const AuthGuard(
        child: AdminCommandeScreen(),
      );
        case 1:
          return ArticleScreen();
        case 2:
          return InventoryManagementScreen();
         case 3:
          return const AuthGuard(
        child: MouvementStockScreen(),
          );
          case 4:
          return FactureScreen();
        case 5:
          return const AuthGuard(
        child: BonDeLivraisonScreen(),
        );
        case 6:
          return Center(child: Text('Sélectionnez un sous-menu Statistiques'));
        case 7:
          return const AuthGuard(
        child: CalendrierLogistiqueScreen(),
        ); 
        default:
          return const AuthGuard(
            child: AdminCommandeScreen(),
          );
      }
    } else if (widget.selectedModule == ModuleType.immobilisation) {
      switch (selectedIndex) {
        case 0:
          return MaterielScreen();
        case 1:
          return MouvementStockImmoScreen();
        case 2:
          return InventoryImmoManagementScreen();
        case 3:
          return DechargeScreen();
        case 4:
          return StatistiqueImmoScreen();
        default:
          return MaterielScreen();
      }
    }
    else {
      switch (selectedIndex) {
        case 0:
          return const BonDeCommandeScreen();
        default:
          return const BonDeCommandeScreen();
      }
    }
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
                      // Logo + bouton collapse
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
                        if (widget.selectedModule == ModuleType.stock || widget.selectedModule == ModuleType.immobilisation) 
                        ElevatedButton.icon(
                          onPressed: () {
                          if (widget.selectedModule == ModuleType.stock) {
                            Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => const MainLayout(
                              selectedModule: ModuleType.immobilisation,
                              ),
                            ),
                            );
                          } else if (widget.selectedModule == ModuleType.immobilisation) {
                            Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => const MainLayout(
                              selectedModule: ModuleType.stock,
                              ),
                            ),
                            );
                          }
                          },
                          icon: Icon(
                          widget.selectedModule == ModuleType.stock
                            ? Icons.business
                            : Icons.store,
                          ),
                          label: Text(
                          widget.selectedModule == ModuleType.stock
                            ? 'Immobilisation'
                            : 'Stock',
                          ),
                          style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(243, 217, 15, 52),
                          foregroundColor: Colors.white,
                          ),
                        ),
                    ],
                  ),
                ),

                // Contenu principal
                Expanded(
                  child: Column(
                    children: [
                      // Top bar
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
                            
                            const Spacer(),
                            ShakeX(
                              animate: _playAnimation,
                              duration: const Duration(milliseconds: 600),
                              child: Stack(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.notifications_none),
                                    onPressed: () {
                                      if (!mounted) return;
                                      setState(() {
                                        showNotificationPanel = !showNotificationPanel;
                                      });
                                    },
                                  ),
                                  if (notifications.isNotEmpty)
                                    Positioned(
                                      right: 8,
                                      top: 8,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        constraints: const BoxConstraints(
                                          minWidth: 18,
                                          minHeight: 18,
                                        ),
                                        child: Text(
                                          '${notifications.length}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            PopupMenuButton<String>(
                              icon: CircleAvatar(
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

          // Panneau de notifications
          if (showNotificationPanel)
            Positioned(
              top: 70,
              right: 24,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 320,
                  constraints: const BoxConstraints(maxHeight: 400),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // En-tête
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.grey.shade200),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Notifications',
                              style: GoogleFonts.urbanist(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              children: [
                                if (notifications.isNotEmpty)
                                  TextButton(
                                    onPressed: () {
                                      if (!mounted) return;
                                      setState(() {
                                        notifications.clear();
                                      });
                                    },
                                    child: Text(
                                      'Tout effacer',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ),
                                IconButton(
                                  icon: const Icon(Icons.close, size: 20),
                                  onPressed: () {
                                    if (!mounted) return;
                                    setState(() {
                                      showNotificationPanel = false;
                                    });
                                  },
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Liste des notifications
                      notifications.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.notifications_none,
                                    size: 48,
                                    color: Colors.grey.shade300,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Aucune notification',
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Flexible(
                              child: ListView.separated(
                                shrinkWrap: true,
                                padding: const EdgeInsets.all(8),
                                itemCount: notifications.length,
                                separatorBuilder: (context, index) => Divider(
                                  height: 1,
                                  color: Colors.grey.shade100,
                                ),
                                itemBuilder: (context, index) {
                                  final notif = notifications[notifications.length - 1 - index];
                                  return Dismissible(
                                    key: Key('$notif-$index'),
                                    direction: DismissDirection.endToStart,
                                    onDismissed: (_) {
                                      if (!mounted) return;
                                      setState(() {
                                        notifications.removeAt(notifications.length - 1 - index);
                                      });
                                    },
                                    background: Container(
                                      alignment: Alignment.centerRight,
                                      padding: const EdgeInsets.only(right: 16),
                                      color: Colors.red.shade400,
                                      child: const Icon(
                                        Icons.delete,
                                        color: Colors.white,
                                      ),
                                    ),
                                    child: ListTile(
                                      dense: true,
                                      leading: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.red.shade50,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.warning_amber_rounded,
                                          size: 20,
                                          color: Colors.red.shade400,
                                        ),
                                      ),
                                      title: Text(
                                        notif,
                                        style: GoogleFonts.urbanist(
                                          fontSize: 13,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      trailing: IconButton(
                                        icon: Icon(
                                          Icons.close,
                                          size: 16,
                                          color: Colors.grey.shade400,
                                        ),
                                        onPressed: () {
                                          if (!mounted) return;
                                          setState(() {
                                            notifications.removeAt(notifications.length - 1 - index);
                                          });
                                        },
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ),

          if (widget.selectedModule == ModuleType.stock || widget.selectedModule == ModuleType.immobilisation)
            const ChatbotLauncher(),
        ],
      ),
    );
  }
}