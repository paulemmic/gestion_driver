import 'package:flutter/material.dart';
import 'package:gestion_driver/core/theme/app_colors.dart';
import 'package:gestion_driver/features/drivers/models/chauffeur.dart';
import 'package:gestion_driver/features/drivers/presentation/widgets/chauffeur_expiry_status.dart';

class ChauffeurHeaderStats extends StatelessWidget {
  const ChauffeurHeaderStats({super.key, required this.chauffeurs});

  final List<Chauffeur> chauffeurs;

  @override
  Widget build(BuildContext context) {
    final expiredCount = chauffeurs
        .where((c) => chauffeurExpiryStatus(c) == ChauffeurExpiryStatus.expired)
        .length;

    final expiringSoonCount = chauffeurs
        .where(
          (c) => chauffeurExpiryStatus(c) == ChauffeurExpiryStatus.expiringSoon,
        )
        .length;

    final okCount = chauffeurs.length - expiredCount - expiringSoonCount;

    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: _StatChip(
              label: 'EXPIRÉS',
              value: expiredCount.toString().padLeft(2, '0'),
              valueColor: AppColors.accent,
            ),
          ),
          const _VerticalDivider(),
          Expanded(
            child: _StatChip(
              label: 'EXPIRENT BIENTÔT',
              value: expiringSoonCount.toString().padLeft(2, '0'),
              valueColor: const Color(0xFFF5A623),
            ),
          ),
          const _VerticalDivider(),
          Expanded(
            child: _StatChip(
              label: 'CONFORMES',
              value: okCount.toString().padLeft(2, '0'),
              valueColor: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
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
