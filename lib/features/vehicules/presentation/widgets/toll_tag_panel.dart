import 'package:flutter/material.dart';
import 'package:gestion_driver/core/theme/app_colors.dart';
import 'package:gestion_driver/core/theme/app_shadows.dart';
import 'package:gestion_driver/features/vehicules/models/vehicule.dart';
import 'package:gestion_driver/shared/widgets/status_badge.dart';

class TollTagPanel extends StatelessWidget {
  const TollTagPanel({super.key, required this.tag});

  final TollTagInfo tag;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: const Border(
          left: BorderSide(color: AppColors.accent, width: 3),
        ),
        boxShadow: AppShadows.subtle,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.wifi_tethering,
                color: AppColors.secondary,
                size: 18,
              ),
              const Spacer(),
              StatusBadge(
                label: tag.status,
                tone: tag.tone,
                status: tag.status,
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Badge Télépéage Autoroute',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            tag.subtitle,
            style: const TextStyle(color: AppColors.secondary, fontSize: 12),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.battery_alert,
                color: AppColors.accent,
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                tag.issue,
                style: const TextStyle(
                  color: AppColors.accent,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.accent,
                side: const BorderSide(color: AppColors.accent),
              ),
              child: Text(tag.actionLabel),
            ),
          ),
        ],
      ),
    );
  }
}
