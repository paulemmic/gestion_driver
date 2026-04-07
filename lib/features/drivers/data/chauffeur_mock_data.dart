import 'package:flutter/material.dart';
import 'package:gestion_driver/features/drivers/models/chauffeur.dart';
import 'package:gestion_driver/shared/models/status_tone.dart';

const _defaultDriverMetrics = [
  // ChauffeurMetric(label: 'SAFETY SCORE', value: '98/100'),
  ChauffeurMetric(label: 'KILOMÈTRES PARCOURUS', value: '124.5k'),
  ChauffeurMetric(label: 'HEURES D\'ACTIVITÉ', value: '2,140'),
  // ChauffeurMetric(label: 'TAUX D\'INCIDENT', value: '0.02%'),
];

const _defaultDriverDocuments = [
  ChauffeurDocument(
    icon: Icons.badge_outlined,
    title: 'Permis de conduire',
    expiry: 'Expire: 12 Nov 2027',
    status: 'VALIDE',
    tone: StatusTone.success,
  ),
  ChauffeurDocument(
    icon: Icons.shield_outlined,
    title: 'Assurance professionnelle',
    expiry: 'Expire: 28 Apr 2026',
    status: 'EXPIRE BIENTÔT',
    tone: StatusTone.warning,
  ),
  // ChauffeurDocument(
  //   icon: Icons.medical_services_outlined,
  //   title: 'Certificat médical',
  //   expiry: 'Expiré: 15 Jan 2026',
  //   status: 'LAPSED',
  //   tone: StatusTone.danger,
  // ),
  // ChauffeurDocument(
  //   icon: Icons.fact_check_outlined,
  //   title: 'vérification des antécédents',
  //   expiry: 'Expire: 02 Oct 2026',
  //   status: 'VALIDE',
  //   tone: StatusTone.success,
  // ),
  // ChauffeurDocument(
  //   icon: Icons.warning_amber_outlined,
  //   title: 'Agrément pour matières dangereuses',
  //   expiry: 'Expire: 19 Jun 2026',
  //   status: 'IN REVIEW',
  //   tone: StatusTone.notice,
  // ),
  ChauffeurDocument(
    icon: Icons.security_outlined,
    title: 'Certificat de formation à la sécurité',
    expiry: 'Expire: Perpetual',
    status: 'VALIDE',
    tone: StatusTone.success,
  ),
];

const chauffeursMockData = [
  Chauffeur(
    name: 'Marcus Thorne',
    id: 'FA-9921',
    conforme: false,
    alert: ChauffeurAlert(
      label: 'EXPIRATION DE LA LICENCE',
      value: '2 JOURS',
      tone: StatusTone.danger,
      icon: Icons.warning_amber_rounded,
    ),
    metrics: _defaultDriverMetrics,
    documents: _defaultDriverDocuments,
  ),
  Chauffeur(
    name: 'Elena Rodriguez',
    id: 'FA-8845',
    conforme: true,
    alert: ChauffeurAlert(
      label: 'TOUS CONFORMES',
      value: 'OK',
      tone: StatusTone.success,
      icon: Icons.check_circle_outline,
    ),
    metrics: _defaultDriverMetrics,
    documents: _defaultDriverDocuments,
  ),
  Chauffeur(
    name: 'Samuel Vance',
    id: 'FA-1022',
    conforme: true,
    alert: ChauffeurAlert(
      label: 'REVUE D\'ASSURANCE',
      value: '14 JOURS',
      tone: StatusTone.warning,
      icon: Icons.timer_outlined,
    ),
    metrics: _defaultDriverMetrics,
    documents: _defaultDriverDocuments,
  ),
  Chauffeur(
    name: 'Sienna Watts',
    id: 'FA-2331',
    conforme: true,
    alert: ChauffeurAlert(
      label: 'TOUS CONFORMES',
      value: 'OK',
      tone: StatusTone.success,
      icon: Icons.check_circle_outline,
    ),
    metrics: _defaultDriverMetrics,
    documents: _defaultDriverDocuments,
  ),
  Chauffeur(
    name: 'David Chen',
    id: 'FA-7712',
    conforme: false,
    alert: ChauffeurAlert(
      label: 'ASSURANCE EXPIRÉE',
      value: 'EXPIRÉ',
      tone: StatusTone.danger,
      icon: Icons.error_outline,
    ),
    metrics: _defaultDriverMetrics,
    documents: _defaultDriverDocuments,
  ),
  Chauffeur(
    name: 'Julian Grant',
    id: 'FA-4402',
    conforme: true,
    alert: ChauffeurAlert(
      label: 'ALL COMPLIANT',
      value: 'OK',
      tone: StatusTone.success,
      icon: Icons.check_circle_outline,
    ),
    metrics: _defaultDriverMetrics,
    documents: _defaultDriverDocuments,
  ),
];
