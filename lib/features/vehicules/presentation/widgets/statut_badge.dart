import 'package:flutter/material.dart';
import 'package:gestion_driver/features/vehicules/presentation/pages/add_vehicule_page.dart';
import 'package:gestion_driver/features/vehicules/presentation/widgets/status_mapper.dart';
import 'package:gestion_driver/shared/models/status_tone.dart';

class StatusBadge extends StatelessWidget {
  final VehiculeStatus status;

  const StatusBadge({
    super.key,
    required this.status,
    required String label,
    required StatusTone tone,
  });

  @override
  Widget build(BuildContext context) {
    final config = StatusMapper.fromStatus(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: config.bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(config.icon, size: 14, color: config.color),
          const SizedBox(width: 6),
          Text(
            config.label,
            style: TextStyle(
              color: config.color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
