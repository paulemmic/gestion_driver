import 'package:flutter/material.dart';
import 'package:gestion_driver/core/theme/app_colors.dart';
import 'package:gestion_driver/features/dashboard/models/dashboard_banner_stat.dart';
import 'package:gestion_driver/shared/models/status_tone.dart';

class StatsBanner extends StatelessWidget {
  const StatsBanner({super.key, required this.items});

  final List<DashboardBannerStat> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          for (var index = 1; index < items.length; index++) ...[
            Expanded(child: _StatItem(item: items[index])),
            if (index < items.length - 1)
              Container(width: 1, height: 36, color: Colors.white24),
          ],
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.item});

  final DashboardBannerStat item;

  @override
  Widget build(BuildContext context) {
    final valueColor = item.tone == StatusTone.danger
        ? AppColors.red
        : Colors.white;

    return Column(
      children: [
        Text(
          item.label,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 10,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          item.value,
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
