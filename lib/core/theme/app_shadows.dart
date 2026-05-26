import 'package:flutter/material.dart';
import 'package:gestion_driver/core/theme/app_colors.dart';

class AppShadows {
  const AppShadows._();

  static const List<BoxShadow> subtle = [
    BoxShadow(color: AppColors.grey, blurRadius: 8, offset: Offset(0, 2)),
  ];

  static const List<BoxShadow> card = [
    BoxShadow(color: AppColors.black, blurRadius: 12, offset: Offset(0, 4)),
  ];
}
