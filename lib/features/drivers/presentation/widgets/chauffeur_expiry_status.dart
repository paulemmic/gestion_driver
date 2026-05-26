import 'package:gestion_driver/features/drivers/models/chauffeur.dart';

enum ChauffeurExpiryStatus { ok, expiringSoon, expired }

ChauffeurExpiryStatus chauffeurExpiryStatus(Chauffeur c) {
  final date = c.dateExpirationPermis;
  if (date == null) return ChauffeurExpiryStatus.ok;
  final now = DateTime.now();
  if (date.isBefore(now)) return ChauffeurExpiryStatus.expired;
  if (date.isBefore(now.add(const Duration(days: 30)))) {
    return ChauffeurExpiryStatus.expiringSoon;
  }
  return ChauffeurExpiryStatus.ok;
}
