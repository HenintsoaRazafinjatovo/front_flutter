
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
  final Agence? agence;
  final String user_vpercode;

  User({
    required this.name,
    this.email,
    required this.password,
    required this.profil,
    required this.agence,
    required this.user_vpercode,
  });

  // factory User.fromJson(Map<String, dynamic> json) {
  //   return User(
  //     name: json['name'] ?? '',
  //     email: json['email'],
  //     password: json['password'] ?? '',
  //     user_vpercode: json['user_vcodeper'] ?? '',
  //     profil: Profil.fromJson(json['profil']),
  //      agence: Agence.fromJson(json['agence']),
  //   );
  // }
  factory User.fromJson(Map<String, dynamic> json) {
  return User(
    name: json['name'] ?? '',
    email: json['email'],
    password: json['password'] ?? '',
    user_vpercode: json['user_vcodeper'] ?? '',
    profil: json['profil'] != null
        ? Profil.fromJson(json['profil'])
        : Profil(id: 0, nom: ''), // valeur par défaut
    agence: json['agence'] != null
        ? Agence.fromJson(json['agence'])
        : null,
  );
}


  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'user_vcodeper': user_vpercode,
      'email': email,
      'password': password,
      'profil': profil.toJson(),
      'agence': agence?.toJson(),
    };
  }
}
