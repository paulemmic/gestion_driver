import 'package:flutter/material.dart';
import 'package:gestion_driver/core/constants.dart';
import 'package:gestion_driver/core/theme/app_colors.dart';
import 'package:gestion_driver/features/drivers/presentation/widgets/date_field.dart';
import 'package:gestion_driver/features/drivers/presentation/widgets/date_input_field.dart';
import 'package:gestion_driver/features/drivers/presentation/widgets/dropdown_field.dart';
import 'package:gestion_driver/features/drivers/presentation/widgets/section_label.dart';
import 'package:gestion_driver/features/drivers/presentation/widgets/textform_field.dart';
import 'package:gestion_driver/features/drivers/services/add_chauffeur.dart';
import 'package:gestion_driver/shared/widgets/fleet_app_bar.dart';

class AddChauffeurPage extends StatefulWidget {
  const AddChauffeurPage({super.key});

  @override
  State<AddChauffeurPage> createState() => _AddChauffeurPageState();
}

class _AddChauffeurPageState extends State<AddChauffeurPage> {
  static final RegExp _datePattern = RegExp(r'^(\d{2})/(\d{2})/(\d{4})$');

  final formKey = GlobalKey<FormState>();

  final nomController = TextEditingController();
  final prenomController = TextEditingController();
  final telephoneController = TextEditingController();
  final emailController = TextEditingController();
  final permisController = TextEditingController();
  final cinController = TextEditingController();

  // Contrôleurs pour la saisie de date au format jj/mm/aaaa
  final dateNaissanceController = TextEditingController();
  final dateExpirationPermisController = TextEditingController();
  final dateExpirationVisiteController = TextEditingController();

  String selectedStatut = 'Actif';
  String selectedCategorie = 'B';
  DateTime? dateNaissance;
  DateTime? dateExpirationPermis;
  DateTime? dateExpirationVisite;
  bool isLoading = false;

  @override
  void dispose() {
    nomController.dispose();
    prenomController.dispose();
    telephoneController.dispose();
    emailController.dispose();
    permisController.dispose();
    cinController.dispose();
    dateNaissanceController.dispose();
    dateExpirationPermisController.dispose();
    dateExpirationVisiteController.dispose();
    super.dispose();
  }

  /// Déduit le statut basé sur les dates d'expiration
  String deduireStatut() {
    final now = DateTime.now();

    // Si le permis est expiré ou expire dans moins de 30 jours
    if (dateExpirationPermis != null &&
        dateExpirationPermis!.isBefore(now.add(const Duration(days: 30)))) {
      return 'Expire le ${formatDate(dateExpirationPermis)}';
    }

    // Si la visite médicale est expirée ou expire dans moins de 30 jours
    // if (dateExpirationVisite != null &&
    //     dateExpirationVisite!.isBefore(now.add(const Duration(days: 30)))) {
    //   return 'Suspendu';
    // }

    // Par défaut, le chauffeur est actif
    return 'Actif';
  }

  Future<void> _pickDate(DateField field) async {
    DateTime initial;
    DateTime firstDate;
    DateTime lastDate;

    switch (field) {
      case DateField.naissance:
        initial = dateNaissance ?? DateTime(1990);
        firstDate = DateTime(1940);
        lastDate = DateTime.now();
        break;
      case DateField.permis:
        initial = dateExpirationPermis ?? DateTime.now();
        firstDate = DateTime(2000);
        lastDate = DateTime.now().add(const Duration(days: 365 * 10));
        break;
      case DateField.visite:
        initial = dateExpirationVisite ?? DateTime.now();
        firstDate = DateTime.now().subtract(const Duration(days: 365));
        lastDate = DateTime.now().add(const Duration(days: 365 * 5));
        break;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formatted = formatDate(picked); // ex: "15/06/2025"
      setState(() {
        switch (field) {
          case DateField.naissance:
            dateNaissance = picked;
            dateNaissanceController.text = formatted;
            break;
          case DateField.permis:
            dateExpirationPermis = picked;
            dateExpirationPermisController.text = formatted;
            break;
          case DateField.visite:
            dateExpirationVisite = picked;
            dateExpirationVisiteController.text = formatted;
            break;
        }
        selectedStatut = deduireStatut();
      });
    }
  }

  /// Parse une date au format jj/mm/aaaa
  DateTime? parseDateFromString(String dateString) {
    final match = _datePattern.firstMatch(dateString.trim());

    if (match == null) return null;

    try {
      final day = int.parse(match.group(1)!);
      final month = int.parse(match.group(2)!);
      final year = int.parse(match.group(3)!);

      final date = DateTime(year, month, day);

      // Vérifier que la date est valide
      if (date.day != day || date.month != month || date.year != year) {
        return null;
      }

      return date;
    } catch (_) {
      return null;
    }
  }

  /// Formate une date au format jj/mm/aaaa
  String formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  final addChauffeurService = AddChauffeur();

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;

    if (dateNaissance == null) {
      showError(
        'Veuillez saisir une date de naissance valide au format jj/mm/aaaa',
      );
      return;
    }
    if (dateExpirationPermis == null) {
      showError(
        'Veuillez saisir une date d\'expiration du permis valide au format jj/mm/aaaa',
      );
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
    final statusColor = _getStatusColor(selectedStatut);
    final statusMessage = _getStatusMessage(selectedStatut);
    final now = DateTime.now();
    final soonThreshold = now.add(const Duration(days: 30));
    final isPermisExpiringSoon =
        dateExpirationPermis != null &&
        dateExpirationPermis!.isBefore(soonThreshold);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: const FleetAppBar(),
      body: Column(
        children: [
          // Header band
          Container(
            color: AppColors.primary,
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
                              color: AppColors.primary.withOpacity(0.12),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primary.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.person,
                              size: 44,
                              color: AppColors.primary,
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
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
                          child: TextformField(
                            controller: nomController,
                            label: 'Nom',
                            icon: Icons.person_outline,
                            validator: (v) =>
                                (v == null || v.isEmpty) ? 'Requis' : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextformField(
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

                    // Date de naissance avec saisie manuelle
                    DateInputField(
                      label: 'Date de naissance',
                      controller: dateNaissanceController,
                      hint: 'jj/mm/aaaa',
                      onCalendarTap: () => _pickDate(DateField.naissance),
                      // onChanged: (value) =>
                      //     handleDateInput(value, DateField.naissance),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Requis';
                        if (parseDateFromString(v) == null) {
                          return 'Format invalide (jj/mm/aaaa)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    TextformField(
                      controller: cinController,
                      label: "N° CIN",
                      icon: Icons.badge_outlined,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Requis' : null,
                    ),
                    const SizedBox(height: 12),

                    TextformField(
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

                    TextformField(
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

                    // Expiration permis avec saisie manuelle
                    DateInputField(
                      label: "Expiration permis",
                      controller: dateExpirationPermisController,
                      hint: 'jj/mm/aaaa',
                      onCalendarTap: () => _pickDate(DateField.permis),
                      // onChanged: (value) =>
                      //     handleDateInput(value, DateField.permis),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Requis';
                        if (parseDateFromString(v) == null) {
                          return 'Format invalide (jj/mm/aaaa)';
                        }
                        return null;
                      },
                      isAlert: isPermisExpiringSoon,
                    ),
                    const SizedBox(height: 12),

                    // Expiration visite médicale avec saisie manuelle
                    // DateInputField(
                    //   label: 'Expiration visite médicale',
                    //   controller: dateExpirationVisiteController,
                    //   hint: 'jj/mm/aaaa',
                    //   onCalendarTap: () => _pickDate(DateField.visite),
                    //   onChanged: (value) =>
                    //       handleDateInput(value, DateField.visite),
                    //   validator: (v) {
                    //     if (v != null &&
                    //         v.isNotEmpty &&
                    //         parseDateFromString(v) == null) {
                    //       return 'Format invalide (jj/mm/aaaa)';
                    //     }
                    //     return null;
                    //   },
                    //   isAlert:
                    //       dateExpirationVisite != null &&
                    //       dateExpirationVisite!.isBefore(
                    //         DateTime.now().add(const Duration(days: 30)),
                    //       ),
                    // ),
                    // const SizedBox(height: 24),

                    // Affichage du statut déduit automatiquement
                    SectionLabel(label: 'STATUT (DÉDUIT AUTOMATIQUEMENT)'),
                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.08),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.2),
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: statusColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            selectedStatut,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            statusMessage,
                            style: const TextStyle(
                              color: AppColors.secondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
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

  Color _getStatusColor(String statut) {
    if (statut == 'Actif') return AppColors.primary;
    if (statut == 'Inactif') return AppColors.secondary;
    if (statut == 'En congé') return AppColors.info;
    if (statut == 'Suspendu') return AppColors.accent;
    if (statut.startsWith('Expire le')) return AppColors.warning;
    return AppColors.primary;
  }

  String _getStatusMessage(String statut) {
    if (statut == 'Actif') return 'Chauffeur disponible';
    if (statut == 'Inactif') return 'Chauffeur inactif';
    if (statut == 'En congé') return 'En période de congé';
    if (statut == 'Suspendu') return 'Documents expirés';
    if (statut.startsWith('Expire le')) return 'Expiration imminente';
    return '';
  }

  /// Retourne la couleur du statut
  //   Color _getStatusColor(String statut) {
  //     switch (statut) {
  //       case 'Actif':
  //         return AppColors.primaryLight;
  //       case 'Inactif':
  //         return AppColors.textSecondary;
  //       case 'En congé':
  //         return AppColors.taxiYellow;
  //       case 'Suspendu':
  //         return AppColors.accent;
  //       default:
  //         return AppColors.primary;
  //     }
  //   }

  //   /// Retourne le message du statut
  //   String _getStatusMessage(String statut) {
  //     switch (statut) {
  //       case 'Actif':
  //         return 'Chauffeur disponible';
  //       case 'Inactif':
  //         return 'Chauffeur inactif';
  //       case 'En congé':
  //         return 'En période de congé';
  //       case 'Suspendu':
  //         return 'Documents expirés';
  //       default:
  //         return '';
  //     }
  //   }
}
