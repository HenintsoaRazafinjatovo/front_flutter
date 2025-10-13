
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

class Unite {
  final String uteVcode;
  final String uteVnom;
  final String libelle;

  Unite({
    required this.uteVcode,
    required this.uteVnom,
    required this.libelle,
  });

  factory Unite.fromJson(Map<String, dynamic> json) {
    return Unite(
      uteVcode: json['ute_vcode'],
      uteVnom: json['ute_vnom'],
      libelle: json['libelle'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ute_vcode': uteVcode,
      'ute_vnom': uteVnom,
      'libelle': libelle,
    };
  }
}

class User {
  final String name;
  final String? email;
  final String password;
  final Profil profil;
  final List<Unite> unites;

  User({
    required this.name,
    this.email,
    required this.password,
    required this.profil,
    required this.unites,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'] ?? '',
      email: json['email'],
      password: json['password'] ?? '',
      profil: Profil.fromJson(json['profil']),
      unites: (json['unites'] as List<dynamic>)
          .map((u) => Unite.fromJson(u))
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
    };
  }
}
