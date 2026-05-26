import 'package:flutter/material.dart';
import 'package:gestion_driver/core/theme/app_colors.dart';

class DateInputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  // final Function(String)? onChanged;
  final String? Function(String?)? validator;
  final bool isAlert;
  final VoidCallback? onCalendarTap;

  const DateInputField({
    required this.label,
    required this.controller,
    required this.hint,
    // this.onChanged,
    this.validator,
    this.isAlert = false,
    this.onCalendarTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      // keyboardType: TextInputType.number,
      // inputFormatters: [_DateInputFormatter()],
      // onChanged: onChanged,
      readOnly: true,
      onTap: onCalendarTap,
      validator: validator,
      style: const TextStyle(
        color: AppColors.primary,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: AppColors.secondary, fontSize: 13),
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
        prefixIcon: IconButton(
          onPressed: onCalendarTap,
          icon: Icon(
            Icons.calendar_today_outlined,
            color: isAlert ? AppColors.accent : AppColors.primary,
            size: 18,
          ),
        ),
        suffixIcon: isAlert
            ? const Padding(
                padding: EdgeInsets.only(right: 12),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.accent,
                  size: 18,
                ),
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: isAlert ? AppColors.accent : const Color(0xFFE0E6F0),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: isAlert ? AppColors.accent : const Color(0xFFE0E6F0),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: isAlert ? AppColors.accent : AppColors.primary,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.accent),
        ),
      ),
    );
  }
}
