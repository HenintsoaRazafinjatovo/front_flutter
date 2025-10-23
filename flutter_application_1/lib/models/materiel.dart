import 'nature.dart';

class Materiel {
  int? idMateriel;
  String? designation;
  String? code;
  DateTime? dateAcquisition;
  int? idNature;
  Nature? nature;

  Materiel({
    this.idMateriel,
    this.designation,
    this.code,
    this.dateAcquisition,
    this.idNature,
    this.nature,
  });

  factory Materiel.fromJson(Map<String, dynamic> json) {
    return Materiel(
      idMateriel: json['id_materiel'],
      designation: json['designation'],
      code: json['code'],
      dateAcquisition: json['date_acquisition'] != null
          ? DateTime.parse(json['date_acquisition'])
          : null,
      idNature: json['id_nature'],
      nature: json['nature'] != null ? Nature.fromJson(json['nature']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_materiel': idMateriel,
      'designation': designation,
      'code': code,
      'date_acquisition':
          dateAcquisition != null ? dateAcquisition!.toIso8601String() : null,
      'id_nature': idNature,
    };
  }
}