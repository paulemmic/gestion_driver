import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gestion_driver/core/constants.dart';
import 'package:gestion_driver/core/theme/app_colors.dart';
import 'package:gestion_driver/features/drivers/models/chauffeur.dart';
import 'package:gestion_driver/features/drivers/presentation/pages/edit_chauffeur_page.dart';
import 'package:gestion_driver/features/drivers/presentation/widgets/chauffeur_document_title.dart';
import 'package:gestion_driver/features/drivers/presentation/widgets/chauffeur_metric_block.dart';
import 'package:gestion_driver/features/drivers/presentation/widgets/info_row.dart';
import 'package:gestion_driver/features/drivers/presentation/widgets/section.dart';
import 'package:gestion_driver/features/drivers/services/add_chauffeur.dart';
import 'package:gestion_driver/shared/utils/expire_utils.dart';
import 'package:gestion_driver/shared/widgets/fleet_app_bar.dart';
import 'package:image_picker/image_picker.dart';

class ChauffeurProfilePage extends StatefulWidget {
  const ChauffeurProfilePage({super.key, required this.chauffeur});

  final Chauffeur chauffeur;

  @override
  State<ChauffeurProfilePage> createState() => _ChauffeurProfilePageState();
}

class _ChauffeurProfilePageState extends State<ChauffeurProfilePage> {
  final service = AddChauffeur();
  late Chauffeur chauffeur;
  bool isPhotoLoading = false;

  @override
  void initState() {
    super.initState();
    chauffeur = widget.chauffeur;
  }

  Color statutColor(String? statut) => switch (statut) {
    'Actif' => AppColors.primary,
    'Inactif' => AppColors.secondary,
    'En congé' => AppColors.danger,
    'Suspendu' => AppColors.accent,
    _ => AppColors.grey,
  };

  Future<void> openEditPage() async {
    final updatedChauffeur = await Navigator.of(context).push<Chauffeur>(
      MaterialPageRoute<Chauffeur>(
        builder: (_) => EditChauffeurPage(chauffeur: chauffeur),
      ),
    );

    if (updatedChauffeur != null && mounted) {
      setState(() => chauffeur = updatedChauffeur);
    }
  }

  Future<ImageSource?> selectPhotoSource() {
    return showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      builder: (modalContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Prendre une photo'),
                onTap: () => Navigator.of(modalContext).pop(ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Choisir depuis la galerie'),
                onTap: () =>
                    Navigator.of(modalContext).pop(ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> pickAndUploadPhoto() async {
    final source = await selectPhotoSource();
    if (source == null) return;

    final pickedFile = await ImagePicker().pickImage(
      source: source,
      imageQuality: 82,
      maxWidth: 1600,
    );
    if (pickedFile == null) return;

    setState(() => isPhotoLoading = true);
    try {
      final photoUrl = await service.updateChauffeurPhoto(
        chauffeurId: chauffeur.id,
        file: File(pickedFile.path),
      );

      if (!mounted) return;
      setState(() => chauffeur = chauffeur.copyWith(photoUrl: photoUrl));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Photo chauffeur mise à jour.'),
          backgroundColor: Color(0xFF1B8C5A),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on Exception catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppColors.accent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isPhotoLoading = false);
      }
    }
  }

  Color expiryColor(DateTime? date) {
    if (date == null) return AppColors.secondary;
    final now = DateTime.now();
    if (date.isBefore(now)) return AppColors.accent;
    if (date.isBefore(now.add(const Duration(days: 30)))) {
      return const Color(0xFFF5A623);
    }
    return const Color(0xFF1B8C5A);
  }

  ImageProvider<Object>? get avatarImage {
    final photoUrl = chauffeur.photoUrl;
    if (photoUrl == null || photoUrl.trim().isEmpty) {
      return null;
    }
    return NetworkImage(photoUrl.trim());
  }

  @override
  Widget build(BuildContext context) {
    final dates = [
      chauffeur.dateExpirationPermis,
      chauffeur.dateExpirationVisite,
    ].whereType<DateTime>().toList()..sort((a, b) => a.compareTo(b));

    final nearestDate = dates.isNotEmpty ? dates.first : null;
    final expire = getExpiryInfo(nearestDate);
    final complianceColor = expire.color;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: const FleetAppBar(showBack: true, title: 'Profil Chauffeur'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: AppColors.bg,
                            foregroundImage: avatarImage,
                            child: avatarImage == null
                                ? Text(
                                    chauffeur.initials,
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 2,
                            right: 2,
                            child: Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: complianceColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'ID: ${chauffeur.id}',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              chauffeur.name,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (chauffeur.statut != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: statutColor(
                                    chauffeur.statut,
                                  ).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: statutColor(
                                      chauffeur.statut,
                                    ).withValues(alpha: 0.4),
                                  ),
                                ),
                                child: Text(
                                  chauffeur.statut!,
                                  style: TextStyle(
                                    color: statutColor(chauffeur.statut),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: complianceColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: complianceColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(expire.icon, color: complianceColor, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          expire.label,
                          style: TextStyle(
                            color: complianceColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),

                        const Spacer(),
                        Text(
                          chauffeur.alert.value,
                          style: TextStyle(
                            color: complianceColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: isPhotoLoading ? null : openEditPage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.white,
                          ),
                          icon: const Icon(Icons.edit_outlined, size: 16),
                          label: const Text('Modifier'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: isPhotoLoading ? null : pickAndUploadPhoto,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.grey,
                          ),
                          icon: isPhotoLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.camera_alt_outlined, size: 16),
                          label: Text(isPhotoLoading ? 'Upload...' : 'Photo'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Section(
              title: 'INFORMATIONS PERSONNELLES',
              child: Column(
                children: [
                  InfoRow(
                    icon: Icons.phone_outlined,
                    label: 'Téléphone',
                    value: chauffeur.telephone ?? '—',
                  ),
                  Divider(),
                  InfoRow(
                    icon: Icons.badge_outlined,
                    label: 'N° CIN',
                    value: chauffeur.numeroCin ?? '—',
                  ),
                  Divider(),
                  InfoRow(
                    icon: Icons.cake_outlined,
                    label: 'Date de naissance',
                    value: formatDate(chauffeur.dateNaissance),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Section(
              title: 'PERMIS & CONFORMITÉ',
              child: Column(
                children: [
                  InfoRow(
                    icon: Icons.credit_card_outlined,
                    label: 'N° Permis',
                    value: chauffeur.numeroPermis ?? '—',
                  ),
                  Divider(),
                  InfoRow(
                    icon: Icons.category_outlined,
                    label: 'Catégorie',
                    value: chauffeur.categoriePermis ?? '—',
                  ),
                  Divider(),
                  InfoRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'Expiration permis',
                    value: formatDate(chauffeur.dateExpirationPermis),
                    valueColor: expiryColor(chauffeur.dateExpirationPermis),
                  ),
                  // _Divider(),
                  // _InfoRow(
                  //   icon: Icons.medical_services_outlined,
                  //   label: 'Visite médicale',
                  //   value: formatDate(_chauffeur.dateExpirationVisite),
                  //   valueColor: _expiryColor(_chauffeur.dateExpirationVisite),
                  // ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (chauffeur.metrics.isNotEmpty) ...[
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.info,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 2.5,
                  children: [
                    for (final metric in chauffeur.metrics)
                      ChauffeurMetricBlock(metric: metric),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            if (chauffeur.documents.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Text(
                      'Documents de conformité',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${chauffeur.documents.length} document(s)',
                      style: const TextStyle(
                        color: AppColors.secondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    for (var i = 0; i < chauffeur.documents.length; i++) ...[
                      ChauffeurDocumentTile(document: chauffeur.documents[i]),
                      if (i < chauffeur.documents.length - 1)
                        const SizedBox(height: 10),
                    ],
                  ],
                ),
              ),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
