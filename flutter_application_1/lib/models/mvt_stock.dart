import 'direction.dart' show Direction;

class MvtStock {
  final int? idmvt;
  final String article;
  final double quantite;
  final Direction? direction;
  final String type;
  final DateTime date_mvt;

  MvtStock({
    this.idmvt,
    required this.article,
    required this.quantite,
    this.direction,
    required this.type,
    required this.date_mvt,
  });

  factory MvtStock.fromJson(Map<String, dynamic> json) {
    print(json);
    return MvtStock(
      idmvt: json['idmvt'] as int?,
      article: json['article'] as String,
      quantite: double.tryParse(json['quantite'].toString()) ?? 0.0,
      direction: json['direction'] != null
          ? Direction.fromJson(json['direction'] as Map<String, dynamic>)
          : null,
      type: json['type'] as String,
      date_mvt: DateTime.parse(json['date_mvt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idmvt': idmvt,
      'article': article,
      'quantite': quantite.toStringAsFixed(2),
      'direction': direction?.toJson(),
      'type': type,
      'date_mvt': date_mvt.toIso8601String(),
    };
  }
}
