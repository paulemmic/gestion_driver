import 'package:flutter/material.dart';
import 'package:gestion_driver/core/theme/app_colors.dart';

class ChauffeurSearchBar extends StatelessWidget {
  const ChauffeurSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: const InputDecoration(
        hintText: 'Rechercher par nom ou ID...',
        prefixIcon: Icon(Icons.search, color: AppColors.secondary, size: 20),
        border: InputBorder.none,
      ),
    );
  }
}
