import 'package:flutter/material.dart';
import 'package:gestion_driver/core/theme/app_colors.dart';

class ProfileField extends StatelessWidget {
  const ProfileField({
    super.key,
    required this.icon,
    required this.label,
    required this.controller,
    required this.enabled,
    this.keyboardType,
    this.validator,
  });

  final IconData icon;
  final String label;
  final TextEditingController controller;
  final bool enabled;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 14),
          Expanded(
            child: TextFormField(
              controller: controller,
              enabled: enabled,
              keyboardType: keyboardType,
              validator: validator,
              style: const TextStyle(fontSize: 14, color: AppColors.primary),
              decoration: InputDecoration(
                labelText: label,
                labelStyle: const TextStyle(
                  fontSize: 11,
                  color: AppColors.secondary,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primary, width: 1.5),
                ),
                disabledBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                isDense: true,
              ),
            ),
          ),
          if (enabled)
            const Icon(Icons.edit, color: AppColors.secondary, size: 14),
        ],
      ),
    );
  }
}
