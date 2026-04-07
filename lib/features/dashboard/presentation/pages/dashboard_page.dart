import 'package:flutter/material.dart';
import 'package:gestion_driver/core/theme/app_colors.dart';
import 'package:gestion_driver/features/dashboard/data/dashboard_mock_data.dart';
import 'package:gestion_driver/features/dashboard/presentation/widgets/alerts_by_urgency_section.dart';
import 'package:gestion_driver/shared/widgets/fleet_app_bar.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: const FleetAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // // const Text(
            // //   'Aperçu',
            // //   style: TextStyle(
            // //     fontSize: 22,
            // //     fontWeight: FontWeight.bold,
            // //     color: AppColors.textPrimary,
            // //   ),
            // // ),
            // // const SizedBox(height: 4),
            // // const Text(
            // //   'Résumé de la flotte en un coup d\'œil',
            // //   style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            // ),
            // const SizedBox(height: 16),
            // for (final item in dashboardOverviewItems) ...[
            //   OverviewCard(item: item),
            //   if (item != dashboardOverviewItems.last)
            //     const SizedBox(height: 12),
            // ],
            const SizedBox(height: 20),
            const AlertsByUrgencySection(alerts: dashboardDocumentAlerts),
          ],
        ),
      ),
    );
  }
}
