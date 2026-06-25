import 'package:flutter/material.dart';
import 'package:gestion_driver/core/theme/app_colors.dart';

class SectionLabel extends StatelessWidget {
  const SectionLabel({super.key, required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Text(
    label.toUpperCase(),
    style: const TextStyle(
      color: AppColors.secondary,
      fontSize: 10,
      letterSpacing: 0.8,
      fontWeight: FontWeight.w700,
    ),
  );
}
