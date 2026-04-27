import 'package:flutter/material.dart';
import 'package:gestion_driver/core/theme/app_colors.dart';
import 'package:gestion_driver/features/drivers/services/add_chauffeur.dart';
import 'package:gestion_driver/shared/widgets/fleet_app_bar.dart';

class AddChauffeurPage extends StatefulWidget {
  const AddChauffeurPage({super.key});

  @override
  State<AddChauffeurPage> createState() => _AddChauffeurPageState();
}

class _AddChauffeurPageState extends State<AddChauffeurPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _permisController = TextEditingController();
  final _cinController = TextEditingController();

  String _selectedStatut = 'Actif';
  String _selectedCategorie = 'B';
  DateTime? _dateNaissance;
  DateTime? _dateExpirationPermis;
  DateTime? _dateExpirationVisite;
  bool _isLoading = false;
  // final _showError = false;

  final List<String> _statuts = ['Actif', 'Inactif', 'En congé', 'Suspendu'];
  final List<String> _categories = ['A', 'B', 'C', 'D', 'E'];

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

  Future<void> _pickDate(
    BuildContext context, {
    required _DateField field,
  }) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
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

  String _formatDate(DateTime? date) {
    if (date == null) return 'Sélectionner';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  // En haut du State
  final addChauffeurService = AddChauffeur();

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
      // 1. Construire l'objet Chauffeur
      final nouveauChauffeur = addChauffeurService.buildFromForm(
        nom: _nomController.text.trim(),
        prenom: _prenomController.text.trim(),
        telephone: _telephoneController.text.trim(),
        email: _emailController.text.trim(),
        numeroCin: _cinController.text.trim(),
        numeroPermis: _permisController.text.trim(),
        categoriePermis: _selectedCategorie,
        statut: _selectedStatut,
        dateNaissance: _dateNaissance,
        dateExpirationPermis: _dateExpirationPermis,
        dateExpirationVisite: _dateExpirationVisite,
      );

      // 2. Enregistrer dans Firestore
      await addChauffeurService.chauffeur(
        nouveauChauffeur.toMap(),
        nouveauChauffeur.id,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 18),
              const SizedBox(width: 10),
              Text(
                'Chauffeur ${nouveauChauffeur.name} ajouté !',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF1B8C5A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
      Navigator.of(context).pop();
    } on Exception catch (e) {
      if (!mounted) return;
      _showError(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFD32F2F),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: const FleetAppBar(),
      body: Column(
        children: [
          // Header band
          Container(
            color: AppColors.navy,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 14),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NOUVEAU CHAUFFEUR',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Enregistrement du personnel',
                      style: TextStyle(color: Colors.white54, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Form
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar placeholder
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              color: AppColors.navy.withOpacity(0.12),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.navy.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.person,
                              size: 44,
                              color: AppColors.navy,
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: const BoxDecoration(
                                color: AppColors.navy,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    _SectionLabel(label: 'INFORMATIONS PERSONNELLES'),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: _FormField(
                            controller: _nomController,
                            label: 'Nom',
                            icon: Icons.person_outline,
                            validator: (v) =>
                                (v == null || v.isEmpty) ? 'Requis' : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _FormField(
                            controller: _prenomController,
                            label: 'Prénom',
                            icon: Icons.person_outline,
                            validator: (v) =>
                                (v == null || v.isEmpty) ? 'Requis' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    _DatePickerField(
                      label: 'Date de naissance',
                      value: _formatDate(_dateNaissance),
                      onTap: () =>
                          _pickDate(context, field: _DateField.naissance),
                    ),
                    const SizedBox(height: 12),

                    _FormField(
                      controller: _cinController,
                      label: "N° CIN",
                      icon: Icons.badge_outlined,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Requis' : null,
                    ),
                    const SizedBox(height: 12),

                    _FormField(
                      controller: _telephoneController,
                      label: 'Téléphone',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Requis' : null,
                    ),
                    const SizedBox(height: 12),

                    _SectionLabel(label: 'PERMIS & CONFORMITÉ'),
                    const SizedBox(height: 12),

                    _FormField(
                      controller: _permisController,
                      label: 'N° Permis de conduire',
                      icon: Icons.credit_card_outlined,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Requis' : null,
                    ),
                    const SizedBox(height: 12),

                    // Catégorie permis
                    _DropdownField(
                      label: 'Catégorie permis',
                      value: _selectedCategorie,
                      items: _categories,
                      icon: Icons.category_outlined,
                      onChanged: (v) => setState(() => _selectedCategorie = v!),
                    ),
                    const SizedBox(height: 12),

                    _DatePickerField(
                      label: "Expiration permis",
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
                    const SizedBox(height: 24),

                    _SectionLabel(label: 'STATUT'),
                    const SizedBox(height: 12),

                    Row(
                      children: _statuts.map((s) {
                        final isSelected = _selectedStatut == s;
                        Color chipColor;
                        switch (s) {
                          case 'Actif':
                            chipColor = const Color(0xFF1B8C5A);
                          case 'Inactif':
                            chipColor = Colors.grey;
                          case 'En congé':
                            chipColor = const Color(0xFFF5A623);
                          case 'Suspendu':
                            chipColor = AppColors.red;
                          default:
                            chipColor = AppColors.navy;
                        }
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedStatut = s),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? chipColor
                                    : chipColor.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: chipColor.withOpacity(
                                    isSelected ? 1 : 0.3,
                                  ),
                                ),
                              ),
                              child: Text(
                                s,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : chipColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 32),

                    // Submit button
                    GestureDetector(
                      child: SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.navy,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
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
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.check, color: Colors.white),
                                    SizedBox(width: 8),
                                    Text(
                                      'Enregistrer le chauffeur',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Helpers ────────────────────────────────────────────────────────────────

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
            if (isAlert) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'ALERTE',
                  style: TextStyle(
                    color: AppColors.red,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
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
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
    );
  }
}
