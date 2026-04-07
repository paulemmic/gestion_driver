import 'package:flutter/material.dart';
import 'package:gestion_driver/shared/models/status_tone.dart';

class DashboardDocumentAlert {
  const DashboardDocumentAlert({
    required this.title,
    required this.icon,
    required this.daysRemaining,
  });

  final String title;
  final IconData icon;
  final int daysRemaining;

  StatusTone get tone {
    if (daysRemaining <= 1) {
      return StatusTone.danger;
    }
    if (daysRemaining <= 7) {
      return StatusTone.warning;
    }
    return StatusTone.notice;
  }

  String get urgencyLabel {
    if (daysRemaining <= 1) {
      return 'Urgent - 1 jour restant';
    }
    if (daysRemaining <= 7) {
      return 'Urgent - moins d\'une semaine';
    }
    return 'Urgent - $daysRemaining jours restants';
  }
}
