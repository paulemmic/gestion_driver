import 'package:flutter/material.dart';

class VehiculeHistoriqueDraft {
  const VehiculeHistoriqueDraft({
    required this.type,
    required this.title,
    required this.description,
  });

  final HistoryEntryType type;
  final String title;
  final String description;
}

enum HistoryEntryType { maintenance, controle, incident, administratif }

extension HistoryEntryTypeStyle on HistoryEntryType {
  String get label => switch (this) {
    HistoryEntryType.maintenance => 'Maintenance',
    HistoryEntryType.controle => 'Contrôle',
    HistoryEntryType.incident => 'Incident',
    HistoryEntryType.administratif => 'Administratif',
  };

  IconData get icon => switch (this) {
    HistoryEntryType.maintenance => Icons.build_circle_outlined,
    HistoryEntryType.controle => Icons.fact_check_outlined,
    HistoryEntryType.incident => Icons.report_problem_outlined,
    HistoryEntryType.administratif => Icons.assignment_outlined,
  };
}
