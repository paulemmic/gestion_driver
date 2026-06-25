import 'package:gestion_driver/features/vehicules/models/vehicule_document_draft.dart';

DocumentStatusOption statusFromExpiryString(String expiryStr) {
  if (expiryStr.trim().isEmpty) return DocumentStatusOption.valide;

  final parts = expiryStr.trim().split('/');
  if (parts.length != 3) return DocumentStatusOption.valide;

  final day = int.tryParse(parts[0]);
  final month = int.tryParse(parts[1]);
  final year = int.tryParse(parts[2]);

  if (day == null || month == null || year == null) {
    return DocumentStatusOption.valide;
  }

  try {
    final expiry = DateTime(year, month, day);
    final now = DateTime.now();
    final e = DateTime(expiry.year, expiry.month, expiry.day);
    final n = DateTime(now.year, now.month, now.day);
    final daysLeft = e.difference(n).inDays;

    if (daysLeft < 0) return DocumentStatusOption.expire;
    if (daysLeft < 30) return DocumentStatusOption.bientotExpire;
    return DocumentStatusOption.valide;
  } catch (_) {
    return DocumentStatusOption.valide;
  }
}

DateTime? parseDate(String raw) {
  final parts = raw.trim().split('/');
  if (parts.length != 3) return null;
  final day = int.tryParse(parts[0]);
  final month = int.tryParse(parts[1]);
  final year = int.tryParse(parts[2]);
  if (day == null || month == null || year == null) return null;
  try {
    final date = DateTime(year, month, day);
    return date.day == day && date.month == month && date.year == year
        ? date
        : null;
  } catch (_) {
    return null;
  }
}

DocumentStatusOption statusFromDate(DateTime? dateExpiration) {
  if (dateExpiration == null) return DocumentStatusOption.valide;
  final now = DateTime.now();
  final e = DateTime(
    dateExpiration.year,
    dateExpiration.month,
    dateExpiration.day,
  );
  final n = DateTime(now.year, now.month, now.day);
  final daysLeft = e.difference(n).inDays;
  if (daysLeft < 0) return DocumentStatusOption.expire;
  if (daysLeft < 30) return DocumentStatusOption.bientotExpire;
  return DocumentStatusOption.valide;
}

int? joursRestantsFromDate(DateTime? dateExpiration) {
  if (dateExpiration == null) return null;
  final now = DateTime.now();
  final e = DateTime(
    dateExpiration.year,
    dateExpiration.month,
    dateExpiration.day,
  );
  final n = DateTime(now.year, now.month, now.day);
  return e.difference(n).inDays;
}
