import 'package:flutter/material.dart';
import 'package:gestion_driver/core/theme/app_colors.dart';

enum StatusTone { success, warning, danger, accent, notice, neutral }

extension StatusToneStyle on StatusTone {
  Color get foregroundColor {
    switch (this) {
      case StatusTone.success:
        return AppColors.green;
      case StatusTone.warning:
        return AppColors.amber;
      case StatusTone.danger:
        return AppColors.red;
      case StatusTone.accent:
        return AppColors.blue;
      case StatusTone.notice:
        return AppColors.orange;
      case StatusTone.neutral:
        return AppColors.navy;
    }
  }

  Color get backgroundColor {
    switch (this) {
      case StatusTone.success:
        return AppColors.greenLight;
      case StatusTone.warning:
        return AppColors.amberLight;
      case StatusTone.danger:
        return AppColors.redLight;
      case StatusTone.accent:
        return AppColors.blueLight;
      case StatusTone.notice:
        return AppColors.orangeLight;
      case StatusTone.neutral:
        return AppColors.bg;
    }
  }
}
