
import 'agence.dart';
class Profil {
  final int id;
  final String nom;

  Profil({
    required this.id,
    required this.nom,
  });

  factory Profil.fromJson(Map<String, dynamic> json) {
    return Profil(
      id: json['id'],
      nom: json['nom'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
    };
  }
}

class User {
  final String name;
  final String? email;
  final String password;
  final Profil profil;
  final List<Agence> unites;
  final String user_vpercode;

  User({
    required this.name,
    this.email,
    required this.password,
    required this.profil,
    required this.unites,
    required this.user_vpercode,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'] ?? '',
      email: json['email'],
      password: json['password'] ?? '',
      user_vpercode: json['user_vpercode'] ?? '',
      profil: Profil.fromJson(json['profil']),
      unites: (json['unites'] as List<dynamic>)
          .map((u) => Agence.fromJson(u))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'profil': profil.toJson(),
      'unites': unites.map((u) => u.toJson()).toList(),
      'user_vpercode': user_vpercode,
    };
  }
}
