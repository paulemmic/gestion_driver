import 'package:flutter/material.dart';
import 'package:gestion_driver/core/theme/app_colors.dart';
import 'package:gestion_driver/features/vehicules/models/vehicule.dart';
import 'package:gestion_driver/features/vehicules/models/vehicule_document_draft.dart';
import 'package:gestion_driver/features/vehicules/models/vehicule_historique_draft.dart';
import 'package:gestion_driver/features/vehicules/models/vehicule_historique_entry.dart';
import 'package:gestion_driver/features/vehicules/presentation/widgets/history_tile.dart';
import 'package:gestion_driver/features/vehicules/presentation/widgets/info_panel.dart';
import 'package:gestion_driver/features/vehicules/presentation/widgets/vehicule_doc_card.dart';
import 'package:gestion_driver/features/vehicules/presentation/widgets/vidange_card.dart';
import 'package:gestion_driver/features/vehicules/services/document.dart';
import 'package:gestion_driver/shared/models/status_tone.dart';

enum DocumentTypeOption {
  assurance,
  carteGrise,
  visiteTechnique,
  carteStationnement,
  patente,
}

extension DocumentTypeOptionExt on DocumentTypeOption {
  String get label => switch (this) {
    DocumentTypeOption.assurance => 'Assurance',
    DocumentTypeOption.carteGrise => 'Carte grise',
    DocumentTypeOption.visiteTechnique => 'Visite technique',
    DocumentTypeOption.carteStationnement => 'Carte de stationnement',
    DocumentTypeOption.patente => 'Patente',
  };

  IconData get icon => switch (this) {
    DocumentTypeOption.assurance => Icons.verified_user_outlined,
    DocumentTypeOption.carteGrise => Icons.description_outlined,
    DocumentTypeOption.visiteTechnique => Icons.build_circle_outlined,
    DocumentTypeOption.carteStationnement => Icons.local_parking_outlined,
    DocumentTypeOption.patente => Icons.receipt_long_outlined,
  };
}

DocumentStatusOption _statusFromExpiryString(String expiryStr) {
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
    final daysLeft = expiry.difference(now).inDays;

    if (daysLeft < 0) return DocumentStatusOption.expire;
    if (daysLeft <= 30) return DocumentStatusOption.bientotExpire;
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

enum VehiculeAddAction { document /* history */ }

class _ComplianceSummary {
  const _ComplianceSummary({
    required this.complianceStatus,
    required this.complianceTone,
    required this.nextExpiration,
    required this.nextExpirationTone,
  });

  final String complianceStatus;
  final StatusTone complianceTone;
  final String nextExpiration;
  final StatusTone nextExpirationTone;
}

class VehiculeDetailPage extends StatefulWidget {
  const VehiculeDetailPage({super.key, required this.vehicule});

  final Vehicule vehicule;

  @override
  State<VehiculeDetailPage> createState() => _VehiculeDetailPageState();
}

class _VehiculeDetailPageState extends State<VehiculeDetailPage> {
  final DocumentService documentService = DocumentService();

  List<VehiculeDocument> documents = [];
  bool isLoadingDocuments = true;
  String? loadError;

  final List<VehiculeHistoriqueEntry> history = [];

  @override
  void initState() {
    super.initState();
    loadDocuments();
  }

  Future<void> loadDocuments() async {
    try {
      final docs = await documentService.fetchDocuments(widget.vehicule.id!);
      if (!mounted) return;
      setState(() {
        documents = docs;
        isLoadingDocuments = false;
      });
      seedHistory();
    } on DocumentServiceException catch (e) {
      if (!mounted) return;
      setState(() {
        loadError = e.message;
        isLoadingDocuments = false;
      });
    }
  }

  void seedHistory() {
    final now = DateTime.now();

    history.add(
      VehiculeHistoriqueEntry(
        title: 'Fiche consultée',
        description:
            'Ouverture des détails pour ${widget.vehicule.name} (${widget.vehicule.plaque}).',
        timestamp: now,
        icon: Icons.visibility_outlined,
      ),
    );

    if (documents.isNotEmpty) {
      history.add(
        VehiculeHistoriqueEntry(
          title: 'Documents synchronisés',
          description: '${documents.length} document(s) déjà disponible(s).',
          timestamp: now.subtract(const Duration(minutes: 1)),
          icon: Icons.folder_outlined,
        ),
      );
    }
  }

  Future<void> _openAddActionSheet() async {
    final action = await showModalBottomSheet<VehiculeAddAction>(
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
                    Navigator.of(modalContext).pop(VehiculeAddAction.document),
              ),
              // ListTile(
              //   leading: const Icon(Icons.history_edu_outlined),
              //   title: const Text('Ajouter un historique'),
              //   onTap: () =>
              //       Navigator.of(modalContext).pop(VehiculeAddAction.history),
              // ),
            ],
          ),
        );
      },
    );

    if (action == null || !mounted) return;

    switch (action) {
      case VehiculeAddAction.document:
        await openDocumentDialog();
      // case VehiculeAddAction.history:
      //   await openAddHistoryDialog();
    }
  }

  Future<void> openDocumentDialog({int? editIndex}) async {
    final isEditing = editIndex != null;
    final existing = isEditing ? documents[editIndex] : null;

    // Pre-fill when editing
    DocumentTypeOption docType = existing != null
        ? _typeFromTitle(existing.title)
        : DocumentTypeOption.assurance;

    final subtitleCtrl = TextEditingController(text: existing?.subtitle ?? '');
    final expiryCtrl = TextEditingController(text: existing?.extra ?? '');
    final formKey = GlobalKey<FormState>();

    final draft = await showDialog<VehiculeDocumentDraft>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            return AlertDialog(
              backgroundColor: AppColors.white,
              title: Text(
                isEditing ? 'Modifier le document' : 'Ajouter un document',
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ── Type de document (menu déroulant) ──────────────
                      DropdownButtonFormField<DocumentTypeOption>(
                        value: docType,
                        decoration: const InputDecoration(
                          labelText: 'Type de document',
                        ),
                        items: DocumentTypeOption.values.map((value) {
                          return DropdownMenuItem<DocumentTypeOption>(
                            value: value,
                            child: Row(
                              children: [
                                Icon(
                                  value.icon,
                                  size: 18,
                                  color: AppColors.secondary,
                                ),
                                const SizedBox(width: 8),
                                Text(value.label),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setModalState(() => docType = value);
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

                      TextFormField(
                        controller: expiryCtrl,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Date d\'expiration',
                          hintText: 'jj/mm/aaaa',
                          prefixIcon: const Icon(
                            Icons.calendar_today_outlined,
                            size: 18,
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.calendar_today_outlined),
                            onPressed: () async {
                              final selectedDate = await showDatePicker(
                                context: modalContext,
                                initialDate:
                                    parseDate(expiryCtrl.text) ??
                                    DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: ColorScheme.light(
                                        primary: AppColors.primary,
                                        onPrimary: Colors.white,
                                        surface: Colors.white,
                                        onSurface: AppColors.primary,
                                      ),
                                      dialogBackgroundColor: AppColors.white,
                                    ),
                                    child: child!,
                                  );
                                },
                              );

                              if (selectedDate != null) {
                                final formatted =
                                    '${selectedDate.day.toString().padLeft(2, '0')}/'
                                    '${selectedDate.month.toString().padLeft(2, '0')}/'
                                    '${selectedDate.year}';
                                expiryCtrl.text = formatted;
                                setModalState(() {});
                              }
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'La date est requise';
                          }
                          final parts = value.trim().split('/');
                          if (parts.length != 3) {
                            return 'Format attendu : jj/mm/aaaa';
                          }

                          final day = int.parse(parts[0]);
                          final month = int.parse(parts[1]);
                          final year = int.parse(parts[2]);

                          try {
                            final date = DateTime(year, month, day);

                            if (date.day != day ||
                                date.month != month ||
                                date.year != year) {
                              return 'Date invalide';
                            }
                            return null;
                          } catch (e) {
                            return 'Format invalide';
                          }
                        },
                      ),

                      ValueListenableBuilder<TextEditingValue>(
                        valueListenable: expiryCtrl,
                        builder: (_, val, __) {
                          if (val.text.length < 10) {
                            return const SizedBox.shrink();
                          }
                          final deduced = _statusFromExpiryString(val.text);
                          return Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: deduced.tone.foregroundColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Statut déduit : ${deduced.badgeLabel}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: deduced.tone.foregroundColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
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
                      VehiculeDocumentDraft(
                        title: docType.label,
                        subtitle: subtitleCtrl.text.trim(),
                        status: _statusFromExpiryString(expiryCtrl.text),
                        expiry: expiryCtrl.text.trim(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.check, size: 16),
                  label: Text(isEditing ? 'Enregistrer' : 'Ajouter'),
                ),
              ],
            );
          },
        );
      },
    );

    if (draft == null) return;

    final document = VehiculeDocument(
      icon: _typeFromTitle(draft.title).icon,
      title: draft.title,
      subtitle: draft.subtitle.isEmpty ? 'Ajout manuel' : draft.subtitle,
      status: draft.status.badgeLabel,
      tone: draft.status.tone,
      extra: draft.expiry,
      extraTone: draft.status.tone,
    );

    if (isEditing) {
      setState(() {
        documents[editIndex] = document;
        history.insert(
          0,
          VehiculeHistoriqueEntry(
            title: 'Document modifié',
            description: '${draft.title} mis à jour dans le dossier.',
            timestamp: DateTime.now(),
            icon: Icons.edit_outlined,
          ),
        );
      });

      try {
        await documentService.updateDocument(
          vehiculeId: widget.vehicule.id!,
          document: document,
          firestoreId: "",
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('Document "${draft.title}" mis à jour avec succès.'),
          ),
        );
      } on DocumentServiceException catch (e) {
        if (!mounted) return;
        // Roll back optimistic update
        setState(() => documents[editIndex] = existing!);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.accent,
            content: Text('Erreur : ${e.message}'),
          ),
        );
      }
    } else {
      setState(() {
        documents.insert(0, document);
        history.insert(
          0,
          VehiculeHistoriqueEntry(
            title: 'Document ajouté',
            description: '${draft.title} ajouté au dossier du véhicule.',
            timestamp: DateTime.now(),
            icon: Icons.upload_file_outlined,
          ),
        );
      });

      try {
        await documentService.addDocument(
          vehiculeId: widget.vehicule.id!,
          document: document,
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('Document "${draft.title}" ajouté avec succès.'),
          ),
        );
      } on DocumentServiceException catch (e) {
        if (!mounted) return;
        setState(() => documents.removeAt(0));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.accent,
            content: Text('Erreur : ${e.message}'),
          ),
        );
      }
    }
  }

  Future<void> openHistorySheet() {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (modalContext) {
        final sortedHistory = [...history]
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
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.vehicule.plaque,
                    style: const TextStyle(
                      color: AppColors.secondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (sortedHistory.isEmpty)
                    const Expanded(
                      child: Center(
                        child: Text(
                          'Aucun historique pour le moment.',
                          style: TextStyle(color: AppColors.secondary),
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.separated(
                        itemCount: sortedHistory.length,
                        itemBuilder: (context, index) =>
                            HistoryTile(entry: sortedHistory[index]),
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

  Future<void> openAddHistoryDialog() async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    HistoryEntryType type = HistoryEntryType.maintenance;

    final draft = await showDialog<VehiculeHistoriqueDraft>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            return AlertDialog(
              backgroundColor: AppColors.white,
              title: const Text('Ajouter un historique'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<HistoryEntryType>(
                        initialValue: type,
                        decoration: const InputDecoration(labelText: 'Type'),
                        items: HistoryEntryType.values.map((value) {
                          return DropdownMenuItem<HistoryEntryType>(
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
                        controller: titleController,
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
                        controller: descriptionController,
                        textCapitalization: TextCapitalization.sentences,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          hintText: 'Détails de l\'opération',
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
                      VehiculeHistoriqueDraft(
                        type: type,
                        title: titleController.text.trim(),
                        description: descriptionController.text.trim(),
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

    if (draft == null) return;

    setState(() {
      history.insert(
        0,
        VehiculeHistoriqueEntry(
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

  DocumentTypeOption _typeFromTitle(String title) {
    final normalized = title.toLowerCase();
    if (normalized.contains('assurance')) return DocumentTypeOption.assurance;
    if (normalized.contains('grise')) return DocumentTypeOption.carteGrise;
    if (normalized.contains('visite'))
      return DocumentTypeOption.visiteTechnique;
    if (normalized.contains('stationnement')) {
      return DocumentTypeOption.carteStationnement;
    }
    if (normalized.contains('patente')) return DocumentTypeOption.patente;
    return DocumentTypeOption.assurance;
  }

  _ComplianceSummary _buildComplianceSummary() {
    if (isLoadingDocuments || documents.isEmpty) {
      return _ComplianceSummary(
        complianceStatus: '',
        complianceTone: DocumentStatusOption.valide.tone,
        nextExpiration: '',
        nextExpirationTone: DocumentStatusOption.valide.tone,
      );
    }

    final now = DateTime.now();
    bool hasExpired = false;
    bool hasSoon = false;
    DateTime? soonest;

    for (final doc in documents) {
      final date = parseDate(doc.extra);
      if (date == null) continue;

      final days = date.difference(now).inDays;
      if (days < 0) {
        hasExpired = true;
      } else if (days <= 30) {
        hasSoon = true;
      }

      if (date.isAfter(now) && (soonest == null || date.isBefore(soonest))) {
        soonest = date;
      }
    }

    final complianceStatus = switch ((hasExpired, hasSoon)) {
      (true, _) => 'Non conforme',
      (false, true) => 'Attention',
      _ => 'Conforme',
    };

    final complianceTone = switch ((hasExpired, hasSoon)) {
      (true, _) => DocumentStatusOption.expire.tone,
      (false, true) => DocumentStatusOption.bientotExpire.tone,
      _ => DocumentStatusOption.valide.tone,
    };

    final nextExpiration = soonest == null
        ? ''
        : '${soonest.day.toString().padLeft(2, '0')}/'
              '${soonest.month.toString().padLeft(2, '0')}/'
              '${soonest.year}';

    final nextExpirationTone = soonest == null
        ? DocumentStatusOption.valide.tone
        : soonest.difference(now).inDays <= 30
        ? DocumentStatusOption.bientotExpire.tone
        : DocumentStatusOption.valide.tone;

    return _ComplianceSummary(
      complianceStatus: complianceStatus,
      complianceTone: complianceTone,
      nextExpiration: nextExpiration,
      nextExpirationTone: nextExpirationTone,
    );
  }

  @override
  Widget build(BuildContext context) {
    final vehicule = widget.vehicule;
    final complianceSummary = _buildComplianceSummary();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.of(context).pop(documents);
      },
      child: Scaffold(
        backgroundColor: AppColors.bg,
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.primary,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 18),
            onPressed: () => Navigator.of(context).pop(documents),
          ),
          titleSpacing: 0,
          title: Row(
            children: [
              const Text(
                'Vehicules',
                style: TextStyle(color: AppColors.secondary, fontSize: 13),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.secondary,
                size: 16,
              ),
              Text(
                vehicule.plaque,
                style: const TextStyle(color: AppColors.primary, fontSize: 13),
              ),
            ],
          ),
          // actions: [
          //   IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          // ],
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
                        color: AppColors.primary,
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
                            border: Border.all(color: AppColors.primary),
                          ),
                          child: Text(
                            vehicule.plaque,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
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
                            color: AppColors.secondary,
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
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.white,
                            ),
                            onPressed: _openAddActionSheet,
                            icon: const Icon(
                              Icons.add_circle_outline,
                              size: 16,
                              color: AppColors.primary,
                            ),
                            label: const Text('Ajouter'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.grey,
                            ),
                            onPressed: openHistorySheet,
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
                        value: complianceSummary.complianceStatus,
                        toneColor:
                            complianceSummary.complianceTone.foregroundColor,
                        backgroundColor:
                            complianceSummary.complianceTone.backgroundColor,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: InfoPanel(
                        title: 'PROCHAINE EXPIRATION',
                        value: complianceSummary.nextExpiration,
                        toneColor: complianceSummary
                            .nextExpirationTone
                            .foregroundColor,
                        backgroundColor: complianceSummary
                            .nextExpirationTone
                            .backgroundColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              if (vehicule.kilometrage != null &&
                  vehicule.kilometrage! > 0) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ENTRETIEN',
                        style: TextStyle(
                          color: AppColors.secondary,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 10),
                      VidangeCard(kilometrage: vehicule.kilometrage!),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'DOCUMENTS OBLIGATOIRES',
                      style: TextStyle(
                        color: AppColors.secondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (isLoadingDocuments)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (loadError != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.accent),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: AppColors.accent,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                loadError!,
                                style: const TextStyle(
                                  color: AppColors.accent,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  loadError = null;
                                  isLoadingDocuments = true;
                                });
                                loadDocuments();
                              },
                              child: const Text('Réessayer'),
                            ),
                          ],
                        ),
                      )
                    else if (documents.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.grey),
                        ),
                        child: const Text(
                          'Aucun document pour le moment. Utilisez "Ajouter".',
                          style: TextStyle(
                            color: AppColors.secondary,
                            fontSize: 12,
                          ),
                        ),
                      )
                    else
                      for (var i = 0; i < documents.length; i++) ...[
                        // ── Card + bouton modifier ────────────────────
                        GestureDetector(
                          onTap: () => openDocumentDialog(editIndex: i),
                          child: Stack(
                            children: [VehiculeDocCard(document: documents[i])],
                          ),
                        ),
                        if (i < documents.length - 1)
                          const SizedBox(height: 10),
                      ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
