class Nature {
  int? idNature;
  String? code;
  String? description;

  Nature({this.idNature, this.code, this.description});

  factory Nature.fromJson(Map<String, dynamic> json) {
    return Nature(
      idNature: json['id_nature'],
      code: json['code'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_nature': idNature,
      'code': code,
      'description': description,
    };
  }
}