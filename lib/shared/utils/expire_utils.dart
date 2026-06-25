import 'package:flutter/material.dart';
import 'package:gestion_driver/core/theme/app_colors.dart';

enum ExpiryStatus { ok, arrive, urgent, expire }

class ExpireInfo {
  final ExpiryStatus status;
  final Color color;
  final IconData icon;
  final String label;

  const ExpireInfo({
    required this.status,
    required this.color,
    required this.icon,
    required this.label,
  });
}

ExpireInfo getExpiryInfo(DateTime? date) {
  if (date == null) {
    return ExpireInfo(
      status: ExpiryStatus.ok,
      color: AppColors.succe.withValues(alpha: 0.08),
      icon: Icons.check_circle,
      label: 'Tous les documents conformes',
    );
  }

  final maint = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );
  final dateOnly = DateTime(date.year, date.month, date.day);
  final diff = dateOnly.difference(maint).inDays;

  if (diff < 0) {
    return ExpireInfo(
      status: ExpiryStatus.expire,
      color: AppColors.accent,
      icon: Icons.cancel,
      label: 'Expiré depuis ${diff.abs()} jour${diff.abs() > 1 ? 's' : ''}',
    );
  } else if (diff == 0) {
    return ExpireInfo(
      status: ExpiryStatus.urgent,
      color: AppColors.accent,
      icon: Icons.warning_rounded,
      label: 'Expire aujourd\'hui',
    );
  } else if (diff <= 7) {
    return ExpireInfo(
      status: ExpiryStatus.urgent,
      color: AppColors.warning,
      icon: Icons.warning_rounded,
      label: 'Expire dans $diff jour${diff > 1 ? 's' : ''}',
    );
  } else if (diff <= 30) {
    return ExpireInfo(
      status: ExpiryStatus.arrive,
      color: AppColors.warning,
      icon: Icons.warning_amber_rounded,
      label: 'Expire dans $diff jours',
    );
  } else {
    return const ExpireInfo(
      status: ExpiryStatus.ok,
      color: AppColors.succe,
      icon: Icons.check_circle,
      label: 'Tous les documents conformes',
    );
  }
}
