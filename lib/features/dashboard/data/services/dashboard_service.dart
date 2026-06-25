import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gestion_driver/core/theme/app_colors.dart';
import 'package:gestion_driver/features/dashboard/models/dashboard_document_alert.dart';
import 'package:gestion_driver/features/dashboard/models/dashboard_overview_item.dart';

typedef _FirestoreSnapshot = QuerySnapshot<Map<String, dynamic>>;

class DashboardService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Stream<List<DashboardDocumentAlert>> streamAlerts() {
    return _combineCollections(
      build: (chauffeursSnap, vehiculesSnap) {
        final alerts = <DashboardDocumentAlert>[];
        final now = DateTime.now();

        for (final doc in chauffeursSnap.docs) {
          final data = doc.data();
          final name = data['name'] as String? ?? 'Chauffeur inconnu';
          final datePermis = _toDate(data['dateExpirationPermis']);

          if (datePermis != null) {
            final days = datePermis.difference(now).inDays;
            if (days <= 30) {
              alerts.add(
                DashboardDocumentAlert(
                  title: 'Permis - $name',
                  icon: Icons.badge_outlined,
                  daysRemaining: days < 0 ? 0 : days,
                  isExpired: days < 0,
                  entityId: doc.id,
                  entityType: EntityType.chauffeur,
                ),
              );
            }
          }
        }

        for (final doc in vehiculesSnap.docs) {
          final data = doc.data();
          final plaque = data['plaque'] as String? ?? 'Vehicule inconnu';
          final name = data['name'] as String? ?? 'Vehicule inconnu';
          final dateVisite = _toDate(data['dateExpirationVisite']);

          final checks = {
            'Assurance': (
              _toDate(data['dateExpirationAssurance']),
              Icons.shield_outlined,
            ),
            'Visite technique': (
              _toDate(data['dateExpirationVisite']),
              Icons.build_circle_outlined,
            ),
            'Patente': (
              _toDate(data['dateExpirationPatente']),
              Icons.assignment_turned_in_outlined,
            ),
          };

          if (dateVisite != null) {
            final days = dateVisite.difference(now).inDays;
            if (days <= 30) {
              alerts.add(
                DashboardDocumentAlert(
                  title: 'Visite - $name $plaque',
                  icon: Icons.badge_outlined,
                  daysRemaining: days < 0 ? 0 : days,
                  isExpired: days < 0,
                  entityId: doc.id,
                  entityType: EntityType.chauffeur,
                ),
              );
            }
          }

          for (final entry in checks.entries) {
            final date = entry.value.$1;
            final icon = entry.value.$2;
            if (date != null) {
              final days = date.difference(now).inDays;
              if (days <= 30) {
                alerts.add(
                  DashboardDocumentAlert(
                    title: '${entry.key} - $plaque',
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

        alerts.sort((a, b) => a.daysRemaining.compareTo(b.daysRemaining));
        return alerts;
      },
    );
  }

  Stream<List<DashboardOverviewItem>> streamOverview() {
    return _combineCollections(
      build: (chauffeursSnap, vehiculesSnap) {
        final totalChauffeurs = chauffeursSnap.docs.length;
        final chauffeursActifs = chauffeursSnap.docs
            .where((d) => d.data()['statut'] == 'Actif')
            .length;

        final totalVehicules = vehiculesSnap.docs.length;
        final vehiculesActifs = vehiculesSnap.docs
            .where((d) => d.data()['statut'] == 'Actif')
            .length;

        final now = DateTime.now();
        final alertCount =
            _countExpiringDocuments(chauffeursSnap.docs, [
              'dateExpirationPermis',
            ], now) +
            _countExpiringDocuments(vehiculesSnap.docs, [
              'dateExpirationAssurance',
              'dateExpirationVisite',
              'dateExpirationPatente',
            ], now);

        return [
          DashboardOverviewItem(
            title: 'Conducteurs actifs',
            value: '$chauffeursActifs/$totalChauffeurs',
            icon: Icons.person,
            color: AppColors.info,
          ),
          DashboardOverviewItem(
            title: 'Alertes documents',
            value: '$alertCount',
            icon: Icons.warning_amber,
            color: AppColors.warning,
          ),
          DashboardOverviewItem(
            title: 'Vehicules actifs',
            value: '$vehiculesActifs/$totalVehicules',
            icon: Icons.local_shipping,
            color: AppColors.succe,
          ),
        ];
      },
    );
  }

  Stream<T> _combineCollections<T>({
    required T Function(
      _FirestoreSnapshot chauffeursSnap,
      _FirestoreSnapshot vehiculesSnap,
    )
    build,
  }) {
    late StreamController<T> controller;
    StreamSubscription<_FirestoreSnapshot>? chauffeursSubscription;
    StreamSubscription<_FirestoreSnapshot>? vehiculesSubscription;
    _FirestoreSnapshot? latestChauffeurs;
    _FirestoreSnapshot? latestVehicules;

    void emitIfReady() {
      final chauffeursSnap = latestChauffeurs;
      final vehiculesSnap = latestVehicules;
      if (chauffeursSnap == null || vehiculesSnap == null) return;
      controller.add(build(chauffeursSnap, vehiculesSnap));
    }

    controller = StreamController<T>(
      onListen: () {
        chauffeursSubscription = firestore
            .collection('chauffeurs')
            .snapshots()
            .listen((snapshot) {
              latestChauffeurs = snapshot;
              emitIfReady();
            }, onError: controller.addError);

        vehiculesSubscription = firestore
            .collection('vehicules')
            .snapshots()
            .listen((snapshot) {
              latestVehicules = snapshot;
              emitIfReady();
            }, onError: controller.addError);
      },
      onCancel: () async {
        await chauffeursSubscription?.cancel();
        await vehiculesSubscription?.cancel();
      },
    );

    return controller.stream;
  }

  int _countExpiringDocuments(
    Iterable<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
    List<String> keys,
    DateTime now,
  ) {
    var count = 0;
    for (final doc in docs) {
      final data = doc.data();
      for (final key in keys) {
        final date = _toDate(data[key]);
        if (date != null && date.difference(now).inDays <= 30) {
          count++;
        }
      }
    }
    return count;
  }

  DateTime? _toDate(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    return null;
  }
}

enum EntityType { chauffeur, vehicule }
