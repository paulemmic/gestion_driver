import 'package:flutter/material.dart';
import 'package:gestion_driver/core/theme/app_colors.dart';
import 'package:gestion_driver/features/drivers/presentation/widgets/date_field.dart';
import 'package:gestion_driver/features/drivers/presentation/widgets/dropdown_field.dart';
import 'package:gestion_driver/features/drivers/presentation/widgets/section_label.dart';
import 'package:gestion_driver/features/drivers/services/add_chauffeur.dart';
import 'package:gestion_driver/shared/widgets/fleet_app_bar.dart';

class AddChauffeurPage extends StatefulWidget {
  const AddChauffeurPage({super.key});

  @override
  State<AddChauffeurPage> createState() => _AddChauffeurPageState();
}

class _AddChauffeurPageState extends State<AddChauffeurPage> {
  final formKey = GlobalKey<FormState>();

  final nomController = TextEditingController();
  final prenomController = TextEditingController();
  final telephoneController = TextEditingController();
  final emailController = TextEditingController();
  final permisController = TextEditingController();
  final cinController = TextEditingController();

  String selectedStatut = 'Actif';
  String selectedCategorie = 'B';
  DateTime? dateNaissance;
  DateTime? dateExpirationPermis;
  DateTime? dateExpirationVisite;
  bool isLoading = false;

  final List<String> statuts = ['Actif', 'Inactif', 'En congé', 'Suspendu'];
  final List<String> categories = ['A', 'B', 'C', 'D', 'E'];

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

  Future<void> pickDate(
    BuildContext context, {
    required DateField field,
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
          case DateField.naissance:
            dateNaissance = picked;
            break;
          case DateField.permis:
            dateExpirationPermis = picked;
            break;
          case DateField.visite:
            dateExpirationVisite = picked;
            break;
        }
      });
    }
  }

  String formatDate(DateTime? date) {
    if (date == null) return 'Sélectionner';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  // En haut du State
  final addChauffeurService = AddChauffeur();

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;

    if (dateNaissance == null) {
      showError('Veuillez sélectionner la date de naissance.');
      return;
    }
    if (dateExpirationPermis == null) {
      showError("Veuillez sélectionner la date d'expiration du permis.");
      return;
    }

    setState(() => isLoading = true);

    try {
      final nouveauChauffeur = addChauffeurService.buildFromForm(
        nom: nomController.text.trim(),
        prenom: prenomController.text.trim(),
        telephone: telephoneController.text.trim(),
        email: emailController.text.trim(),
        numeroCin: cinController.text.trim(),
        numeroPermis: permisController.text.trim(),
        categoriePermis: selectedCategorie,
        statut: selectedStatut,
        dateNaissance: dateNaissance,
        dateExpirationPermis: dateExpirationPermis,
        dateExpirationVisite: dateExpirationVisite,
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
      showError(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void showError(String message) {
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
              key: formKey,
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

                    SectionLabel(label: 'INFORMATIONS PERSONNELLES'),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: FormField(
                            controller: nomController,
                            label: 'Nom',
                            icon: Icons.person_outline,
                            validator: (v) =>
                                (v == null || v.isEmpty) ? 'Requis' : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FormField(
                            controller: prenomController,
                            label: 'Prénom',
                            icon: Icons.person_outline,
                            validator: (v) =>
                                (v == null || v.isEmpty) ? 'Requis' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    DatePickerField(
                      label: 'Date de naissance',
                      value: formatDate(dateNaissance),
                      onTap: () =>
                          pickDate(context, field: DateField.naissance),
                    ),
                    const SizedBox(height: 12),

                    FormField(
                      controller: cinController,
                      label: "N° CIN",
                      icon: Icons.badge_outlined,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Requis' : null,
                    ),
                    const SizedBox(height: 12),

                    FormField(
                      controller: telephoneController,
                      label: 'Téléphone',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Requis' : null,
                    ),
                    const SizedBox(height: 12),

                    SectionLabel(label: 'PERMIS & CONFORMITÉ'),
                    const SizedBox(height: 12),

                    FormField(
                      controller: permisController,
                      label: 'N° Permis de conduire',
                      icon: Icons.credit_card_outlined,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Requis' : null,
                    ),
                    const SizedBox(height: 12),

                    // Catégorie permis
                    DropdownField(
                      label: 'Catégorie permis',
                      value: selectedCategorie,
                      items: categories,
                      icon: Icons.category_outlined,
                      onChanged: (v) => setState(() => selectedCategorie = v!),
                    ),
                    const SizedBox(height: 12),

                    DatePickerField(
                      label: "Expiration permis",
                      value: formatDate(dateExpirationPermis),
                      onTap: () => pickDate(context, field: DateField.permis),
                      isAlert:
                          dateExpirationPermis != null &&
                          dateExpirationPermis!.isBefore(
                            DateTime.now().add(const Duration(days: 30)),
                          ),
                    ),
                    const SizedBox(height: 12),

                    DatePickerField(
                      label: 'Expiration visite médicale',
                      value: formatDate(dateExpirationVisite),
                      onTap: () => pickDate(context, field: DateField.visite),
                      isAlert:
                          dateExpirationVisite != null &&
                          dateExpirationVisite!.isBefore(
                            DateTime.now().add(const Duration(days: 30)),
                          ),
                    ),
                    const SizedBox(height: 24),

                    SectionLabel(label: 'STATUT'),
                    const SizedBox(height: 12),

                    Row(
                      children: statuts.map((s) {
                        final isSelected = selectedStatut == s;
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
                            onTap: () => setState(() => selectedStatut = s),
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
                          onPressed: isLoading ? null : submit,
                          child: isLoading
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

class FormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const FormField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.validator,
  });

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
