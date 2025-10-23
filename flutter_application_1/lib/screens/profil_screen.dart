import 'package:flutter/material.dart';
import '../services/userService.dart';
import '../models/user.dart';

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  User? currentUser;

  @override
  void initState() {
    super.initState();
    _fetchCurrentUser();
  }

  Future<void> _fetchCurrentUser() async {
    final authService = AuthService();
    final user = await authService.getCurrentUser();
    print("Current User in ProfilScreen: ${user?.toJson()}");
    setState(() {
      currentUser = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profil',
          style: TextStyle(fontFamily: 'Poppins'),
        ),
      ),
      body: currentUser == null
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Card(
                elevation: 4,
                margin: const EdgeInsets.all(20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircleAvatar(
                        radius: 40,
                        backgroundImage: AssetImage('assets/profile.png'),
                        // tu peux mettre une image locale ici (dans /assets)
                      ),
                      const SizedBox(height: 16),
                      Text(
                        currentUser!.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Profil : ${currentUser!.profil.nom}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const Divider(height: 30, thickness: 1),
                      _infoRow('User VCodePer', currentUser!.user_vpercode),
                      const SizedBox(height: 8),
                      _infoRow(
                          'Agence', currentUser!.agence?.libelle ?? 'Aucune'),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontFamily: 'Poppins',
            )),
        Text(value,
            style: const TextStyle(
              color: Colors.black87,
              fontFamily: 'Poppins',
            )),
      ],
    );
  }
}
