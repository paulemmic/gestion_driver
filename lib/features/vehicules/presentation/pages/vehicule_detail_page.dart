import 'package:flutter/material.dart';
import 'package:gestion_driver/core/theme/app_colors.dart';
import 'package:gestion_driver/features/vehicules/models/vehicule.dart';
import 'package:gestion_driver/features/vehicules/models/vehicule_document_draft.dart';
import 'package:gestion_driver/features/vehicules/models/vehicule_historique_draft.dart';
import 'package:gestion_driver/features/vehicules/models/vehicule_historique_entry.dart';
import 'package:gestion_driver/features/vehicules/presentation/widgets/fuel_card_panel.dart';
import 'package:gestion_driver/features/vehicules/presentation/widgets/history_tile.dart';
import 'package:gestion_driver/features/vehicules/presentation/widgets/info_panel.dart';
import 'package:gestion_driver/features/vehicules/presentation/widgets/missing_operational_cards_hint.dart';
import 'package:gestion_driver/features/vehicules/presentation/widgets/toll_tag_panel.dart';
import 'package:gestion_driver/features/vehicules/presentation/widgets/vehicule_doc_card.dart';
import 'package:gestion_driver/features/vehicules/services/document.dart';
import 'package:gestion_driver/shared/models/status_tone.dart';

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
      seedHistory(); // seed only once we have the real count
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
              ListTile(
                leading: const Icon(Icons.history_edu_outlined),
                title: const Text('Ajouter un historique'),
                onTap: () =>
                    Navigator.of(modalContext).pop(VehiculeAddAction.history),
              ),
            ],
          ),
        );
      },
    );

    if (action == null || !mounted) return;

    switch (action) {
      case VehiculeAddAction.document:
        await openAddDocumentDialog();
      case VehiculeAddAction.history:
        await openAddHistoryDialog();
    }
  }

  Future<void> openAddDocumentDialog() async {
    final titleCtrl = TextEditingController();
    final subtitleCtrl = TextEditingController();
    final expiryCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    DocumentStatusOption status = DocumentStatusOption.valide;

    final draft = await showDialog<VehiculeDocumentDraft>(
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
                      DropdownButtonFormField<DocumentStatusOption>(
                        initialValue: status,
                        decoration: const InputDecoration(labelText: 'Statut'),
                        items: DocumentStatusOption.values.map((value) {
                          return DropdownMenuItem<DocumentStatusOption>(
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
                      VehiculeDocumentDraft(
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
      // Roll back optimistic insert
      if (!mounted) return;
      setState(() => documents.removeAt(0));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.red,
          content: Text('Erreur : ${e.message}'),
        ),
      );
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
    final titleCtrl = TextEditingController();
    final descriptionCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    HistoryEntryType type = HistoryEntryType.maintenance;

    final draft = await showDialog<VehiculeHistoriqueDraft>(
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
    final fuelCard = vehicule.fuelCard;
    final tollTag = vehicule.tollTag;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.of(context).pop(documents);
      },
      child: Scaffold(
        backgroundColor: AppColors.bg,
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.navy,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 18),
            onPressed: () => Navigator.of(context).pop(documents),
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
          actions: [
            IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          ],
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
                        value: vehicule.complianceStatus,
                        toneColor: vehicule.complianceTone.foregroundColor,
                        backgroundColor:
                            vehicule.complianceTone.backgroundColor,
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

                    // Loading state
                    if (isLoadingDocuments)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    // Error state
                    else if (loadError != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.red),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: AppColors.red,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                loadError!,
                                style: const TextStyle(
                                  color: AppColors.red,
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
                    // Empty state
                    else if (documents.isEmpty)
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
                    // Document list
                    else
                      for (var i = 0; i < documents.length; i++) ...[
                        VehiculeDocCard(document: documents[i]),
                        if (i < documents.length - 1)
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
                    if (fuelCard == null && tollTag == null)
                      const MissingOperationalCardsHint()
                    else ...[
                      if (fuelCard != null) FuelCardPanel(card: fuelCard),
                      if (fuelCard != null && tollTag != null)
                        const SizedBox(height: 10),
                      if (tollTag != null) TollTagPanel(tag: tollTag),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
