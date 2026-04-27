import 'package:flutter/material.dart';
import 'package:gestion_driver/core/theme/app_colors.dart';
import 'package:gestion_driver/core/theme/app_shadows.dart';
import 'package:gestion_driver/features/drivers/models/chauffeur.dart';
import 'package:gestion_driver/shared/models/status_tone.dart';

class ChauffeurCard extends StatelessWidget {
  const ChauffeurCard({
    super.key,
    required this.chauffeur,
    required this.onTap,
  });

  final Chauffeur chauffeur;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final alertColor = chauffeur.alert.tone.foregroundColor;
    final alertBg = chauffeur.alert.tone.backgroundColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border(left: BorderSide(color: alertColor, width: 3)),
          boxShadow: AppShadows.subtle,
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.bg,
                    foregroundImage:
                        chauffeur.photoUrl != null &&
                            chauffeur.photoUrl!.trim().isNotEmpty
                        ? NetworkImage(chauffeur.photoUrl!.trim())
                        : null,
                    child:
                        chauffeur.photoUrl != null &&
                            chauffeur.photoUrl!.trim().isNotEmpty
                        ? null
                        : Text(
                            chauffeur.initials,
                            style: const TextStyle(
                              color: AppColors.navy,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          chauffeur.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'ID: ${chauffeur.id}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: alertBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(chauffeur.alert.icon, color: alertColor, size: 15),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        chauffeur.alert.label,
                        style: TextStyle(
                          color: alertColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    Text(
                      chauffeur.alert.value,
                      style: TextStyle(
                        color: alertColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text(
                    'ROUTE',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
