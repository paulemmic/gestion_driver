// features/dashboard/models/dashboard_document_alert.dart
import 'package:flutter/material.dart';
import 'package:gestion_driver/features/dashboard/data/services/dashboard_service.dart';
import 'package:gestion_driver/shared/models/status_tone.dart';

class DashboardDocumentAlert {
  const DashboardDocumentAlert({
    required this.title,
    required this.icon,
    required this.daysRemaining,
    this.isExpired = false,
    this.entityId,
    this.entityType,
  });

  final String title;
  final IconData icon;
  final int daysRemaining;
  final bool isExpired;
  final String? entityId;
  final EntityType? entityType;

  StatusTone get tone {
    if (isExpired || daysRemaining <= 1) return StatusTone.danger;
    if (daysRemaining <= 7) return StatusTone.warning;
    return StatusTone.notice;
  }

  String get urgencyLabel {
    if (isExpired) return 'EXPIRÉ';
    if (daysRemaining == 0) return 'Expire aujourd\'hui';
    if (daysRemaining == 1) return '1 jour restant';
    if (daysRemaining <= 7) return '$daysRemaining jours — urgent';
    return '$daysRemaining jours restants';
  }
}
