// features/drivers/models/chauffeur.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gestion_driver/shared/models/status_tone.dart';

class Chauffeur {
  final String id;
  final String name;
  final String? photoUrl;
  final bool conforme;
  final ChauffeurAlert alert;
  final List<ChauffeurMetric> metrics;
  final List<ChauffeurDocument> documents;

  // ─── Nouveaux champs Firebase ───────────────────────────────
  final String? telephone;
  final String? email;
  final String? numeroCin;
  final String? numeroPermis;
  final String? categoriePermis;
  final String? statut;
  final DateTime? dateNaissance;
  final DateTime? dateExpirationPermis;
  final DateTime? dateExpirationVisite;
  final DateTime? createdAt;

  const Chauffeur({
    required this.id,
    required this.name,
    this.photoUrl,
    required this.conforme,
    required this.alert,
    required this.metrics,
    required this.documents,
    this.telephone,
    this.email,
    this.numeroCin,
    this.numeroPermis,
    this.categoriePermis,
    this.statut,
    this.dateNaissance,
    this.dateExpirationPermis,
    this.dateExpirationVisite,
    this.createdAt,
  });

  Chauffeur copyWith({
    String? id,
    String? name,
    String? photoUrl,
    bool? conforme,
    ChauffeurAlert? alert,
    List<ChauffeurMetric>? metrics,
    List<ChauffeurDocument>? documents,
    String? telephone,
    String? email,
    String? numeroCin,
    String? numeroPermis,
    String? categoriePermis,
    String? statut,
    DateTime? dateNaissance,
    DateTime? dateExpirationPermis,
    DateTime? dateExpirationVisite,
    DateTime? createdAt,
  }) {
    return Chauffeur(
      id: id ?? this.id,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      conforme: conforme ?? this.conforme,
      alert: alert ?? this.alert,
      metrics: metrics ?? this.metrics,
      documents: documents ?? this.documents,
      telephone: telephone ?? this.telephone,
      email: email ?? this.email,
      numeroCin: numeroCin ?? this.numeroCin,
      numeroPermis: numeroPermis ?? this.numeroPermis,
      categoriePermis: categoriePermis ?? this.categoriePermis,
      statut: statut ?? this.statut,
      dateNaissance: dateNaissance ?? this.dateNaissance,
      dateExpirationPermis: dateExpirationPermis ?? this.dateExpirationPermis,
      dateExpirationVisite: dateExpirationVisite ?? this.dateExpirationVisite,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get initials {
    final parts = name.split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  // ─── Sérialisation Firestore ────────────────────────────────
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'photoUrl': photoUrl,
      'conforme': conforme,
      'telephone': telephone,
      'email': email,
      'numeroCin': numeroCin,
      'numeroPermis': numeroPermis,
      'categoriePermis': categoriePermis,
      'statut': statut,
      'dateNaissance': dateNaissance != null
          ? Timestamp.fromDate(dateNaissance!)
          : null,
      'dateExpirationPermis': dateExpirationPermis != null
          ? Timestamp.fromDate(dateExpirationPermis!)
          : null,
      'dateExpirationVisite': dateExpirationVisite != null
          ? Timestamp.fromDate(dateExpirationVisite!)
          : null,
      'createdAt': Timestamp.fromDate(createdAt ?? DateTime.now()),
      'alert': {
        'label': alert.label,
        'value': alert.value,
        'tone': alert.tone.name,
      },
    };
  }

  factory Chauffeur.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    DateTime? toDate(dynamic v) => v != null ? (v as Timestamp).toDate() : null;

    // Calcul automatique de l'alerte selon les dates
    final ChauffeurAlert computedAlert = computeAlert(
      dateExpirationPermis: toDate(data['dateExpirationPermis']),
      dateExpirationVisite: toDate(data['dateExpirationVisite']),
    );

    return Chauffeur(
      id: data['id'] ?? doc.id,
      name: data['name'] ?? '',
      photoUrl: data['photoUrl'],
      conforme: data['conforme'] ?? true,
      alert: computedAlert,
      metrics: const [],
      documents: const [],
      telephone: data['telephone'],
      email: data['email'],
      numeroCin: data['numeroCin'],
      numeroPermis: data['numeroPermis'],
      categoriePermis: data['categoriePermis'],
      statut: data['statut'],
      dateNaissance: toDate(data['dateNaissance']),
      dateExpirationPermis: toDate(data['dateExpirationPermis']),
      dateExpirationVisite: toDate(data['dateExpirationVisite']),
      createdAt: toDate(data['createdAt']),
    );
  }

  // ─── Calcul automatique de l'alerte ────────────────────────
  static ChauffeurAlert computeAlert({
    DateTime? dateExpirationPermis,
    DateTime? dateExpirationVisite,
  }) {
    final now = DateTime.now();
    final soon = now.add(const Duration(days: 30));

    // Permis expiré
    if (dateExpirationPermis != null && dateExpirationPermis.isBefore(now)) {
      return const ChauffeurAlert(
        label: 'PERMIS EXPIRÉ',
        value: 'EXPIRÉ',
        tone: StatusTone.danger,
        icon: Icons.error_outline,
      );
    }
    // Permis expire bientôt
    if (dateExpirationPermis != null && dateExpirationPermis.isBefore(soon)) {
      final days = dateExpirationPermis.difference(now).inDays;
      return ChauffeurAlert(
        label: 'EXPIRATION DU PERMIS',
        value: '$days JOURS',
        tone: StatusTone.danger,
        icon: Icons.warning_amber_rounded,
      );
    }
    // Visite médicale expire bientôt
    if (dateExpirationVisite != null && dateExpirationVisite.isBefore(soon)) {
      final days = dateExpirationVisite.difference(now).inDays;
      return ChauffeurAlert(
        label: 'VISITE MÉDICALE',
        value: '$days JOURS',
        tone: StatusTone.warning,
        icon: Icons.timer_outlined,
      );
    }

    return const ChauffeurAlert(
      label: 'TOUS CONFORMES',
      value: 'OK',
      tone: StatusTone.success,
      icon: Icons.check_circle_outline,
    );
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
