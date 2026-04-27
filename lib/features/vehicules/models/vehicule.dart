import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gestion_driver/shared/models/status_tone.dart';

class Vehicule {
  final String name;
  final String plaque;
  final String infoLabel;
  final String infoValue;
  final StatusTone infoTone;
  final String badgeLabel;
  final StatusTone badgeTone;
  final String complianceStatus;
  final StatusTone complianceTone;
  final String nextExpiration;
  final StatusTone nextExpirationTone;
  final List<VehiculeDocument> documents;
  final FuelCardInfo fuelCard;
  final TollTagInfo tollTag;
  final String? id;
  final String? marque;
  final String? modele;
  final String? vin;
  final int? annee;
  final int? kilometrage;
  final String? carburant;
  final String? statut;
  final String? notes;
  final DateTime? createdAt;

  const Vehicule({
    required this.name,
    required this.plaque,
    required this.infoLabel,
    required this.infoValue,
    required this.infoTone,
    required this.badgeLabel,
    required this.badgeTone,
    required this.complianceStatus,
    required this.complianceTone,
    required this.nextExpiration,
    required this.nextExpirationTone,
    required this.documents,
    required this.fuelCard,
    required this.tollTag,
    required this.id,
    required this.marque,
    required this.modele,
    required this.vin,
    required this.annee,
    required this.kilometrage,
    required this.carburant,
    required this.statut,
    required this.notes,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'plaque': plaque,
      'marque': marque,
      'modele': modele,
      'vin': vin,
      'annee': annee,
      'kilometrage': kilometrage,
      'carburant': carburant,
      'statut': statut,
      'notes': notes,
      'badgeLabel': badgeLabel,
      'badgeTone': badgeTone.name,
      'complianceStatus': complianceStatus,
      'complianceTone': complianceTone.name,
      'nextExpiration': nextExpiration,
      'nextExpirationTone': nextExpirationTone.name,
      'createdAt': Timestamp.fromDate(createdAt ?? DateTime.now()),
    };
  }

  factory Vehicule.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    final statut = data['statut'] as String? ?? 'Actif';

    final StatusTone badgeTone = switch (statut) {
      'En maintenance' => StatusTone.danger,
      'Inactif' => StatusTone.neutral,
      _ => StatusTone.success,
    };

    final km = data['kilometrage'] as int?;

    return Vehicule(
      id: data['id'] ?? doc.id,
      name: data['name'] ?? '',
      plaque: data['plaque'] ?? '',
      marque: data['marque'],
      modele: data['modele'],
      vin: data['vin'],
      annee: data['annee'],
      kilometrage: km,
      carburant: data['carburant'],
      statut: statut,
      notes: data['notes'],
      infoLabel: 'Kilométrage',
      infoValue: km != null ? '${_formatKm(km)} km' : '—',
      infoTone: StatusTone.neutral,
      badgeLabel: statut.toUpperCase(),
      badgeTone: badgeTone,
      complianceStatus: data['complianceStatus'] ?? 'Conforme',
      complianceTone: StatusTone.success,
      nextExpiration: data['nextExpiration'] ?? '—',
      nextExpirationTone: StatusTone.neutral,
      documents: const [],
      fuelCard: const FuelCardInfo(
        status: '—',
        tone: StatusTone.neutral,
        subtitle: '—',
        expiry: '—',
      ),
      tollTag: const TollTagInfo(
        status: '—',
        tone: StatusTone.neutral,
        subtitle: '—',
        issue: '—',
        actionLabel: '—',
      ),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  static String _formatKm(int km) {
    if (km >= 1000) {
      return '${(km / 1000).toStringAsFixed(1)}k';
    }
    return km.toString();
  }
}

class VehiculeDocument {
  const VehiculeDocument({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.tone,
    required this.extra,
    this.extraTone = StatusTone.neutral,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String status;
  final StatusTone tone;
  final String extra;
  final StatusTone extraTone;
}

class FuelCardInfo {
  const FuelCardInfo({
    required this.status,
    required this.tone,
    required this.subtitle,
    required this.expiry,
  });

  final String status;
  final StatusTone tone;
  final String subtitle;
  final String expiry;
}

class TollTagInfo {
  const TollTagInfo({
    required this.status,
    required this.tone,
    required this.subtitle,
    required this.issue,
    required this.actionLabel,
  });

  final String status;
  final StatusTone tone;
  final String subtitle;
  final String issue;
  final String actionLabel;
}
