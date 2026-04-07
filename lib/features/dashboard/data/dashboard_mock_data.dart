import 'package:flutter/material.dart';
import 'package:gestion_driver/core/theme/app_colors.dart';
import 'package:gestion_driver/features/dashboard/models/dashboard_banner_stat.dart';
import 'package:gestion_driver/features/dashboard/models/dashboard_document_alert.dart';
import 'package:gestion_driver/features/dashboard/models/dashboard_overview_item.dart';
import 'package:gestion_driver/shared/models/status_tone.dart';

const dashboardBannerStats = [
  // DashboardBannerStat(label: 'TOTAL ACTIVE', value: '142'),
  DashboardBannerStat(
    label: 'DOC ALERTS',
    value: '08',
    tone: StatusTone.danger,
  ),
  // DashboardBannerStat(label: 'AVG RATING', value: '4.9 ★'),
];

const dashboardOverviewItems = [
  DashboardOverviewItem(
    title: 'Conducteurs actifs',
    value: '142',
    icon: Icons.person,
    color: AppColors.blue,
  ),
  DashboardOverviewItem(
    title: 'Alertes de documents',
    value: '8',
    icon: Icons.warning_amber,
    color: AppColors.amber,
  ),
  DashboardOverviewItem(
    title: 'Véhicules actifs',
    value: '42',
    icon: Icons.local_shipping,
    color: AppColors.green,
  ),
  DashboardOverviewItem(
    title: 'Note moyenne',
    value: '4.9★',
    icon: Icons.star,
    color: AppColors.orange,
  ),
];

const dashboardDocumentAlerts = [
  DashboardDocumentAlert(
    title: 'Assurance',
    icon: Icons.shield_outlined,
    daysRemaining: 6,
  ),
  DashboardDocumentAlert(
    title: 'Assurance',
    icon: Icons.shield_outlined,
    daysRemaining: 6,
  ),
  DashboardDocumentAlert(
    title: 'Assurance',
    icon: Icons.shield_outlined,
    daysRemaining: 1,
  ),
  DashboardDocumentAlert(
    title: 'Assurance',
    icon: Icons.shield_outlined,
    daysRemaining: 16,
  ),
  DashboardDocumentAlert(
    title: 'Visite technique',
    icon: Icons.build_circle_outlined,
    daysRemaining: 25,
  ),
  DashboardDocumentAlert(
    title: 'Visite technique',
    icon: Icons.build_circle_outlined,
    daysRemaining: 24,
  ),
  DashboardDocumentAlert(
    title: 'Visite technique',
    icon: Icons.build_circle_outlined,
    daysRemaining: 1,
  ),
  DashboardDocumentAlert(
    title: 'Visite technique',
    icon: Icons.build_circle_outlined,
    daysRemaining: 9,
  ),
  DashboardDocumentAlert(
    title: 'Patente',
    icon: Icons.assignment_turned_in_outlined,
    daysRemaining: 1,
  ),
  DashboardDocumentAlert(
    title: 'Patente',
    icon: Icons.assignment_turned_in_outlined,
    daysRemaining: 1,
  ),
];
