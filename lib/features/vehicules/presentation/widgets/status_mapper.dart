import 'package:flutter/material.dart';
import 'package:gestion_driver/core/theme/app_colors.dart';
import 'package:gestion_driver/features/vehicules/models/status_config.dart';
import 'package:gestion_driver/features/vehicules/presentation/pages/add_vehicule_page.dart';

class StatusMapper {
  static StatusConfig fromStatus(VehiculeStatus status) {
    switch (status) {
      case VehiculeStatus.actif:
        return const StatusConfig(
          label: "Disponible",
          color: AppColors.succe,
          bgColor: AppColors.white,
          icon: Icons.check_circle,
        );

      case VehiculeStatus.enCourse:
        return const StatusConfig(
          label: "En course",
          color: AppColors.info,
          bgColor: AppColors.white,
          icon: Icons.local_taxi,
        );

      case VehiculeStatus.maintenance:
        return const StatusConfig(
          label: "Maintenance",
          color: AppColors.warning,
          bgColor: AppColors.white,
          icon: Icons.build,
        );

      case VehiculeStatus.inactif:
        return const StatusConfig(
          label: "Hors service",
          color: AppColors.danger,
          bgColor: AppColors.white,
          icon: Icons.cancel,
        );
    }
  }
}
