import 'package:flutter/material.dart';
import 'package:gestion_driver/core/theme/app_colors.dart';

enum StatusTone { success, warning, danger, accent, notice, neutral }

extension StatusToneStyle on StatusTone {
  Color get foregroundColor {
    switch (this) {
      case StatusTone.success:
        return AppColors.succe;
      case StatusTone.warning:
        return AppColors.warning;
      case StatusTone.danger:
        return AppColors.danger;
      case StatusTone.accent:
        return AppColors.accent;
      case StatusTone.notice:
        return AppColors.warning;
      case StatusTone.neutral:
        return AppColors.primary;
    }
  }

  Color get backgroundColor {
    switch (this) {
      case StatusTone.success:
        return AppColors.succe.withOpacity(0.08);
      case StatusTone.warning:
        return AppColors.warning.withOpacity(0.08);
      case StatusTone.danger:
        return AppColors.danger.withOpacity(0.08);
      case StatusTone.accent:
        return AppColors.accent.withOpacity(0.08);
      case StatusTone.notice:
        return AppColors.warning.withOpacity(0.08);
      case StatusTone.neutral:
        return AppColors.bg;
    }
  }
}
