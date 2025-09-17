import 'package:flutter/material.dart';
import 'charts_tab.dart';
import 'prediction_tab.dart';
import 'dashboard_tab.dart';
import 'chatbot_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  bool _showChatbot = false;

  // Méthodes et variables pour chatbot placées dans chatbot_widget.dart (passage via setters si besoin)

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this,initialIndex: 1);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color(0xFFF8F9FA),
        child: SafeArea(
          child: Stack(
            children: [
              TabBarView(
                controller: _tabController,
                children: const [
                  DashboardTab(),
                  ChartsTab(),
                  PredictionTab(),
                ],
              ),
              if (_showChatbot)
                ChatbotDialog(
                  onClose: () {
                    setState(() {
                      _showChatbot = false;
                    });
                  },
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() => _showChatbot = !_showChatbot),
        backgroundColor: const Color(0xFFF9B70D),
        child: const Text('🤖', style: TextStyle(fontSize: 24)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
