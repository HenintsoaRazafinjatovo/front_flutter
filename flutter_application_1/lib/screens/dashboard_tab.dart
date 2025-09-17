// import 'package:flutter/material.dart';
// import 'dart:math' as math;
// // import 'models.dart';

// class DashboardTab extends StatelessWidget {
//   const DashboardTab({super.key});

//   // Vous pouvez initialiser vos données ici ou les passer via constructeur

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         children: [
//           _buildKPICards(),
//           const SizedBox(height: 24),
//           _buildDetailedDashboard(),
//         ],
//       ),
//     );
//   }

//   Widget _buildKPICards() {
//     // Exemple statique : remplacer par données dynamiques selon besoin
//     final totalOrders = 5; // Remplacer par variable réelle
//     final totalRevenue = 12_455; 
//     final totalArticles = 100;
//     const totalAgencies = 4;

//     return GridView.count(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       crossAxisCount: 2,
//       childAspectRatio: 1.5,
//       crossAxisSpacing: 16,
//       mainAxisSpacing: 16,
//       children: [
//         _buildKPICard('📦', totalOrders.toString(), 'Commandes totales', const Color.fromARGB(205, 235, 203, 122)),
//         _buildKPICard('💰', '$totalRevenue €', 'Chiffre d\'affaires', const Color.fromARGB(234, 245, 126, 99)),
//         _buildKPICard('📋', totalArticles.toString(), 'Articles en stock', const Color.fromARGB(198, 129, 150, 245)),
//         _buildKPICard('🏢', totalAgencies.toString(), 'Agences actives', const Color.fromARGB(181, 138, 224, 214)),
//       ],
//     );
//   }

//   Widget _buildKPICard(String icon, String value, String label, Color color) {
//     return Container(
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [color, color.withOpacity(0.8)],
//         ),
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
//       ),
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Text(icon, style: const TextStyle(fontSize: 32)),
//           const SizedBox(height: 8),
//           Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
//           const SizedBox(height: 4),
//           Text(label, style: const TextStyle(fontSize: 12, color: Colors.white70), textAlign: TextAlign.center),
//         ],
//       ),
//     );
//   }

//   Widget _buildDetailedDashboard() {
//     // Exemple statique : remplacer par données dynamiques
//     final pendingOrders = 1;
//     final successfulDeliveries = 2;
//     final lowStockItems = 3;
//     final delayedOrders = math.Random().nextInt(3);

//     return GridView.count(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       crossAxisCount: 2,
//       childAspectRatio: 2,
//       crossAxisSpacing: 16,
//       mainAxisSpacing: 16,
//       children: [
//         _buildDetailCard('Commandes en cours', pendingOrders.toString(), 'En traitement', Colors.blue),
//         _buildDetailCard('Livraisons réussies', successfulDeliveries.toString(), 'Ce mois', Colors.green),
//         _buildDetailCard('Stock faible', lowStockItems.toString(), 'Articles < 10', Colors.orange),
//         _buildDetailCard('Retards', delayedOrders.toString(), 'Commandes en retard', Colors.red),
//       ],
//     );
//   }

//   Widget _buildDetailCard(String title, String value, String subtitle, Color color) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: color.withOpacity(0.2)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color)),
//           const SizedBox(height: 8),
//           Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
//           const SizedBox(height: 4),
//           Text(subtitle, style: TextStyle(fontSize: 12, color: color)),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'dart:math' as math;

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          _buildKPICards(),
          const SizedBox(height: 16),
          _buildDetailedDashboard(),
        ],
      ),
    );
  }

  // ------------------- KPI Cards -------------------
  Widget _buildKPICards() {
    final totalOrders = 5;
    final totalRevenue = 12_455; 
    final totalArticles = 100;
    const totalAgencies = 4;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,       // 4 cartes par ligne
      childAspectRatio: 2.5,   // rectangles horizontaux
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _buildKPICard('📦', totalOrders.toString(), 'Commandes', const Color.fromARGB(205, 235, 203, 122)),
        _buildKPICard('💰', '$totalRevenue €', 'CA', const Color.fromARGB(234, 245, 126, 99)),
        _buildKPICard('📋', totalArticles.toString(), 'Articles', const Color.fromARGB(198, 129, 150, 245)),
        _buildKPICard('🏢', totalAgencies.toString(), 'Agences', const Color.fromARGB(181, 138, 224, 214)),
      ],
    );
  }

  Widget _buildKPICard(String icon, String value, String label, Color color) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, color.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: color.withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
              Text(label, style: const TextStyle(fontSize: 9, color: Colors.white70)),
            ],
          ),
        ],
      ),
    );
  }

  // ------------------- Detailed Dashboard -------------------
  Widget _buildDetailedDashboard() {
    final pendingOrders = 1;
    final successfulDeliveries = 2;
    final lowStockItems = 3;
    final delayedOrders = math.Random().nextInt(3);

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,       // 4 cartes par ligne
      childAspectRatio: 2.5,   // rectangles horizontaux
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _buildDetailCard('Commandes en cours', pendingOrders.toString(), 'En traitement', Colors.blue),
        _buildDetailCard('Livraisons réussies', successfulDeliveries.toString(), 'Ce mois', Colors.green),
        _buildDetailCard('Stock faible', lowStockItems.toString(), 'Articles < 10', Colors.orange),
        _buildDetailCard('Retards', delayedOrders.toString(), 'Commandes en retard', Colors.red),
      ],
    );
  }

  Widget _buildDetailCard(String title, String value, String subtitle, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
              const SizedBox(height: 2),
              Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
              Text(subtitle, style: TextStyle(fontSize: 9, color: color)),
            ],
          ),
        ],
      ),
    );
  }
}

