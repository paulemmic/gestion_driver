import 'package:flutter/material.dart';
import 'package:gestion_driver/features/vehicules/models/vehicle.dart';
import 'package:gestion_driver/shared/models/status_tone.dart';

const _defaultVehicleDocuments = [
  VehicleDocument(
    icon: Icons.description_outlined,
    title: 'Registration Document',
    subtitle: 'VIN: 1HGCM82633A004352',
    status: 'VALID',
    tone: StatusTone.success,
    extra: 'Permanent',
  ),
  VehicleDocument(
    icon: Icons.shield_outlined,
    title: 'Insurance Policy',
    subtitle: 'AXA Commercial - #99283-BB',
    status: 'EXPIRING SOON',
    tone: StatusTone.warning,
    extra: '14 Oct 2026',
    extraTone: StatusTone.warning,
  ),
  VehicleDocument(
    icon: Icons.build_circle_outlined,
    title: 'Visite Technique',
    subtitle: 'Last inspection: 12 Jan 2026',
    status: 'VALID',
    tone: StatusTone.success,
    extra: '12 Jan 2027',
  ),
];

const _defaultFuelCard = FuelCardInfo(
  status: 'ACTIVE',
  tone: StatusTone.success,
  subtitle: 'Shell Business •••• 4482',
  expiry: '08/2027',
);

const _defaultTollTag = TollTagInfo(
  status: 'ACTION REQUIRED',
  tone: StatusTone.danger,
  subtitle: 'E-ZPass Regional Unit',
  issue: 'Battery Low / Signal Weak',
  actionLabel: 'REQUEST REPLACEMENT',
);

const vehiclesMockData = [
  Vehicle(
    name: 'Toyota Hilux',
    plate: 'TX-492-ZA',
    infoLabel: 'Insurance Expiry',
    infoValue: '12 Oct 2026',
    infoTone: StatusTone.neutral,
    badgeLabel: 'OPERATIONAL',
    badgeTone: StatusTone.success,
    complianceStatus: 'Fully Compliant',
    complianceTone: StatusTone.success,
    nextExpiration: '14 Oct 2026',
    nextExpirationTone: StatusTone.warning,
    documents: _defaultVehicleDocuments,
    fuelCard: _defaultFuelCard,
    tollTag: _defaultTollTag,
  ),
  Vehicle(
    name: 'Ford Transit Custom',
    plate: 'UK-882-MM',
    infoLabel: 'License Renewal',
    infoValue: 'Expired 01 Apr 2026',
    infoTone: StatusTone.danger,
    badgeLabel: 'CRITICAL ALERT',
    badgeTone: StatusTone.danger,
    complianceStatus: 'Compliance Blocked',
    complianceTone: StatusTone.danger,
    nextExpiration: 'Immediate Action',
    nextExpirationTone: StatusTone.danger,
    documents: _defaultVehicleDocuments,
    fuelCard: _defaultFuelCard,
    tollTag: _defaultTollTag,
  ),
  Vehicle(
    name: 'Volvo FH16 Semi',
    plate: 'BE-004-GT',
    infoLabel: 'Next Inspection',
    infoValue: '17 Apr 2026',
    infoTone: StatusTone.warning,
    badgeLabel: 'MAINTENANCE',
    badgeTone: StatusTone.warning,
    complianceStatus: 'Scheduled Review',
    complianceTone: StatusTone.warning,
    nextExpiration: '17 Apr 2026',
    nextExpirationTone: StatusTone.warning,
    documents: _defaultVehicleDocuments,
    fuelCard: _defaultFuelCard,
    tollTag: _defaultTollTag,
  ),
  Vehicle(
    name: 'Mercedes Sprinter',
    plate: 'DE-921-PL',
    infoLabel: 'Maintenance History',
    infoValue: 'View Records',
    infoTone: StatusTone.accent,
    badgeLabel: 'OPERATIONAL',
    badgeTone: StatusTone.success,
    complianceStatus: 'Fully Compliant',
    complianceTone: StatusTone.success,
    nextExpiration: '28 Nov 2026',
    nextExpirationTone: StatusTone.neutral,
    documents: _defaultVehicleDocuments,
    fuelCard: _defaultFuelCard,
    tollTag: _defaultTollTag,
  ),
];
