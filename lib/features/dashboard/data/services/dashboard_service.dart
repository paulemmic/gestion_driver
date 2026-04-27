// features/dashboard/services/dashboard_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gestion_driver/core/theme/app_colors.dart';
import 'package:gestion_driver/features/dashboard/models/dashboard_document_alert.dart';
import 'package:gestion_driver/features/dashboard/models/dashboard_overview_item.dart';

class DashboardService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // ─── Stream des alertes combinées (chauffeurs + véhicules) ────────────────
  Stream<List<DashboardDocumentAlert>> streamAlerts() {
    final chauffeursStream = firestore.collection('chauffeurs').snapshots();

    final vehiculesStream = firestore.collection('vehicules').snapshots();

    return chauffeursStream.asyncMap((chauffeursSnap) async {
      final vehiculesSnap = await firestore.collection('vehicules').get();
      final alerts = <DashboardDocumentAlert>[];
      final now = DateTime.now();

      // ── Alertes chauffeurs ─────────────────────────────────────────
      for (final doc in chauffeursSnap.docs) {
        final data = doc.data();
        final name = data['name'] as String? ?? 'Chauffeur inconnu';

        final datePermis = _toDate(data['dateExpirationPermis']);
        final dateVisite = _toDate(data['dateExpirationVisite']);

        if (datePermis != null) {
          final days = datePermis.difference(now).inDays;
          if (days <= 30) {
            alerts.add(
              DashboardDocumentAlert(
                title: 'Permis — $name',
                icon: Icons.badge_outlined,
                daysRemaining: days < 0 ? 0 : days,
                isExpired: days < 0,
                entityId: doc.id,
                entityType: EntityType.chauffeur,
              ),
            );
          }
        }

        if (dateVisite != null) {
          final days = dateVisite.difference(now).inDays;
          if (days <= 30) {
            alerts.add(
              DashboardDocumentAlert(
                title: 'Visite médicale — $name',
                icon: Icons.medical_services_outlined,
                daysRemaining: days < 0 ? 0 : days,
                isExpired: days < 0,
                entityId: doc.id,
                entityType: EntityType.chauffeur,
              ),
            );
          }
        }
      }

      // ── Alertes véhicules ──────────────────────────────────────────
      for (final doc in vehiculesSnap.docs) {
        final data = doc.data();
        final plaque = data['plaque'] as String? ?? '—';

        final dateAssurance = _toDate(data['dateExpirationAssurance']);
        final dateVisite = _toDate(data['dateExpirationVisite']);
        final datePatente = _toDate(data['dateExpirationPatente']);

        final checks = {
          'Assurance': (dateAssurance, Icons.shield_outlined),
          'Visite technique': (dateVisite, Icons.build_circle_outlined),
          'Patente': (datePatente, Icons.assignment_turned_in_outlined),
        };

        for (final entry in checks.entries) {
          final date = entry.value.$1;
          final icon = entry.value.$2;
          if (date != null) {
            final days = date.difference(now).inDays;
            if (days <= 30) {
              alerts.add(
                DashboardDocumentAlert(
                  title: '${entry.key} — $plaque',
                  icon: icon,
                  daysRemaining: days < 0 ? 0 : days,
                  isExpired: days < 0,
                  entityId: doc.id,
                  entityType: EntityType.vehicule,
                ),
              );
            }
          }
        }
      }

      // Trier par urgence
      alerts.sort((a, b) => a.daysRemaining.compareTo(b.daysRemaining));
      return alerts;
    });
  }

  // ─── Stream des stats overview ─────────────────────────────────────────────
  Stream<List<DashboardOverviewItem>> streamOverview() {
    return firestore.collection('chauffeurs').snapshots().asyncMap((
      chauffeursSnap,
    ) async {
      final vehiculesSnap = await firestore.collection('vehicules').get();

      final totalChauffeurs = chauffeursSnap.docs.length;
      final chauffeursActifs = chauffeursSnap.docs
          .where((d) => d.data()['statut'] == 'Actif')
          .length;

      final totalVehicules = vehiculesSnap.docs.length;
      final vehiculesActifs = vehiculesSnap.docs
          .where((d) => d.data()['statut'] == 'Actif')
          .length;

      // Calcul alertes totales (docs expirant dans 30 jours)
      final now = DateTime.now();
      int alertCount = 0;
      for (final doc in [...chauffeursSnap.docs, ...vehiculesSnap.docs]) {
        final data = doc.data();
        for (final key in [
          'dateExpirationPermis',
          'dateExpirationVisite',
          'dateExpirationAssurance',
          'dateExpirationPatente',
        ]) {
          final date = _toDate(data[key]);
          if (date != null && date.difference(now).inDays <= 30) {
            alertCount++;
          }
        }
      }

      return [
        DashboardOverviewItem(
          title: 'Conducteurs actifs',
          value: '$chauffeursActifs/$totalChauffeurs',
          icon: Icons.person,
          color: AppColors.blue,
        ),
        DashboardOverviewItem(
          title: 'Alertes documents',
          value: '$alertCount',
          icon: Icons.warning_amber,
          color: AppColors.amber,
        ),
        DashboardOverviewItem(
          title: 'Véhicules actifs',
          value: '$vehiculesActifs/$totalVehicules',
          icon: Icons.local_shipping,
          color: AppColors.green,
        ),
      ];
    });
  }

  DateTime? _toDate(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    return null;
  }
}

enum EntityType { chauffeur, vehicule }
