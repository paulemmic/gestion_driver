import 'package:flutter/material.dart';
import 'package:gestion_driver/shared/models/status_tone.dart';

class Vehicle {
  const Vehicle({
    required this.name,
    required this.plate,
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
  });

  final String name;
  final String plate;
  final String infoLabel;
  final String infoValue;
  final StatusTone infoTone;
  final String badgeLabel;
  final StatusTone badgeTone;
  final String complianceStatus;
  final StatusTone complianceTone;
  final String nextExpiration;
  final StatusTone nextExpirationTone;
  final List<VehicleDocument> documents;
  final FuelCardInfo fuelCard;
  final TollTagInfo tollTag;
}

class VehicleDocument {
  const VehicleDocument({
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
