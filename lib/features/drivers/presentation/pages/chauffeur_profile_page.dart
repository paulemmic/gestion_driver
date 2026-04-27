import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gestion_driver/core/theme/app_colors.dart';
import 'package:gestion_driver/core/theme/app_shadows.dart';
import 'package:gestion_driver/features/drivers/models/chauffeur.dart';
import 'package:gestion_driver/features/drivers/presentation/pages/edit_chauffeur_page.dart';
import 'package:gestion_driver/features/drivers/services/add_chauffeur.dart';
import 'package:gestion_driver/shared/models/status_tone.dart';
import 'package:gestion_driver/shared/widgets/fleet_app_bar.dart';
import 'package:gestion_driver/shared/widgets/status_badge.dart';
import 'package:image_picker/image_picker.dart';

class ChauffeurProfilePage extends StatefulWidget {
  const ChauffeurProfilePage({super.key, required this.chauffeur});

  final Chauffeur chauffeur;

  @override
  State<ChauffeurProfilePage> createState() => _ChauffeurProfilePageState();
}

class _ChauffeurProfilePageState extends State<ChauffeurProfilePage> {
  final _service = AddChauffeur();
  late Chauffeur _chauffeur;
  bool isPhotoLoading = false;

  @override
  void initState() {
    super.initState();
    _chauffeur = widget.chauffeur;
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '—';
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Color _statutColor(String? statut) => switch (statut) {
    'Actif' => const Color(0xFF1B8C5A),
    'Inactif' => Colors.grey,
    'En congé' => const Color(0xFFF5A623),
    'Suspendu' => AppColors.red,
    _ => AppColors.navy,
  };

  Future<void> _openEditPage() async {
    final updatedChauffeur = await Navigator.of(context).push<Chauffeur>(
      MaterialPageRoute<Chauffeur>(
        builder: (_) => EditChauffeurPage(chauffeur: _chauffeur),
      ),
    );

    if (updatedChauffeur != null && mounted) {
      setState(() => _chauffeur = updatedChauffeur);
    }
  }

  Future<ImageSource?> _selectPhotoSource() {
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

  Future<void> _pickAndUploadPhoto() async {
    final source = await _selectPhotoSource();
    if (source == null) return;

    final pickedFile = await ImagePicker().pickImage(
      source: source,
      imageQuality: 82,
      maxWidth: 1600,
    );
    if (pickedFile == null) return;

    setState(() => isPhotoLoading = true);
    try {
      final photoUrl = await _service.updateChauffeurPhoto(
        chauffeurId: _chauffeur.id,
        file: File(pickedFile.path),
      );

      if (!mounted) return;
      setState(() => _chauffeur = _chauffeur.copyWith(photoUrl: photoUrl));
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
          backgroundColor: AppColors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isPhotoLoading = false);
      }
    }
  }

  Color _expiryColor(DateTime? date) {
    if (date == null) return AppColors.textSecondary;
    final now = DateTime.now();
    if (date.isBefore(now)) return AppColors.red;
    if (date.isBefore(now.add(const Duration(days: 30)))) {
      return const Color(0xFFF5A623);
    }
    return const Color(0xFF1B8C5A);
  }

  ImageProvider<Object>? get _avatarImage {
    final photoUrl = _chauffeur.photoUrl;
    if (photoUrl == null || photoUrl.trim().isEmpty) {
      return null;
    }
    return NetworkImage(photoUrl.trim());
  }

  @override
  Widget build(BuildContext context) {
    final complianceColor = _chauffeur.conforme
        ? AppColors.green
        : _chauffeur.alert.tone.foregroundColor;

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
                            foregroundImage: _avatarImage,
                            child: _avatarImage == null
                                ? Text(
                                    _chauffeur.initials,
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.navy,
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
                                color: AppColors.navy,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'ID: ${_chauffeur.id}',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _chauffeur.name,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (_chauffeur.statut != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _statutColor(
                                    _chauffeur.statut,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: _statutColor(
                                      _chauffeur.statut,
                                    ).withOpacity(0.4),
                                  ),
                                ),
                                child: Text(
                                  _chauffeur.statut!,
                                  style: TextStyle(
                                    color: _statutColor(_chauffeur.statut),
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
                      color: complianceColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: complianceColor.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _chauffeur.conforme
                              ? Icons.check_circle
                              : _chauffeur.alert.icon,
                          color: complianceColor,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _chauffeur.conforme
                              ? 'Tous conformes'
                              : _chauffeur.alert.label,
                          style: TextStyle(
                            color: complianceColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        if (!_chauffeur.conforme) ...[
                          const Spacer(),
                          Text(
                            _chauffeur.alert.value,
                            style: TextStyle(
                              color: complianceColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: isPhotoLoading ? null : _openEditPage,
                          icon: const Icon(Icons.edit_outlined, size: 16),
                          label: const Text('Modifier'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: isPhotoLoading
                              ? null
                              : _pickAndUploadPhoto,
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
            _Section(
              title: 'INFORMATIONS PERSONNELLES',
              child: Column(
                children: [
                  _InfoRow(
                    icon: Icons.phone_outlined,
                    label: 'Téléphone',
                    value: _chauffeur.telephone ?? '—',
                  ),
                  _Divider(),
                  _InfoRow(
                    icon: Icons.badge_outlined,
                    label: 'N° CIN',
                    value: _chauffeur.numeroCin ?? '—',
                  ),
                  _Divider(),
                  _InfoRow(
                    icon: Icons.cake_outlined,
                    label: 'Date de naissance',
                    value: _formatDate(_chauffeur.dateNaissance),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _Section(
              title: 'PERMIS & CONFORMITÉ',
              child: Column(
                children: [
                  _InfoRow(
                    icon: Icons.credit_card_outlined,
                    label: 'N° Permis',
                    value: _chauffeur.numeroPermis ?? '—',
                  ),
                  _Divider(),
                  _InfoRow(
                    icon: Icons.category_outlined,
                    label: 'Catégorie',
                    value: _chauffeur.categoriePermis ?? '—',
                  ),
                  _Divider(),
                  _InfoRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'Expiration permis',
                    value: _formatDate(_chauffeur.dateExpirationPermis),
                    valueColor: _expiryColor(_chauffeur.dateExpirationPermis),
                  ),
                  _Divider(),
                  _InfoRow(
                    icon: Icons.medical_services_outlined,
                    label: 'Visite médicale',
                    value: _formatDate(_chauffeur.dateExpirationVisite),
                    valueColor: _expiryColor(_chauffeur.dateExpirationVisite),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (_chauffeur.metrics.isNotEmpty) ...[
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.blueLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 2.5,
                  children: [
                    for (final metric in _chauffeur.metrics)
                      ChauffeurMetricBlock(metric: metric),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            if (_chauffeur.documents.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Text(
                      'Documents de conformité',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${_chauffeur.documents.length} document(s)',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
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
                    for (var i = 0; i < _chauffeur.documents.length; i++) ...[
                      ChauffeurDocumentTile(document: _chauffeur.documents[i]),
                      if (i < _chauffeur.documents.length - 1)
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

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 3,
                height: 14,
                color: AppColors.navy,
                margin: const EdgeInsets.only(right: 8),
              ),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: AppShadows.subtle,
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.navy, size: 18),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, indent: 46, color: Color(0xFFEEF1F7));
  }
}

// ─── Classes existantes inchangées ───────────────────────────────────────────

class ChauffeurMetricBlock extends StatelessWidget {
  const ChauffeurMetricBlock({required this.metric});
  final ChauffeurMetric metric;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          metric.label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 9,
            letterSpacing: 0.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          metric.value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.navy,
          ),
        ),
      ],
    );
  }
}

class ChauffeurDocumentTile extends StatelessWidget {
  const ChauffeurDocumentTile({required this.document});
  final ChauffeurDocument document;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border(
          left: BorderSide(color: document.tone.foregroundColor, width: 3),
        ),
        boxShadow: AppShadows.subtle,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.bg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(document.icon, color: AppColors.navy, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  document.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  document.expiry,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          StatusBadge(label: document.status, tone: document.tone),
        ],
      ),
    );
  }
}
