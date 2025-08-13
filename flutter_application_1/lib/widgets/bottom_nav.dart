import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
// import '../screens/home_screen.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    // HomeScreen(),
    Placeholder(), // Calendrier
    Placeholder(), // Messages
    Placeholder(), // Paramètres
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(FluentIcons.home_24_regular),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(FluentIcons.calendar_ltr_24_regular),
            label: 'Calendrier',
          ),
          BottomNavigationBarItem(
            icon: Icon(FluentIcons.chat_24_regular),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(FluentIcons.settings_24_regular),
            label: 'Paramètres',
          ),
        ],
      ),
    );
  }
}
