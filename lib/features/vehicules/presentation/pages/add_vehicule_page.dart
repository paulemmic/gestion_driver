import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gestion_driver/core/theme/app_colors.dart';
import 'package:gestion_driver/features/vehicules/services/add_vehicules.dart';

enum CarburantType { essence, diesel, electrique, hybride /*gpl*/ }

enum VehiculeStatus { actif, enCourse, maintenance, inactif }

class AddVehiculePage extends StatefulWidget {
  const AddVehiculePage({super.key});

  @override
  State<AddVehiculePage> createState() => _AddVehiculePageState();
}

class _AddVehiculePageState extends State<AddVehiculePage> {
  final formKey = GlobalKey<FormState>();

  // Controllers
  final marqueController = TextEditingController();
  final modeleController = TextEditingController();
  final plaqueController = TextEditingController();
  final vinController = TextEditingController();
  final anneeController = TextEditingController();
  final kilometrageController = TextEditingController();
  final notesController = TextEditingController();
  final assuranceController = TextEditingController();
  final visiteTechController = TextEditingController();

  DateTime? assuranceDate;
  DateTime? visiteTechDate;

  CarburantType carburant = CarburantType.essence;
  VehiculeStatus status = VehiculeStatus.actif;

  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    anneeController.addListener(updateStatusFromDates);
  }

  void updateStatusFromDates() {
    final year = int.tryParse(anneeController.text.trim());
    if (year == null) return;

    final age = DateTime.now().year - year;

    final newStatus = switch (age) {
      <= 5 => VehiculeStatus.actif,
      <= 10 => VehiculeStatus.maintenance,
      _ => VehiculeStatus.inactif,
    };

    if (status != newStatus) {
      setState(() => status = newStatus);
    }

    // if (assuranceDate == null && visiteTechDate == null) return;

    // final now = DateTime.now();
    // final soon = now.add(const Duration(days: 30));

    // bool assuranceOk = assuranceDate != null && assuranceDate!.isAfter(soon);
    // bool visiteTechOk = visiteTechDate != null && visiteTechDate!.isAfter(soon);

    // bool assuranceExpireSoon =
    //     assuranceDate != null &&
    //     assuranceDate!.isAfter(now) &&
    //     assuranceDate!.isAfter(soon);
    // bool visiteTechExpireSoon =
    //     visiteTechDate != null &&
    //     visiteTechDate!.isAfter(now) &&
    //     visiteTechDate!.isAfter(soon);

    // bool assuranceExpiree =
    //     assuranceDate != null && assuranceDate!.isBefore(now);
    // bool visiteTechExpiree =
    //     visiteTechDate != null && visiteTechDate!.isBefore(now);

    // VehiculeStatus newStatus;

    // if (assuranceExpiree && visiteTechExpiree) {
    //   newStatus = VehiculeStatus.inactif;
    // } else if (assuranceExpiree ||
    //     visiteTechExpiree ||
    //     assuranceExpireSoon ||
    //     visiteTechExpireSoon) {
    //   newStatus = VehiculeStatus.maintenance;
    // } else if (assuranceOk && visiteTechOk) {
    //   newStatus = VehiculeStatus.actif;
    // } else {
    //   return;
    // }

    // if (status != newStatus) setState(() => status = newStatus);
  }

  @override
  void dispose() {
    anneeController.removeListener(updateStatusFromDates);
    marqueController.dispose();
    modeleController.dispose();
    plaqueController.dispose();
    vinController.dispose();
    anneeController.dispose();
    kilometrageController.dispose();
    notesController.dispose();
    assuranceController.dispose();
    visiteTechController.dispose();
    super.dispose();
  }

  Future<void> pickDate({
    required TextEditingController controller,
    required void Function(DateTime) onPicked,
  }) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
            surface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      onPicked(picked);
      controller.text =
          '${picked.day.toString().padLeft(2, '0')}/'
          '${picked.month.toString().padLeft(2, '0')}/'
          '${picked.year}';
      updateStatusFromDates();
    }
  }

  Widget dateField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required DateTime? date,
    required void Function(DateTime) onPicked,
  }) {
    Color? badgeColor;
    String? badgeText;

    if (date != null) {
      final now = DateTime.now();
      final diff = date.difference(now).inDays;

      if (date.isBefore(now)) {
        badgeColor = AppColors.accent;
        badgeText = 'Expiré';
      } else if (diff <= 30) {
        badgeColor = AppColors.warning;
        badgeText = 'Expire bientôt';
      } else {
        badgeColor = AppColors.succe;
        badgeText = 'Valide';
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          readOnly: true,
          onTap: () => pickDate(controller: controller, onPicked: onPicked),
          decoration:
              fieldDecoration(
                label: label,
                hint: 'JJ/MM/AAAA',
                icon: icon,
              ).copyWith(
                suffixIcon: IconButton(
                  onPressed: () =>
                      pickDate(controller: controller, onPicked: onPicked),
                  icon: const Icon(
                    Icons.edit_calendar_outlined,
                    color: AppColors.primary,
                    size: 18,
                  ),
                ),
              ),
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Ce champ est requis' : null,
        ),
        if (badgeText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: badgeColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  badgeText,
                  style: TextStyle(
                    color: badgeColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  String? required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Ce champ est requis' : null;

  String? validateAnnee(String? v) {
    if (v == null || v.trim().isEmpty) return 'Ce champ est requis';
    final year = int.tryParse(v);
    if (year == null) return 'Année invalide';
    final now = DateTime.now().year;
    if (year < 1886 || year > now + 1) return 'Année hors plage';
    return null;
  }

  String? validateKm(String? v) {
    if (v == null || v.trim().isEmpty) return null; // optional
    if (int.tryParse(v.replaceAll(' ', '')) == null) {
      return 'Nombre invalide';
    }
    return null;
  }

  final service = AddVehicules();

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;
    setState(() => isSaving = true);

    try {
      final vehicule = service.buildFromForm(
        marque: marqueController.text.trim(),
        modele: modeleController.text.trim(),
        plaque: plaqueController.text.trim(),
        vin: vinController.text.trim(),
        annee: int.parse(anneeController.text.trim()),
        kilometrage: kilometrageController.text.trim().isEmpty
            ? null
            : int.tryParse(kilometrageController.text.trim()),
        carburant: carburant.name,
        statut: status.name,
        notes: notesController.text.trim().isEmpty
            ? null
            : notesController.text.trim(),
      );

      // 2. Enregistrer dans Firestore
      await service.addVehicule(vehicule.toMap(), vehicule.id!);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: AppColors.succe),
              const SizedBox(width: 10),
              Text(
                '${vehicule.name} ajouté avec succès',
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      );
      Navigator.of(context).pop();
    } on Exception catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFD32F2F),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  e.toString().replaceFirst('Exception: ', ''),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  Widget sectionLabel(String label) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(
      label,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: AppColors.primary,
      ),
    ),
  );

  Widget card({required Widget child}) => Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 20),
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: child,
  );

  InputDecoration fieldDecoration({
    required String label,
    required String hint,
    required IconData icon,
    String? suffix,
  }) => InputDecoration(
    labelText: label,
    hintText: hint,
    suffixText: suffix,
    prefixIcon: Icon(icon, size: 18, color: AppColors.primary),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFFDDE3EE)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFFDDE3EE)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.accent),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.accent, width: 1.6),
    ),
    filled: true,
    fillColor: const Color(0xFFF7F9FC),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    labelStyle: const TextStyle(color: AppColors.secondary),
    floatingLabelStyle: const TextStyle(color: AppColors.primary),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 18,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Nouveau véhicule',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
          ),
        ),
        centerTitle: false,
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
          children: [
            sectionLabel('INFORMATIONS GÉNÉRALES'),
            card(
              child: Column(
                children: [
                  TextFormField(
                    controller: marqueController,
                    textCapitalization: TextCapitalization.words,
                    decoration: fieldDecoration(
                      label: 'Marque',
                      hint: 'Toyota, Mercedes, Renault…',
                      icon: Icons.directions_car_outlined,
                    ),
                    validator: required,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: modeleController,
                    textCapitalization: TextCapitalization.words,
                    decoration: fieldDecoration(
                      label: 'Modèle',
                      hint: 'Corolla, Sprinter, Kangoo…',
                      icon: Icons.commute_outlined,
                    ),
                    validator: required,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: plaqueController,
                          textCapitalization: TextCapitalization.characters,
                          decoration: fieldDecoration(
                            label: 'Immatriculation',
                            hint: 'AB-123-CD',
                            icon: Icons.credit_card_outlined,
                          ),
                          validator: required,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: anneeController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(4),
                          ],
                          decoration: fieldDecoration(
                            label: 'Année',
                            hint: '2022',
                            icon: Icons.calendar_today_outlined,
                          ),
                          validator: validateAnnee,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Identification ──────────────────────────────────────────
            sectionLabel('IDENTIFICATION'),
            card(
              child: Column(
                children: [
                  TextFormField(
                    controller: vinController,
                    textCapitalization: TextCapitalization.characters,
                    maxLength: 17,
                    decoration: fieldDecoration(
                      label: 'Numéro VIN',
                      hint: 'WBA3A5C51DF…',
                      icon: Icons.pin_outlined,
                    ).copyWith(counterText: ''),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Ce champ est requis';
                      }
                      if (v.trim().length != 17) {
                        return 'Le VIN doit comporter 17 caractères';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: kilometrageController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: fieldDecoration(
                      label: 'Kilométrage actuel',
                      hint: '0',
                      icon: Icons.speed_outlined,
                      suffix: 'km',
                    ),
                    validator: validateKm,
                  ),
                ],
              ),
            ),

            // sectionLabel("DOCUMENT"),
            // card(
            //   child: Column(
            //     children: [
            //       dateField(
            //         controller: assuranceController,
            //         label: "Experation Assurance",
            //         icon: Icons.shield_outlined,
            //         date: assuranceDate,
            //         onPicked: (d) => setState(() => assuranceDate = d),
            //       ),
            //       const SizedBox(height: 14),
            //       dateField(
            //         controller: visiteTechController,
            //         label: "Expiration Visite Technique",
            //         icon: Icons.fact_check_outlined,
            //         date: visiteTechDate,
            //         onPicked: (d) => setState(() => visiteTechDate = d),
            //       ),
            //     ],
            //   ),
            // ),
            sectionLabel('TYPE DE CARBURANT'),
            card(
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: CarburantType.values.map((type) {
                  final selected = carburant == type;
                  return GestureDetector(
                    onTap: () => setState(() => carburant = type),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: selected
                              ? AppColors.primary
                              : const Color(0xFFDDE3EE),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.local_gas_station_outlined,
                            size: 15,
                            color: selected
                                ? Colors.white
                                : AppColors.secondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${type.name[0].toUpperCase()}${type.name.substring(1)}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: selected
                                  ? Colors.white
                                  : AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            sectionLabel('STATUT'),
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 13,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Suggéré automatiquement selon l\'année — modifiable',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.secondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            // ('STATUT'),
            // card(
            //   child: Column(
            //     children: VehiculeStatus.values.map((s) {
            //       final selected = status == s;
            //       return GestureDetector(
            //         onTap: () => setState(() => status = s),
            //         child: AnimatedContainer(
            //           duration: const Duration(milliseconds: 160),
            //           margin: const EdgeInsets.only(bottom: 8),
            //           padding: const EdgeInsets.symmetric(
            //             horizontal: 14,
            //             vertical: 13,
            //           ),
            //           decoration: BoxDecoration(
            //             color: selected
            //                 ? s.color.withOpacity(0.08)
            //                 : Colors.transparent,
            //             borderRadius: BorderRadius.circular(10),
            //             border: Border.all(
            //               color: selected ? s.color : const Color(0xFFDDE3EE),
            //               width: 1.4,
            //             ),
            //           ),
            //           child: Row(
            //             children: [
            //               Container(
            //                 width: 10,
            //                 height: 10,
            //                 decoration: BoxDecoration(
            //                   color: selected ? s.color : Colors.grey.shade300,
            //                   shape: BoxShape.circle,
            //                 ),
            //               ),
            //               const SizedBox(width: 12),
            //               Text(
            //                 s.label,
            //                 style: TextStyle(
            //                   fontWeight: FontWeight.w600,
            //                   fontSize: 14,
            //                   color: selected
            //                       ? s.color
            //                       : AppColors.textSecondary,
            //                 ),
            //               ),
            //               const Spacer(),
            //               if (selected)
            //                 Icon(Icons.check_circle, color: s.color, size: 18),
            //             ],
            //           ),
            //         ),
            //       );
            //     }).toList(),
            //   ),
            // ),

            // _sectionLabel('NOTES (OPTIONNEL)'),
            // _card(
            //   child: TextFormField(
            //     controller: _notesCtrl,
            //     maxLines: 4,
            //     decoration: InputDecoration(
            //       hintText:
            //           'Informations complémentaires, historique, remarques…',
            //       hintStyle: const TextStyle(
            //         color: AppColors.textSecondary,
            //         fontSize: 13,
            //       ),
            //       border: InputBorder.none,
            //     ),
            //   ),
            // ),
          ],
        ),
      ),

      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(
          16,
          12,
          16,
          MediaQuery.of(context).padding.bottom + 12,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: isSaving ? null : submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.6),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: isSaving
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Enregistrer le véhicule',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
