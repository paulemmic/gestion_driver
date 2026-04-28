import 'package:gestion_driver/shared/models/status_tone.dart';

class VehiculeDocumentDraft {
  const VehiculeDocumentDraft({
    required this.title,
    required this.subtitle,
    required this.status,
    required this.expiry,
  });

  final String title;
  final String subtitle;
  final DocumentStatusOption status;
  final String expiry;
}

enum VehiculeAddAction { document, history }

enum DocumentStatusOption { valide, bientotExpire, expire }

extension DocumentStatusOptionStyle on DocumentStatusOption {
  String get label => switch (this) {
    DocumentStatusOption.valide => 'Valide',
    DocumentStatusOption.bientotExpire => 'Bientot expire',
    DocumentStatusOption.expire => 'Expire',
  };

  String get badgeLabel => switch (this) {
    DocumentStatusOption.valide => 'VALIDE',
    DocumentStatusOption.bientotExpire => 'BIENTOT EXPIRE',
    DocumentStatusOption.expire => 'EXPIRE',
  };

  StatusTone get tone => switch (this) {
    DocumentStatusOption.valide => StatusTone.success,
    DocumentStatusOption.bientotExpire => StatusTone.warning,
    DocumentStatusOption.expire => StatusTone.danger,
  };
}
