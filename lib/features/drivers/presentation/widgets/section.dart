import 'package:flutter/material.dart';
import 'package:gestion_driver/core/theme/app_colors.dart';
import 'package:gestion_driver/core/theme/app_shadows.dart';

class Section extends StatelessWidget {
  const Section({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 3,
                height: 14,
                color: AppColors.primary,
                margin: const EdgeInsets.only(right: 8),
              ),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.secondary,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: AppShadows.subtle,
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}
