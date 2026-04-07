import 'package:flutter/material.dart';
import 'package:gestion_driver/shared/models/status_tone.dart';

class Chauffeur {
  const Chauffeur({
    required this.name,
    required this.id,
    // required this.route,
    // required this.roleTag,
    // required this.specialty,
    // required this.region,
    required this.conforme,
    required this.alert,
    required this.metrics,
    required this.documents,
    // required this.auditNote,
    // required this.auditSchedule,
    // required this.alertDescription,
  });

  final String name;
  final String id;
  // final String route;
  // final String roleTag;
  // final String specialty;
  // final String region;
  final bool conforme;
  final ChauffeurAlert alert;
  final List<ChauffeurMetric> metrics;
  final List<ChauffeurDocument> documents;
  // final String auditNote;
  // final String auditSchedule;
  // final String alertDescription;

  String get initials {
    final parts = name.split(' ').where((part) => part.isNotEmpty).toList();
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}

class ChauffeurAlert {
  const ChauffeurAlert({
    required this.label,
    required this.value,
    required this.tone,
    required this.icon,
  });

  final String label;
  final String value;
  final StatusTone tone;
  final IconData icon;
}

class ChauffeurMetric {
  const ChauffeurMetric({required this.label, required this.value});

  final String label;
  final String value;
}

class ChauffeurDocument {
  const ChauffeurDocument({
    required this.icon,
    required this.title,
    required this.expiry,
    required this.status,
    required this.tone,
  });

  final IconData icon;
  final String title;
  final String expiry;
  final String status;
  final StatusTone tone;
}
