import 'package:flutter/material.dart';
import 'package:gestion_driver/core/theme/app_colors.dart';

class AppShadows {
  const AppShadows._();

  static const List<BoxShadow> subtle = [
    BoxShadow(color: AppColors.shadowSoft, blurRadius: 8, offset: Offset(0, 2)),
  ];

  static const List<BoxShadow> card = [
    BoxShadow(color: AppColors.shadow, blurRadius: 12, offset: Offset(0, 4)),
  ];
}
