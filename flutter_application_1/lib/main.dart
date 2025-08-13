
import 'package:flutter/material.dart';
import 'layout/main_layout.dart';
import 'package:google_fonts/google_fonts.dart'; // <-- Assure-toi que ce chemin est correct

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        fontFamily: 'Poppins',
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      // home: const LoginScreen(),
      home: const MainLayout(), // <-- Affiche la page de connexion en premier
       // <-- Affiche la page de connexion en premier
    );
  }
}
