import 'package:flutter/material.dart';
import 'dart:async';
import '../models/categorie.dart';  // Import nécessaire pour Article
// Définition de la classe Article conforme à votre modèle
class Article {
  final int? idArticle;
  final String intitule;
  double seuilMin;
  final String code;
  double? prix;
  double? stockActuel;
  final Categorie? categorie;

  Article({
    this.idArticle,
    required this.intitule,
    required this.seuilMin,
    required this.code,
    this.prix,
    this.stockActuel,
    this.categorie,
  });
}

class Order {
  final int id;
  final String number;
  final String date;
  final String agency;
  final double total;
  final String status;

  Order({
    required this.id,
    required this.number,
    required this.date,
    required this.agency,
    required this.total,
    required this.status,
  });
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  ChatMessage({required this.text, required this.isUser, required this.timestamp});
}

class ChatbotDialog extends StatefulWidget {
  final VoidCallback onClose;

  const ChatbotDialog({super.key, required this.onClose});

  @override
  State<ChatbotDialog> createState() => _ChatbotDialogState();
}

class _ChatbotDialogState extends State<ChatbotDialog> {
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();
  final List<ChatMessage> _chatMessages = [];
  bool _isTyping = false;

  final List<Article> articles = [
    Article(idArticle: 1, intitule: 'PV de stockage', seuilMin: 5, code: 'ART-001', prix: 1200.0, stockActuel: 15),
    Article(idArticle: 2, intitule: 'Fiche de prêt', seuilMin: 3, code: 'ART-002', prix: 25.0, stockActuel: 25),
    Article(idArticle: 3, intitule: 'Carnet de prêt', seuilMin: 4, code: 'ART-003', prix: 300.0, stockActuel: 8),
    Article(idArticle: 4, intitule: 'Acte de cautionnement', seuilMin: 2, code: 'ART-004', prix: 80.0, stockActuel: 12),
    Article(idArticle: 5, intitule: 'Contrat depot a terme', seuilMin: 5, code: 'ART-005', prix: 450.0, stockActuel: 5),
    Article(idArticle: 6, intitule: 'Fanambarana fanonerana', seuilMin: 10, code: 'ART-006', prix: 60.0, stockActuel: 20),
    Article(idArticle: 7, intitule: 'Registre de transmission', seuilMin: 1, code: 'ART-007', prix: 90.0, stockActuel: 3),
    Article(idArticle: 8, intitule: 'Registre de passation', seuilMin: 2, code: 'ART-008', prix: 120.0, stockActuel: 18),
  ];

  final List<Order> orders = [
    Order(id: 1, number: 'CMD-0001', date: '15/12/2024', agency: 'Agence Aina', total: 2525, status: 'Validée'),
    Order(id: 2, number: 'CMD-0002', date: '14/12/2024', agency: 'Agence Fanavotana', total: 1140, status: 'Livrée'),
    Order(id: 3, number: 'CMD-0003', date: '13/12/2024', agency: 'Agence Vonjy', total: 890, status: 'En cours'),
    Order(id: 4, number: 'CMD-0004', date: '12/12/2024', agency: 'Agence Farimbotsoa', total: 1650, status: 'Validée'),
    Order(id: 5, number: 'CMD-0005', date: '11/12/2024', agency: 'Agence Aina', total: 2100, status: 'Livrée'),
  ];

  @override
  void initState() {
    super.initState();
    _chatMessages.add(ChatMessage(
      text:
          '👋 Bonjour ! Je peux vous aider à :\n• Vérifier le stock d\'un article\n• Consulter l\'état d\'une commande\n• Obtenir des informations sur les livraisons\n\nQue souhaitez-vous savoir ?',
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  @override
  void dispose() {
    _chatController.dispose();
    _chatScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 90,
      right: 16,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 350,
          height: 500,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFF9B70D),
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    const Text('🤖', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    const Text('Assistant Logistique', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    GestureDetector(
                      onTap: widget.onClose,
                      child: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: _chatScrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _chatMessages.length + (_isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _chatMessages.length && _isTyping) {
                      return _buildTypingIndicator();
                    }
                    final message = _chatMessages[index];
                    return _buildChatMessage(message);
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.grey[300]!))),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _chatController,
                        decoration: InputDecoration(
                          hintText: 'Tapez votre question...',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _sendMessage,
                      icon: const Icon(Icons.send),
                      color: Colors.white,
                      splashRadius: 24,
                      style: IconButton.styleFrom(backgroundColor: const Color(0xFFF9B70D)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatMessage(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: message.isUser ? const Color(0xFFF9B70D) : Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          message.text,
          style: TextStyle(color: message.isUser ? Colors.white : Colors.black87, fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(16)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🤖', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            ...List.generate(3, (index) => Container(margin: EdgeInsets.only(right: index < 2 ? 4 : 0), child: const TypingDot())),
          ],
        ),
      ),
    );
  }

  void _sendMessage() {
    final text = _chatController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _chatMessages.add(ChatMessage(text: text, isUser: true, timestamp: DateTime.now()));
      _isTyping = true;
    });
    _chatController.clear();
    _scrollToBottom();

    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isTyping = false;
        _chatMessages.add(ChatMessage(text: _generateBotResponse(text), isUser: false, timestamp: DateTime.now()));
      });
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_chatScrollController.hasClients) {
        _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _generateBotResponse(String userMessage) {
    final message = userMessage.toLowerCase();

    if (message.contains('stock') || message.contains('quantité')) {
      final articleKeywords = {
        'pv de stockage': 'ART-001',
        'fiche': 'ART-002',
        'carnet': 'ART-003',
        'acte': 'ART-004',
        'contrat': 'ART-005',
        'fanambarana': 'ART-006',
        'registre': 'ART-007',
      };
      for (final entry in articleKeywords.entries) {
        if (message.contains(entry.key)) {
          final article = articles.firstWhere(
            (a) => a.code == entry.value,
            orElse: () => articles.first,
          );

          final stock = article.stockActuel ?? 0;
          final seuil = article.seuilMin;
          final prix = article.prix ?? 0;

          final stockStatus = stock < seuil
              ? '⚠️ Stock faible'
              : stock < seuil * 2
                  ? '⚡ Stock modéré'
                  : '✅ Stock suffisant';

          return '${article.intitule}\nStock actuel: ${stock.toStringAsFixed(0)} unités\nSeuil minimum: ${seuil.toStringAsFixed(0)}\nStatut: $stockStatus\nPrix unitaire: ${prix.toStringAsFixed(2)} €';
        }
      }
      return 'Voici le stock actuel de nos principaux articles:\n\n${articles.take(4).map((a) => '• ${a.intitule}: ${a.stockActuel?.toStringAsFixed(0) ?? "0"} unités').join('\n')}\n\nPrécisez un article pour plus de détails !';
    }

    if (message.contains('commande') || message.contains('cmd')) {
      final cmdPattern = RegExp(r'cmd-\d+', caseSensitive: false);
      final match = cmdPattern.firstMatch(message);

      if (match != null) {
        final orderNumber = match.group(0)!.toUpperCase();
        final order = orders.firstWhere((o) => o.number == orderNumber, orElse: () => Order(id: 0, number: '', date: '', agency: '', total: 0, status: ''));

        if (order.id != 0) {
          final statusEmoji = {
            'Validée': '✅',
            'En cours': '⏳',
            'Livrée': '🚚',
            'Annulée': '❌'
          };
          return 'Commande ${order.number}\nDate: ${order.date}\nAgence: ${order.agency}\nMontant: ${order.total} €\nStatut: ${statusEmoji[order.status]} ${order.status}';
        } else {
          return '❌ Commande $orderNumber non trouvée. Vérifiez le numéro.';
        }
      }
      return 'Voici les dernières commandes:\n\n${orders.take(3).map((o) => '• ${o.number} - ${o.agency} (${o.status})').join('\n')}\n\nPrécisez un numéro (ex: CMD-0001) pour plus de détails !';
    }

    if (message.contains('aide') || message.contains('help')) {
      return '🤖 Je peux vous aider avec:\n\n📦 Stock: "Quel est le stock des PV ?"\n📋 Commandes: "État de la commande CMD-0001"\n🚚 Livraisons: "Statut des livraisons"\n📊 Statistiques: "Résumé du jour"\n\nPosez-moi votre question !';
    }

    if (message.contains('livraison') || message.contains('transport')) {
      final deliveredOrders = orders.where((o) => o.status == 'Livrée').length;
      final pendingOrders = orders.where((o) => o.status == 'En cours').length;
      return 'État des livraisons:\n\n✅ Livrées: $deliveredOrders\n⏳ En cours: $pendingOrders\n📦 Total commandes: ${orders.length}\n\nTaux de livraison: ${((deliveredOrders / orders.length) * 100).round()}%';
    }

    if (message.contains('résumé') || message.contains('statistique') || message.contains('bilan')) {
      final totalRevenue = orders.fold<double>(0, (sum, order) => sum + order.total);
      final lowStock = articles.where((a) => (a.stockActuel ?? 0) < 10).length;
      return 'Résumé du jour:\n\n📦 Commandes: ${orders.length}\n💰 CA: ${totalRevenue.toStringAsFixed(0)} €\n⚠️ Articles en stock faible: $lowStock\n🏢 Agences actives: 4\n\nTout semble bien fonctionner ! 👍';
    }

    return '🤔 Je n\'ai pas bien compris votre demande. Essayez:\n\n• "Stock des PV"\n• "État commande CMD-0001"\n• "Résumé du jour"\n• "Aide" pour plus d\'options';
  }
}

class TypingDot extends StatefulWidget {
  const TypingDot({super.key});
  @override
  State<TypingDot> createState() => _TypingDotState();
}

class _TypingDotState extends State<TypingDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 600), vsync: this);
    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) => Opacity(
        opacity: _animation.value,
        child: Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(color: Colors.grey, shape: BoxShape.circle),
        ),
      ),
    );
  }
}
