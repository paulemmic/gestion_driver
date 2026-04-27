import 'package:flutter/material.dart';
import 'package:gestion_driver/core/theme/app_colors.dart';
import 'package:gestion_driver/core/theme/app_shadows.dart';
import 'package:gestion_driver/features/vehicules/models/vehicule.dart';
import 'package:gestion_driver/features/vehicules/presentation/widgets/vehicule_doc_card.dart';
import 'package:gestion_driver/shared/models/status_tone.dart';
import 'package:gestion_driver/shared/widgets/status_badge.dart';

class VehiculeDetailPage extends StatefulWidget {
  const VehiculeDetailPage({super.key, required this.vehicule});

  final Vehicule vehicule;

  @override
  State<VehiculeDetailPage> createState() => _VehiculeDetailPageState();
}

class _VehiculeDetailPageState extends State<VehiculeDetailPage> {
  late final List<VehiculeDocument> _documents;
  final List<_VehiculeHistoryEntry> _history = [];

  @override
  void initState() {
    super.initState();
    _documents = List<VehiculeDocument>.from(widget.vehicule.documents);
    _seedHistory();
  }

  void _seedHistory() {
    final now = DateTime.now();

    _history.add(
      _VehiculeHistoryEntry(
        title: 'Fiche consultée',
        description:
            'Ouverture des détails pour ${widget.vehicule.name} (${widget.vehicule.plaque}).',
        timestamp: now,
        icon: Icons.visibility_outlined,
      ),
    );

    if (_documents.isNotEmpty) {
      _history.add(
        _VehiculeHistoryEntry(
          title: 'Documents synchronisés',
          description: '${_documents.length} document(s) déjà disponible(s).',
          timestamp: now.subtract(const Duration(minutes: 1)),
          icon: Icons.folder_outlined,
        ),
      );
    }
  }

  Future<void> _openAddActionSheet() async {
    final action = await showModalBottomSheet<_VehiculeAddAction>(
      context: context,
      showDragHandle: true,
      builder: (modalContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.upload_file_outlined),
                title: const Text('Ajouter un document'),
                onTap: () =>
                    Navigator.of(modalContext).pop(_VehiculeAddAction.document),
              ),
              ListTile(
                leading: const Icon(Icons.history_edu_outlined),
                title: const Text('Ajouter un historique'),
                onTap: () =>
                    Navigator.of(modalContext).pop(_VehiculeAddAction.history),
              ),
            ],
          ),
        );
      },
    );

    if (action == null || !mounted) return;

    switch (action) {
      case _VehiculeAddAction.document:
        await _openAddDocumentDialog();
      case _VehiculeAddAction.history:
        await _openAddHistoryDialog();
    }
  }

  Future<void> _openAddDocumentDialog() async {
    final titleCtrl = TextEditingController();
    final subtitleCtrl = TextEditingController();
    final expiryCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    _DocumentStatusOption status = _DocumentStatusOption.valide;

    final draft = await showDialog<_VehiculeDocumentDraft>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            return AlertDialog(
              title: const Text('Ajouter un document'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: titleCtrl,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                          labelText: 'Type de document',
                          hintText: 'Assurance, Carte grise...',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Ce champ est requis';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: subtitleCtrl,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                          labelText: 'Détail',
                          hintText: 'Information complémentaire',
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<_DocumentStatusOption>(
                        initialValue: status,
                        decoration: const InputDecoration(labelText: 'Statut'),
                        items: _DocumentStatusOption.values.map((value) {
                          return DropdownMenuItem<_DocumentStatusOption>(
                            value: value,
                            child: Text(value.label),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setModalState(() => status = value);
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: expiryCtrl,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                          labelText: 'Expiration / Référence',
                          hintText: 'Ex: 12 Mars 2027',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Annuler'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    if (!formKey.currentState!.validate()) return;
                    Navigator.of(dialogContext).pop(
                      _VehiculeDocumentDraft(
                        title: titleCtrl.text.trim(),
                        subtitle: subtitleCtrl.text.trim(),
                        status: status,
                        expiry: expiryCtrl.text.trim(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.check, size: 16),
                  label: const Text('Ajouter'),
                ),
              ],
            );
          },
        );
      },
    );

    titleCtrl.dispose();
    subtitleCtrl.dispose();
    expiryCtrl.dispose();

    if (draft == null) return;

    final document = VehiculeDocument(
      icon: _iconForDocumentTitle(draft.title),
      title: draft.title,
      subtitle: draft.subtitle.isEmpty ? 'Ajout manuel' : draft.subtitle,
      status: draft.status.badgeLabel,
      tone: draft.status.tone,
      extra: draft.expiry.isEmpty ? 'Date non renseignée' : draft.expiry,
      extraTone: draft.status.tone,
    );

    setState(() {
      _documents.insert(0, document);
      _history.insert(
        0,
        _VehiculeHistoryEntry(
          title: 'Document ajouté',
          description: '${draft.title} ajouté au dossier du véhicule.',
          timestamp: DateTime.now(),
          icon: Icons.upload_file_outlined,
        ),
      );
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('Document "${draft.title}" ajouté avec succès.'),
      ),
    );
  }

  Future<void> _openHistorySheet() {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (modalContext) {
        final sortedHistory = [..._history]
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

        return SafeArea(
          child: SizedBox(
            height: MediaQuery.of(modalContext).size.height * 0.72,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Historique du véhicule',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.vehicule.plaque,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (sortedHistory.isEmpty)
                    const Expanded(
                      child: Center(
                        child: Text(
                          'Aucun historique pour le moment.',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.separated(
                        itemCount: sortedHistory.length,
                        itemBuilder: (context, index) {
                          final entry = sortedHistory[index];
                          return _HistoryTile(entry: entry);
                        },
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _openAddHistoryDialog() async {
    final titleCtrl = TextEditingController();
    final descriptionCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    _HistoryEntryType type = _HistoryEntryType.maintenance;

    final draft = await showDialog<_VehiculeHistoryDraft>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            return AlertDialog(
              title: const Text('Ajouter un historique'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<_HistoryEntryType>(
                        initialValue: type,
                        decoration: const InputDecoration(labelText: 'Type'),
                        items: _HistoryEntryType.values.map((value) {
                          return DropdownMenuItem<_HistoryEntryType>(
                            value: value,
                            child: Text(value.label),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setModalState(() => type = value);
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: titleCtrl,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                          labelText: 'Titre',
                          hintText: 'Ex: Vidange effectuée',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Ce champ est requis';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: descriptionCtrl,
                        textCapitalization: TextCapitalization.sentences,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          hintText: 'Détails de l’opération',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Annuler'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    if (!formKey.currentState!.validate()) return;
                    Navigator.of(dialogContext).pop(
                      _VehiculeHistoryDraft(
                        type: type,
                        title: titleCtrl.text.trim(),
                        description: descriptionCtrl.text.trim(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.check, size: 16),
                  label: const Text('Ajouter'),
                ),
              ],
            );
          },
        );
      },
    );

    titleCtrl.dispose();
    descriptionCtrl.dispose();

    if (draft == null) return;

    setState(() {
      _history.insert(
        0,
        _VehiculeHistoryEntry(
          title: draft.title,
          description: draft.description.isEmpty
              ? 'Entrée ajoutée manuellement depuis la fiche véhicule.'
              : draft.description,
          timestamp: DateTime.now(),
          icon: draft.type.icon,
        ),
      );
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('Historique "${draft.title}" ajouté avec succès.'),
      ),
    );
  }

  IconData _iconForDocumentTitle(String title) {
    final normalized = title.toLowerCase();
    if (normalized.contains('assurance')) return Icons.verified_user_outlined;
    if (normalized.contains('grise')) return Icons.description_outlined;
    if (normalized.contains('visite')) return Icons.build_circle_outlined;
    if (normalized.contains('patente')) return Icons.receipt_long_outlined;
    if (normalized.contains('stationnement'))
      return Icons.local_parking_outlined;
    return Icons.insert_drive_file_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final vehicule = widget.vehicule;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.navy,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            const Text(
              'Vehicules',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
              size: 16,
            ),
            Text(
              vehicule.plaque,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
              ),
            ),
          ],
        ),
        actions: [IconButton(icon: const Icon(Icons.search), onPressed: () {})],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vehicule.name,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.bg,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          vehicule.plaque,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: vehicule.badgeTone.foregroundColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        vehicule.badgeLabel,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                          letterSpacing: 0.3,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _openAddActionSheet,
                          icon: const Icon(
                            Icons.add_circle_outline,
                            size: 16,
                            color: AppColors.textPrimary,
                          ),
                          label: const Text('Ajouter'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _openHistorySheet,
                          icon: const Icon(Icons.history, size: 16),
                          label: const Text('Historique'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: InfoPanel(
                      title: 'ÉTAT DE CONFORMITÉ',
                      value: vehicule.complianceStatus,
                      toneColor: vehicule.complianceTone.foregroundColor,
                      backgroundColor: vehicule.complianceTone.backgroundColor,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: InfoPanel(
                      title: 'PROCHAINE EXPIRATION',
                      value: vehicule.nextExpiration,
                      toneColor: vehicule.nextExpirationTone.foregroundColor,
                      backgroundColor:
                          vehicule.nextExpirationTone.backgroundColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'DOCUMENTS OBLIGATOIRES',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (_documents.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Text(
                        'Aucun document pour le moment. Utilisez "Ajouter".',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    )
                  else
                    for (var index = 0; index < _documents.length; index++) ...[
                      VehiculeDocCard(document: _documents[index]),
                      if (index < _documents.length - 1)
                        const SizedBox(height: 10),
                    ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'CARTES OPÉRATIONNELLES',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _FuelCardPanel(card: vehicule.fuelCard),
                  const SizedBox(height: 10),
                  _TollTagPanel(tag: vehicule.tollTag),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

enum _VehiculeAddAction { document, history }

enum _DocumentStatusOption { valide, bientotExpire, expire }

extension _DocumentStatusOptionStyle on _DocumentStatusOption {
  String get label => switch (this) {
    _DocumentStatusOption.valide => 'Valide',
    _DocumentStatusOption.bientotExpire => 'Bientot expire',
    _DocumentStatusOption.expire => 'Expire',
  };

  String get badgeLabel => switch (this) {
    _DocumentStatusOption.valide => 'VALIDE',
    _DocumentStatusOption.bientotExpire => 'BIENTOT EXPIRE',
    _DocumentStatusOption.expire => 'EXPIRE',
  };

  StatusTone get tone => switch (this) {
    _DocumentStatusOption.valide => StatusTone.success,
    _DocumentStatusOption.bientotExpire => StatusTone.warning,
    _DocumentStatusOption.expire => StatusTone.danger,
  };
}

enum _HistoryEntryType { maintenance, controle, incident, administratif }

extension _HistoryEntryTypeStyle on _HistoryEntryType {
  String get label => switch (this) {
    _HistoryEntryType.maintenance => 'Maintenance',
    _HistoryEntryType.controle => 'Contrôle',
    _HistoryEntryType.incident => 'Incident',
    _HistoryEntryType.administratif => 'Administratif',
  };

  IconData get icon => switch (this) {
    _HistoryEntryType.maintenance => Icons.build_circle_outlined,
    _HistoryEntryType.controle => Icons.fact_check_outlined,
    _HistoryEntryType.incident => Icons.report_problem_outlined,
    _HistoryEntryType.administratif => Icons.assignment_outlined,
  };
}

class _VehiculeDocumentDraft {
  const _VehiculeDocumentDraft({
    required this.title,
    required this.subtitle,
    required this.status,
    required this.expiry,
  });

  final String title;
  final String subtitle;
  final _DocumentStatusOption status;
  final String expiry;
}

class _VehiculeHistoryDraft {
  const _VehiculeHistoryDraft({
    required this.type,
    required this.title,
    required this.description,
  });

  final _HistoryEntryType type;
  final String title;
  final String description;
}

class _VehiculeHistoryEntry {
  const _VehiculeHistoryEntry({
    required this.title,
    required this.description,
    required this.timestamp,
    required this.icon,
  });

  final String title;
  final String description;
  final DateTime timestamp;
  final IconData icon;
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.entry});

  final _VehiculeHistoryEntry entry;

  String _formatHistoryDate(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final year = value.year.toString();
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$day/$month/$year - $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.blueLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(entry.icon, size: 18, color: AppColors.blue),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  entry.description,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _formatHistoryDate(entry.timestamp),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class InfoPanel extends StatelessWidget {
  const InfoPanel({
    required this.title,
    required this.value,
    required this.toneColor,
    required this.backgroundColor,
  });

  final String title;
  final String value;
  final Color toneColor;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 9,
              letterSpacing: 0.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: toneColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _FuelCardPanel extends StatelessWidget {
  const _FuelCardPanel({required this.card});

  final FuelCardInfo card;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: const Border(left: BorderSide(color: AppColors.blue, width: 3)),
        boxShadow: AppShadows.subtle,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StatusBadge(label: card.status, tone: card.tone),
              const Spacer(),
              Container(
                width: 42,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.navy,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Center(
                  child: Icon(
                    Icons.credit_card,
                    color: Colors.white60,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Carte Carburant Fleet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            card.subtitle,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'EXPIRATION',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 9,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    card.expiry,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              const Icon(
                Icons.qr_code_2,
                color: AppColors.textSecondary,
                size: 28,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TollTagPanel extends StatelessWidget {
  const _TollTagPanel({required this.tag});

  final TollTagInfo tag;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: const Border(left: BorderSide(color: AppColors.red, width: 3)),
        boxShadow: AppShadows.subtle,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.wifi_tethering,
                color: AppColors.textSecondary,
                size: 18,
              ),
              const Spacer(),
              StatusBadge(label: tag.status, tone: tag.tone),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Badge Télépéage Autoroute',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            tag.subtitle,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.battery_alert, color: AppColors.red, size: 14),
              const SizedBox(width: 4),
              Text(
                tag.issue,
                style: const TextStyle(
                  color: AppColors.red,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.red,
                side: const BorderSide(color: AppColors.red),
              ),
              child: Text(tag.actionLabel),
            ),
          ),
        ],
      ),
    );
  }
}
