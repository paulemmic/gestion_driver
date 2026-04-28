import 'package:flutter/material.dart';
import 'package:gestion_driver/core/theme/app_colors.dart';

class MissingOperationalCardsHint extends StatelessWidget {
  const MissingOperationalCardsHint();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: const Text(
        'Aucune carte opérationnelle disponible pour ce véhicule.',
        style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
      ),
    );
  }
}
