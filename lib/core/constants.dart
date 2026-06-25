import 'package:flutter/material.dart';

const couleurs = [
  // Colors.grey,
  Colors.blue,
  Color(0xFFFB8C00),
  Colors.teal,
  Colors.purple,
  Color(0xFFEC407A),
  Colors.lightBlue,
  Color(0xFFF3774D),
];

const colorSaumon = Color(0xFFF3774D);
const colorTurquoise = Colors.teal;

const List<String> categories = ['A', 'B', 'Toutes catégories(BCDE)'];

String formatDate(DateTime? date) {
  if (date == null) return '—';
  return '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/${date.year}';
}
