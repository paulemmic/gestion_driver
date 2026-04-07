import 'package:gestion_driver/shared/models/status_tone.dart';

class DashboardBannerStat {
  const DashboardBannerStat({
    required this.label,
    required this.value,
    this.tone = StatusTone.neutral,
  });

  final String label;
  final String value;
  final StatusTone tone;
}
