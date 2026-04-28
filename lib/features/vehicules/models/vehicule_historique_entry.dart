import 'package:flutter/material.dart';

class VehiculeHistoriqueEntry {
  const VehiculeHistoriqueEntry({
    required this.title,
    required this.description,
    required this.timestamp,
    required this.icon,
  });

  final String title;
  final String description;
  final DateTime timestamp;
  final IconData icon;
}
