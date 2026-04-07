import 'package:flutter/material.dart';
import 'package:gestion_driver/core/theme/app_colors.dart';
import 'package:gestion_driver/features/drivers/data/chauffeur_mock_data.dart';
import 'package:gestion_driver/features/drivers/presentation/pages/chauffeur_profile_page.dart';
import 'package:gestion_driver/features/drivers/presentation/widgets/chauffeur_card.dart';
import 'package:gestion_driver/shared/widgets/fleet_app_bar.dart';

class ChauffeurPage extends StatelessWidget {
  const ChauffeurPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: const FleetAppBar(),
      body: Column(
        children: [
          Container(
            color: AppColors.navy,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: const Row(
              children: [
                Expanded(
                  child: StatChip(
                    label: 'ALERTS',
                    value: '08',
                    valueColor: AppColors.red,
                  ),
                ),
                _VerticalDivider(),
                Expanded(
                  child: StatChip(
                    label: 'NOTE MOYENNE',
                    value: '4.9 ★',
                    valueColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Chauffeurs',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Gérer le personnel et le statut de conformité.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const TextField(
                    decoration: InputDecoration(
                      hintText: 'Rechercher par nom ou ID...',
                      prefixIcon: Icon(
                        Icons.search,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                  const SizedBox(height: 16),
                  for (
                    var index = 0;
                    index < chauffeursMockData.length;
                    index++
                  ) ...[
                    ChauffeurCard(
                      chauffeur: chauffeursMockData[index],
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => ChauffeurProfilePage(
                              chauffeur: chauffeursMockData[index],
                            ),
                          ),
                        );
                      },
                    ),
                    if (index < chauffeursMockData.length - 1)
                      const SizedBox(height: 12),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StatChip extends StatelessWidget {
  const StatChip({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 9,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      color: Colors.white24,
      margin: const EdgeInsets.symmetric(horizontal: 6),
    );
  }
}
