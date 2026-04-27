import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gestion_driver/core/theme/app_colors.dart';
import 'package:gestion_driver/features/drivers/models/chauffeur.dart';
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
  final _formKey = GlobalKey<FormState>();
  final _service = AddChauffeur();

  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _permisController = TextEditingController();
  final _cinController = TextEditingController();

  final List<String> _statuts = ['Actif', 'Inactif', 'En congé', 'Suspendu'];
  final List<String> _categories = ['A', 'B', 'C', 'D', 'E'];

  String _selectedStatut = 'Actif';
  String _selectedCategorie = 'B';
  DateTime? _dateNaissance;
  DateTime? _dateExpirationPermis;
  DateTime? _dateExpirationVisite;
  String? _photoUrl;
  File? _pickedImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _hydrateFromChauffeur();
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _telephoneController.dispose();
    _emailController.dispose();
    _permisController.dispose();
    _cinController.dispose();
    super.dispose();
  }

  void _hydrateFromChauffeur() {
    final nameParts = widget.chauffeur.name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (nameParts.isEmpty) {
      _prenomController.text = '';
      _nomController.text = '';
    } else if (nameParts.length == 1) {
      _prenomController.text = nameParts.first;
      _nomController.text = '';
    } else {
      _prenomController.text = nameParts.first;
      _nomController.text = nameParts.skip(1).join(' ');
    }

    _telephoneController.text = widget.chauffeur.telephone ?? '';
    _emailController.text = widget.chauffeur.email ?? '';
    _permisController.text = widget.chauffeur.numeroPermis ?? '';
    _cinController.text = widget.chauffeur.numeroCin ?? '';

    _selectedStatut = _resolveSelection(
      value: widget.chauffeur.statut,
      values: _statuts,
      fallback: _statuts.first,
    );
    _selectedCategorie = _resolveSelection(
      value: widget.chauffeur.categoriePermis,
      values: _categories,
      fallback: _categories[1],
    );

    _dateNaissance = widget.chauffeur.dateNaissance;
    _dateExpirationPermis = widget.chauffeur.dateExpirationPermis;
    _dateExpirationVisite = widget.chauffeur.dateExpirationVisite;
    _photoUrl = widget.chauffeur.photoUrl;
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
    required _DateField field,
  }) async {
    final now = DateTime.now();
    final currentDate = switch (field) {
      _DateField.naissance => _dateNaissance,
      _DateField.permis => _dateExpirationPermis,
      _DateField.visite => _dateExpirationVisite,
    };

    final picked = await showDatePicker(
      context: context,
      initialDate: currentDate ?? now,
      firstDate: DateTime(1950),
      lastDate: DateTime(2040),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.blueLight,
            surface: Color(0xFF1E2A3A),
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() {
        switch (field) {
          case _DateField.naissance:
            _dateNaissance = picked;
          case _DateField.permis:
            _dateExpirationPermis = picked;
          case _DateField.visite:
            _dateExpirationVisite = picked;
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
      _pickedImage = File(picked.path);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_dateNaissance == null) {
      _showError('Veuillez sélectionner la date de naissance.');
      return;
    }

    if (_dateExpirationPermis == null) {
      _showError("Veuillez sélectionner la date d'expiration du permis.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      var nextPhotoUrl = _photoUrl;
      if (_pickedImage != null) {
        nextPhotoUrl = await _service.uploadPhoto(
          chauffeurId: widget.chauffeur.id,
          file: _pickedImage!,
        );
      }

      final nextAlert = Chauffeur.computeAlert(
        dateExpirationPermis: _dateExpirationPermis,
        dateExpirationVisite: _dateExpirationVisite,
      );
      final nextConforme = nextAlert.tone == StatusTone.success;
      final nextName = _buildName();

      await _service.updateChauffeur(widget.chauffeur.id, {
        'name': nextName,
        'telephone': _normalized(_telephoneController),
        'email': _normalized(_emailController),
        'numeroCin': _normalized(_cinController),
        'numeroPermis': _normalized(_permisController),
        'categoriePermis': _selectedCategorie,
        'statut': _selectedStatut,
        'dateNaissance': _toTimestamp(_dateNaissance),
        'dateExpirationPermis': _toTimestamp(_dateExpirationPermis),
        'dateExpirationVisite': _toTimestamp(_dateExpirationVisite),
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
        telephone: _normalized(_telephoneController),
        email: _normalized(_emailController),
        numeroCin: _normalized(_cinController),
        numeroPermis: _normalized(_permisController),
        categoriePermis: _selectedCategorie,
        statut: _selectedStatut,
        dateNaissance: _dateNaissance,
        dateExpirationPermis: _dateExpirationPermis,
        dateExpirationVisite: _dateExpirationVisite,
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
        setState(() => _isLoading = false);
      }
    }
  }

  String _buildName() {
    final prenom = _prenomController.text.trim();
    final nom = _nomController.text.trim();
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
        backgroundColor: AppColors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  ImageProvider<Object>? get _avatarImage {
    if (_pickedImage != null) {
      return FileImage(_pickedImage!);
    }
    if (_photoUrl != null && _photoUrl!.trim().isNotEmpty) {
      return NetworkImage(_photoUrl!.trim());
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: const FleetAppBar(
        showBack: true,
        title: 'Modifier Chauffeur',
      ),
      body: Form(
        key: _formKey,
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
                      backgroundColor: AppColors.navy.withOpacity(0.12),
                      foregroundImage: _avatarImage,
                      child: _avatarImage == null
                          ? Text(
                              widget.chauffeur.initials,
                              style: const TextStyle(
                                color: AppColors.navy,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: _isLoading ? null : _pickPhoto,
                      icon: const Icon(Icons.photo_library_outlined, size: 18),
                      label: const Text('Changer la photo'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              const _SectionLabel(label: 'INFORMATIONS PERSONNELLES'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _FormField(
                      controller: _nomController,
                      label: 'Nom',
                      icon: Icons.person_outline,
                      validator: _required,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _FormField(
                      controller: _prenomController,
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
                value: _formatDate(_dateNaissance),
                onTap: () => _pickDate(context, field: _DateField.naissance),
              ),
              const SizedBox(height: 12),
              _FormField(
                controller: _cinController,
                label: 'N° CIN',
                icon: Icons.badge_outlined,
                validator: _required,
              ),
              const SizedBox(height: 12),
              _FormField(
                controller: _telephoneController,
                label: 'Téléphone',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: _required,
              ),
              const SizedBox(height: 12),
              _FormField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 18),

              const _SectionLabel(label: 'PERMIS & CONFORMITÉ'),
              const SizedBox(height: 12),
              _FormField(
                controller: _permisController,
                label: 'N° Permis',
                icon: Icons.credit_card_outlined,
                validator: _required,
              ),
              const SizedBox(height: 12),
              _DropdownField(
                label: 'Catégorie permis',
                value: _selectedCategorie,
                items: _categories,
                icon: Icons.category_outlined,
                onChanged: (v) {
                  if (v != null) {
                    setState(() => _selectedCategorie = v);
                  }
                },
              ),
              const SizedBox(height: 12),
              _DatePickerField(
                label: 'Expiration permis',
                value: _formatDate(_dateExpirationPermis),
                onTap: () => _pickDate(context, field: _DateField.permis),
                isAlert:
                    _dateExpirationPermis != null &&
                    _dateExpirationPermis!.isBefore(
                      DateTime.now().add(const Duration(days: 30)),
                    ),
              ),
              const SizedBox(height: 12),
              _DatePickerField(
                label: 'Expiration visite médicale',
                value: _formatDate(_dateExpirationVisite),
                onTap: () => _pickDate(context, field: _DateField.visite),
                isAlert:
                    _dateExpirationVisite != null &&
                    _dateExpirationVisite!.isBefore(
                      DateTime.now().add(const Duration(days: 30)),
                    ),
              ),
              const SizedBox(height: 18),

              const _SectionLabel(label: 'STATUT'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _statuts.map((status) {
                  final selected = _selectedStatut == status;
                  final color = _statusColor(status);
                  return InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: _isLoading
                        ? null
                        : () => setState(() => _selectedStatut = status),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: selected ? color : color.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: color.withOpacity(selected ? 1 : 0.35),
                        ),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: selected ? Colors.white : color,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.navy,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
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

  Color _statusColor(String status) => switch (status) {
    'Actif' => const Color(0xFF1B8C5A),
    'Inactif' => Colors.grey,
    'En congé' => const Color(0xFFF5A623),
    'Suspendu' => AppColors.red,
    _ => AppColors.navy,
  };
}

enum _DateField { naissance, permis, visite }

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          color: AppColors.navy,
          margin: const EdgeInsets.only(right: 8),
        ),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.4,
          ),
        ),
      ],
    );
  }
}

class _FormField extends StatelessWidget {
  const _FormField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
        ),
        prefixIcon: Icon(icon, color: AppColors.navy, size: 18),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE0E6F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE0E6F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.navy, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.red),
        ),
      ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  const _DatePickerField({
    required this.label,
    required this.value,
    required this.onTap,
    this.isAlert = false,
  });

  final String label;
  final String value;
  final VoidCallback onTap;
  final bool isAlert;

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
            color: isAlert ? AppColors.red : const Color(0xFFE0E6F0),
            width: isAlert ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 18,
              color: isAlert ? AppColors.red : AppColors.navy,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: isAlert ? AppColors.red : AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      color: value == 'Sélectionner'
                          ? AppColors.textSecondary
                          : AppColors.textPrimary,
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
              color: isAlert ? AppColors.red : AppColors.textSecondary,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.icon,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> items;
  final IconData icon;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      dropdownColor: Colors.white,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
        ),
        prefixIcon: Icon(icon, color: AppColors.navy, size: 18),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE0E6F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE0E6F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.navy, width: 1.5),
        ),
      ),
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
    );
  }
}
