import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gestion_driver/core/constants.dart';
import 'package:gestion_driver/core/theme/app_colors.dart';
import 'package:gestion_driver/features/drivers/models/chauffeur.dart';
import 'package:gestion_driver/features/drivers/presentation/widgets/date_field.dart';
import 'package:gestion_driver/features/drivers/presentation/widgets/dropdown_field.dart';
import 'package:gestion_driver/features/drivers/presentation/widgets/section_label.dart';
import 'package:gestion_driver/features/drivers/presentation/widgets/textform_field.dart';
import 'package:gestion_driver/features/drivers/services/add_chauffeur.dart';
import 'package:gestion_driver/shared/models/status_tone.dart';
import 'package:gestion_driver/shared/widgets/fleet_app_bar.dart';
import 'package:image_picker/image_picker.dart';

class EditChauffeurPage extends StatefulWidget {
  const EditChauffeurPage({super.key, required this.chauffeur});

  final Chauffeur chauffeur;

  @override
  State<EditChauffeurPage> createState() => _EditChauffeurPageState();
}

class _EditChauffeurPageState extends State<EditChauffeurPage> {
  final formKey = GlobalKey<FormState>();
  final service = AddChauffeur();

  final nomController = TextEditingController();
  final prenomController = TextEditingController();
  final telephoneController = TextEditingController();
  final emailController = TextEditingController();
  final permisController = TextEditingController();
  final cinController = TextEditingController();

  final List<String> _statuts = ['Actif', 'Inactif', 'En congé', 'Suspendu'];

  String selectedStatut = 'Actif';
  String selectedCategorie = 'B';
  DateTime? dateNaissance;
  DateTime? dateExpirationPermis;
  DateTime? dateExpirationVisite;
  String? photoUrl;
  File? pickedImage;
  bool isLoading = false;

  _ExpiryStatus _expiryStatus(DateTime? date) {
    if (date == null) return _ExpiryStatus.none;
    final now = DateTime.now();
    if (date.isBefore(now)) return _ExpiryStatus.expired;
    if (date.isBefore(now.add(const Duration(days: 30)))) {
      return _ExpiryStatus.expiringSoon;
    }
    return _ExpiryStatus.none;
  }

  @override
  void initState() {
    super.initState();
    _hydrateFromChauffeur();
  }

  @override
  void dispose() {
    nomController.dispose();
    prenomController.dispose();
    telephoneController.dispose();
    emailController.dispose();
    permisController.dispose();
    cinController.dispose();
    super.dispose();
  }

  void _hydrateFromChauffeur() {
    final nameParts = widget.chauffeur.name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (nameParts.isEmpty) {
      prenomController.text = '';
      nomController.text = '';
    } else if (nameParts.length == 1) {
      prenomController.text = nameParts.first;
      nomController.text = '';
    } else {
      prenomController.text = nameParts.first;
      nomController.text = nameParts.skip(1).join(' ');
    }

    telephoneController.text = widget.chauffeur.telephone ?? '';
    emailController.text = widget.chauffeur.email ?? '';
    permisController.text = widget.chauffeur.numeroPermis ?? '';
    cinController.text = widget.chauffeur.numeroCin ?? '';

    selectedStatut = _resolveSelection(
      value: widget.chauffeur.statut,
      values: _statuts,
      fallback: _statuts.first,
    );
    selectedCategorie = _resolveSelection(
      value: widget.chauffeur.categoriePermis,
      values: categories,
      fallback: categories[1],
    );

    dateNaissance = widget.chauffeur.dateNaissance;
    dateExpirationPermis = widget.chauffeur.dateExpirationPermis;
    dateExpirationVisite = widget.chauffeur.dateExpirationVisite;
    photoUrl = widget.chauffeur.photoUrl;
  }

  String _resolveSelection({
    required String? value,
    required List<String> values,
    required String fallback,
  }) {
    if (value != null && values.contains(value)) {
      return value;
    }
    return fallback;
  }

  Future<void> _pickDate(
    BuildContext context, {
    required DateField field,
  }) async {
    final now = DateTime.now();
    final currentDate = switch (field) {
      DateField.naissance => dateNaissance,
      DateField.permis => dateExpirationPermis,
      DateField.visite => dateExpirationVisite,
    };

    final picked = await showDatePicker(
      context: context,
      initialDate: currentDate ?? now,
      firstDate: DateTime(1950),
      lastDate: DateTime(2040),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.info,
            surface: Color(0xFF1E2A3A),
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() {
        switch (field) {
          case DateField.naissance:
            dateNaissance = picked;
          case DateField.permis:
            dateExpirationPermis = picked;
          case DateField.visite:
            dateExpirationVisite = picked;
        }
      });
    }
  }

  Future<void> _pickPhoto() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 82,
      maxWidth: 1600,
    );
    if (picked == null) return;

    setState(() {
      pickedImage = File(picked.path);
    });
  }

  Future<void> _submit() async {
    if (!formKey.currentState!.validate()) return;

    if (dateNaissance == null) {
      _showError('Veuillez sélectionner la date de naissance.');
      return;
    }

    if (dateExpirationPermis == null) {
      _showError("Veuillez sélectionner la date d'expiration du permis.");
      return;
    }

    setState(() => isLoading = true);

    try {
      var nextPhotoUrl = photoUrl;
      if (pickedImage != null) {
        nextPhotoUrl = await service.uploadPhoto(
          chauffeurId: widget.chauffeur.id,
          file: pickedImage!,
        );
      }

      final nextAlert = Chauffeur.computeAlert(
        dateExpirationPermis: dateExpirationPermis,
        dateExpirationVisite: dateExpirationVisite,
      );
      final nextConforme = nextAlert.tone == StatusTone.success;
      final nextName = _buildName();

      await service.updateChauffeur(widget.chauffeur.id, {
        'name': nextName,
        'telephone': _normalized(telephoneController),
        'email': _normalized(emailController),
        'numeroCin': _normalized(cinController),
        'numeroPermis': _normalized(permisController),
        'categoriePermis': selectedCategorie,
        'statut': selectedStatut,
        'dateNaissance': _toTimestamp(dateNaissance),
        'dateExpirationPermis': _toTimestamp(dateExpirationPermis),
        'dateExpirationVisite': _toTimestamp(dateExpirationVisite),
        'photoUrl': nextPhotoUrl,
        'conforme': nextConforme,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      final updatedChauffeur = widget.chauffeur.copyWith(
        name: nextName,
        photoUrl: nextPhotoUrl,
        conforme: nextConforme,
        alert: nextAlert,
        telephone: _normalized(telephoneController),
        email: _normalized(emailController),
        numeroCin: _normalized(cinController),
        numeroPermis: _normalized(permisController),
        categoriePermis: selectedCategorie,
        statut: selectedStatut,
        dateNaissance: dateNaissance,
        dateExpirationPermis: dateExpirationPermis,
        dateExpirationVisite: dateExpirationVisite,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil chauffeur mis à jour.'),
          backgroundColor: Color(0xFF1B8C5A),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop(updatedChauffeur);
    } on Exception catch (e) {
      if (!mounted) return;
      _showError(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  String _buildName() {
    final prenom = prenomController.text.trim();
    final nom = nomController.text.trim();
    final value = '$prenom $nom'.trim();
    return value.isEmpty ? widget.chauffeur.name : value;
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Sélectionner';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Requis';
    }
    return null;
  }

  String? _normalized(TextEditingController controller) {
    final value = controller.text.trim();
    return value.isEmpty ? null : value;
  }

  Timestamp? _toTimestamp(DateTime? date) {
    if (date == null) return null;
    return Timestamp.fromDate(date);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.accent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  ImageProvider<Object>? get _avatarImage {
    if (pickedImage != null) {
      return FileImage(pickedImage!);
    }
    if (photoUrl != null && photoUrl!.trim().isNotEmpty) {
      return NetworkImage(photoUrl!.trim());
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: const FleetAppBar(showBack: true, title: 'Modifier Chauffeur'),
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 46,
                      backgroundColor: AppColors.primary.withValues(
                        alpha: 0.12,
                      ),
                      foregroundImage: _avatarImage,
                      child: _avatarImage == null
                          ? Text(
                              widget.chauffeur.initials,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: isLoading ? null : _pickPhoto,
                      icon: const Icon(Icons.photo_library_outlined, size: 18),
                      label: const Text('Changer la photo'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              const SectionLabel(label: 'INFORMATIONS PERSONNELLES'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextformField(
                      controller: nomController,
                      label: 'Nom',
                      icon: Icons.person_outline,
                      validator: _required,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextformField(
                      controller: prenomController,
                      label: 'Prénom',
                      icon: Icons.person_outline,
                      validator: _required,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _DatePickerField(
                label: 'Date de naissance',
                value: _formatDate(dateNaissance),
                onTap: () => _pickDate(context, field: DateField.naissance),
              ),
              const SizedBox(height: 12),
              TextformField(
                controller: cinController,
                label: 'N° CIN',
                icon: Icons.badge_outlined,
                validator: _required,
              ),
              const SizedBox(height: 12),
              TextformField(
                controller: telephoneController,
                label: 'Téléphone',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: _required,
              ),
              const SizedBox(height: 12),
              TextformField(
                controller: emailController,
                label: 'Email',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 18),

              const SectionLabel(label: 'PERMIS & CONFORMITÉ'),
              const SizedBox(height: 12),
              TextformField(
                controller: permisController,
                label: 'N° Permis',
                icon: Icons.credit_card_outlined,
                validator: _required,
              ),
              const SizedBox(height: 12),
              DropdownField(
                label: 'Catégorie permis',
                value: selectedCategorie,
                items: categories,
                icon: Icons.category_outlined,
                onChanged: (v) {
                  if (v != null) {
                    setState(() => selectedCategorie = v);
                  }
                },
              ),
              const SizedBox(height: 12),
              _DatePickerField(
                label: 'Expiration permis',
                value: _formatDate(dateExpirationPermis),
                onTap: () => _pickDate(context, field: DateField.permis),
                expiryStatus: _expiryStatus(dateExpirationPermis),
              ),
              const SizedBox(height: 12),

              // _DatePickerField(
              //   label: 'Expiration visite médicale',
              //   value: _formatDate(_dateExpirationVisite),
              //   onTap: () => _pickDate(context, field: _DateField.visite),
              //   isAlert:
              //       _dateExpirationVisite != null &&
              //       _dateExpirationVisite!.isBefore(
              //         DateTime.now().add(const Duration(days: 30)),
              //       ),
              // ),
              // const SizedBox(height: 18),

              // const _SectionLabel(label: 'STATUT'),
              // const SizedBox(height: 10),
              // Wrap(
              //   spacing: 8,
              //   runSpacing: 8,
              //   children: _statuts.map((status) {
              //     final selected = _selectedStatut == status;
              //     final color = _statusColor(status);
              //     return InkWell(
              //       borderRadius: BorderRadius.circular(20),
              //       onTap: _isLoading
              //           ? null
              //           : () => setState(() => _selectedStatut = status),
              //       child: AnimatedContainer(
              //         duration: const Duration(milliseconds: 200),
              //         padding: const EdgeInsets.symmetric(
              //           horizontal: 14,
              //           vertical: 8,
              //         ),
              //         decoration: BoxDecoration(
              //           color: selected ? color : color.withOpacity(0.08),
              //           borderRadius: BorderRadius.circular(20),
              //           border: Border.all(
              //             color: color.withOpacity(selected ? 1 : 0.35),
              //           ),
              //         ),
              //         child: Text(
              //           status,
              //           style: TextStyle(
              //             color: selected ? Colors.white : color,
              //             fontSize: 12,
              //             fontWeight: FontWeight.w600,
              //           ),
              //         ),
              //       ),
              //     );
              //   }).toList(),
              // ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: isLoading ? null : _submit,
                  child: isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Enregistrer les modifications',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Color statusColor(String status) => switch (status) {
    'Actif' => const Color(0xFF1B8C5A),
    'Inactif' => Colors.grey,
    'En congé' => const Color(0xFFF5A623),
    'Suspendu' => AppColors.accent,
    _ => AppColors.primary,
  };
}

class _DatePickerField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;
  // final bool isAlert;
  final _ExpiryStatus expiryStatus;

  const _DatePickerField({
    required this.label,
    required this.value,
    required this.onTap,
    this.expiryStatus = _ExpiryStatus.none,
  });

  Color get color => switch (expiryStatus) {
    _ExpiryStatus.expired => AppColors.accent,
    _ExpiryStatus.expiringSoon => Color(0xFFF5A623),
    _ExpiryStatus.none => AppColors.primary,
  };

  bool get _hasAlert => expiryStatus != _ExpiryStatus.none;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _hasAlert ? color : const Color(0xFFE0E6F0),
            width: _hasAlert ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_outlined, size: 18, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: _hasAlert ? color : AppColors.secondary,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      color: _hasAlert
                          ? color
                          : value == 'Sélectionner'
                          ? AppColors.secondary
                          : AppColors.primary,
                      fontSize: 14,
                      fontWeight: value == 'Sélectionner'
                          ? FontWeight.normal
                          : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: _hasAlert ? color : AppColors.secondary,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

enum _ExpiryStatus { none, expiringSoon, expired }
