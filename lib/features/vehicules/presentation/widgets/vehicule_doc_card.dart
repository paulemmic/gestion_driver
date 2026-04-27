import 'package:flutter/material.dart';
import 'package:gestion_driver/core/theme/app_colors.dart';
import 'package:gestion_driver/core/theme/app_shadows.dart';
import 'package:gestion_driver/features/vehicules/models/vehicule.dart';
import 'package:gestion_driver/shared/models/status_tone.dart';
import 'package:gestion_driver/shared/widgets/status_badge.dart';

class VehiculeDocCard extends StatelessWidget {
  const VehiculeDocCard({super.key, required this.document});

  final VehiculeDocument document;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border(
          left: BorderSide(color: document.tone.foregroundColor, width: 3),
        ),
        boxShadow: AppShadows.subtle,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.blueLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(document.icon, color: AppColors.blue, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        document.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    StatusBadge(label: document.status, tone: document.tone),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  document.subtitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  document.extra,
                  style: TextStyle(
                    color: document.extraTone.foregroundColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
