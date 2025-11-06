import 'package:intl/intl.dart';

// Exemple de fonction pour formater
String formatPrix(double prix) {
  final formatter = NumberFormat("#,##0", "fr_FR");
  return formatter.format(prix).replaceAll(',', ' ');
}
