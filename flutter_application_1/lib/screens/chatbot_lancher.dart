import 'package:flutter/material.dart';
import 'chatbot_widget.dart'; // ton fichier avec ChatbotDialog

class ChatbotLauncher extends StatefulWidget {
  const ChatbotLauncher({super.key});

  @override
  State<ChatbotLauncher> createState() => _ChatbotLauncherState();
}

class _ChatbotLauncherState extends State<ChatbotLauncher> {
  bool _isOpen = false;

  void _toggleChatbot() {
    setState(() => _isOpen = !_isOpen);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Le bouton flottant
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            onPressed: _toggleChatbot,
            backgroundColor: const Color(0xFFF9B70D),
            child: const Icon(Icons.smart_toy), // icône robot
          ),
        ),

        // Le Chatbot Dialog
        if (_isOpen)
          ChatbotDialog(
            onClose: _toggleChatbot,
          ),
      ],
    );
  }
}
