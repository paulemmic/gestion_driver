import 'package:flutter/material.dart';
import 'package:gestion_driver/core/theme/app_colors.dart';
import 'package:gestion_driver/core/theme/app_shadows.dart';
import 'package:gestion_driver/features/dashboard/models/dashboard_document_alert.dart';
import 'package:gestion_driver/shared/models/status_tone.dart';
import 'package:gestion_driver/shared/widgets/status_badge.dart';

class AlertsByUrgencySection extends StatelessWidget {
  const AlertsByUrgencySection({super.key, required this.alerts});

  final List<DashboardDocumentAlert> alerts;

  @override
  Widget build(BuildContext context) {
    final sortedAlerts = [...alerts]
      ..sort(
        (first, second) => first.daysRemaining.compareTo(second.daysRemaining),
      );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppShadows.subtle,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Alertes documents par urgence',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Assurance, visite technique et patente triees par priorite.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 14),
          for (var index = 0; index < sortedAlerts.length; index++) ...[
            _AlertTile(alert: sortedAlerts[index]),
            if (index < sortedAlerts.length - 1)
              const Divider(height: 18, color: AppColors.border),
          ],
        ],
      ),
    );
  }
}

class _AlertTile extends StatelessWidget {
  const _AlertTile({required this.alert});

  final DashboardDocumentAlert alert;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: alert.tone.backgroundColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(alert.icon, size: 20, color: alert.tone.foregroundColor),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            alert.title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        StatusBadge(label: alert.urgencyLabel.toUpperCase(), tone: alert.tone),
      ],
    );
  }
}
