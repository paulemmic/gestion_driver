// features/dashboard/presentation/pages/dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:gestion_driver/core/theme/app_colors.dart';
import 'package:gestion_driver/features/dashboard/data/services/dashboard_service.dart';
import 'package:gestion_driver/features/dashboard/models/dashboard_document_alert.dart';
import 'package:gestion_driver/features/dashboard/models/dashboard_overview_item.dart';
import 'package:gestion_driver/features/dashboard/presentation/widgets/alerts_by_urgency_section.dart';
import 'package:gestion_driver/features/dashboard/presentation/widgets/overview_card.dart';
import 'package:gestion_driver/shared/widgets/fleet_app_bar.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final service = DashboardService();

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: const FleetAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // ── Overview stats ─────────────────────────────────────────────
            StreamBuilder<List<DashboardOverviewItem>>(
              stream: service.streamOverview(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const _OverviewSkeleton();
                }
                final items = snapshot.data ?? [];
                return Column(
                  children: [
                    for (final item in items) ...[
                      OverviewCard(item: item),
                      if (item != items.last) const SizedBox(height: 12),
                    ],
                  ],
                );
              },
            ),

            const SizedBox(height: 20),

            // ── Alertes documents ──────────────────────────────────────────
            StreamBuilder<List<DashboardDocumentAlert>>(
              stream: service.streamAlerts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const _AlertSkeleton();
                }
                if (snapshot.hasError) {
                  return _ErrorTile(message: '${snapshot.error}');
                }
                final alerts = snapshot.data ?? [];
                if (alerts.isEmpty) {
                  return const _NoAlerts();
                }
                return AlertsByUrgencySection(alerts: alerts);
              },
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ─── Widgets d'état ───────────────────────────────────────────────────────────

class _OverviewSkeleton extends StatelessWidget {
  const _OverviewSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        3,
        (_) => Container(
          height: 64,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

class _AlertSkeleton extends StatelessWidget {
  const _AlertSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}

class _NoAlerts extends StatelessWidget {
  const _NoAlerts();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        children: [
          Icon(Icons.check_circle_outline, color: AppColors.green, size: 40),
          SizedBox(height: 10),
          Text(
            'Aucune alerte document',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Tous les documents sont à jour.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _ErrorTile extends StatelessWidget {
  const _ErrorTile({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.red.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.red, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: AppColors.red, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
