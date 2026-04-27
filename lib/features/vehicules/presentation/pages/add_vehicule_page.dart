import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gestion_driver/core/theme/app_colors.dart';
import 'package:gestion_driver/features/vehicules/services/add_vehicules.dart';

enum CarburantType { essence, diesel, electrique, hybride, gpl }

enum VehiculeStatus { actif, maintenance, inactif }

extension CarburantLabel on CarburantType {
  String get label => switch (this) {
    CarburantType.essence => 'Essence',
    CarburantType.diesel => 'Diesel',
    CarburantType.electrique => 'Électrique',
    CarburantType.hybride => 'Hybride',
    CarburantType.gpl => 'GPL',
  };

  IconData get icon => switch (this) {
    CarburantType.essence => Icons.local_gas_station,
    CarburantType.diesel => Icons.oil_barrel,
    CarburantType.electrique => Icons.bolt,
    CarburantType.hybride => Icons.eco,
    CarburantType.gpl => Icons.propane,
  };
}

extension StatusLabel on VehiculeStatus {
  String get label => switch (this) {
    VehiculeStatus.actif => 'Actif',
    VehiculeStatus.maintenance => 'En maintenance',
    VehiculeStatus.inactif => 'Inactif',
  };

  Color get color => switch (this) {
    VehiculeStatus.actif => AppColors.green,
    VehiculeStatus.maintenance => AppColors.red,
    VehiculeStatus.inactif => Colors.grey,
  };
}

class AddVehiculePage extends StatefulWidget {
  const AddVehiculePage({super.key});

  @override
  State<AddVehiculePage> createState() => _AddVehiculePageState();
}

class _AddVehiculePageState extends State<AddVehiculePage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _marqueCtrl = TextEditingController();
  final _modeleCtrl = TextEditingController();
  final _plaqueCtrl = TextEditingController();
  final _vinCtrl = TextEditingController();
  final _anneeCtrl = TextEditingController();
  final _kilometrageCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  CarburantType _carburant = CarburantType.essence;
  VehiculeStatus _status = VehiculeStatus.actif;

  bool _isSaving = false;

  @override
  void dispose() {
    _marqueCtrl.dispose();
    _modeleCtrl.dispose();
    _plaqueCtrl.dispose();
    _vinCtrl.dispose();
    _anneeCtrl.dispose();
    _kilometrageCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Ce champ est requis' : null;

  String? _validateAnnee(String? v) {
    if (v == null || v.trim().isEmpty) return 'Ce champ est requis';
    final year = int.tryParse(v);
    if (year == null) return 'Année invalide';
    final now = DateTime.now().year;
    if (year < 1886 || year > now + 1) return 'Année hors plage';
    return null;
  }

  String? _validateKm(String? v) {
    if (v == null || v.trim().isEmpty) return null; // optional
    if (int.tryParse(v.replaceAll(' ', '')) == null) {
      return 'Nombre invalide';
    }
    return null;
  }

  final _service = AddVehicules();

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final vehicule = _service.buildFromForm(
        marque: _marqueCtrl.text.trim(),
        modele: _modeleCtrl.text.trim(),
        plaque: _plaqueCtrl.text.trim(),
        vin: _vinCtrl.text.trim(),
        annee: int.parse(_anneeCtrl.text.trim()),
        kilometrage: _kilometrageCtrl.text.trim().isEmpty
            ? null
            : int.tryParse(_kilometrageCtrl.text.trim()),
        carburant: _carburant.label,
        statut: _status.label,
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      );

      // 2. Enregistrer dans Firestore
      await _service.addVehicule(vehicule.toMap(), vehicule.id!);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.navy,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: AppColors.green),
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
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Widget _sectionLabel(String label) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(
      label,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: AppColors.navy,
      ),
    ),
  );

  Widget _card({required Widget child}) => Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 20),
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: child,
  );

  InputDecoration _fieldDecoration({
    required String label,
    required String hint,
    required IconData icon,
    String? suffix,
  }) => InputDecoration(
    labelText: label,
    hintText: hint,
    suffixText: suffix,
    prefixIcon: Icon(icon, size: 18, color: AppColors.navy),
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
      borderSide: const BorderSide(color: AppColors.navy, width: 1.6),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.red),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.red, width: 1.6),
    ),
    filled: true,
    fillColor: const Color(0xFFF7F9FC),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    labelStyle: const TextStyle(color: AppColors.textSecondary),
    floatingLabelStyle: const TextStyle(color: AppColors.navy),
  );

  // ── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
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
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
          children: [
            // ── Informations générales ──────────────────────────────────
            _sectionLabel('INFORMATIONS GÉNÉRALES'),
            _card(
              child: Column(
                children: [
                  TextFormField(
                    controller: _marqueCtrl,
                    textCapitalization: TextCapitalization.words,
                    decoration: _fieldDecoration(
                      label: 'Marque',
                      hint: 'Toyota, Mercedes, Renault…',
                      icon: Icons.directions_car_outlined,
                    ),
                    validator: _required,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _modeleCtrl,
                    textCapitalization: TextCapitalization.words,
                    decoration: _fieldDecoration(
                      label: 'Modèle',
                      hint: 'Corolla, Sprinter, Kangoo…',
                      icon: Icons.commute_outlined,
                    ),
                    validator: _required,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: _plaqueCtrl,
                          textCapitalization: TextCapitalization.characters,
                          decoration: _fieldDecoration(
                            label: 'Immatriculation',
                            hint: 'AB-123-CD',
                            icon: Icons.credit_card_outlined,
                          ),
                          validator: _required,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _anneeCtrl,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(4),
                          ],
                          decoration: _fieldDecoration(
                            label: 'Année',
                            hint: '2022',
                            icon: Icons.calendar_today_outlined,
                          ),
                          validator: _validateAnnee,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Identification ──────────────────────────────────────────
            _sectionLabel('IDENTIFICATION'),
            _card(
              child: Column(
                children: [
                  TextFormField(
                    controller: _vinCtrl,
                    textCapitalization: TextCapitalization.characters,
                    maxLength: 17,
                    decoration: _fieldDecoration(
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
                    controller: _kilometrageCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: _fieldDecoration(
                      label: 'Kilométrage actuel',
                      hint: '0',
                      icon: Icons.speed_outlined,
                      suffix: 'km',
                    ),
                    validator: _validateKm,
                  ),
                ],
              ),
            ),

            _sectionLabel('TYPE DE CARBURANT'),
            _card(
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: CarburantType.values.map((type) {
                  final selected = _carburant == type;
                  return GestureDetector(
                    onTap: () => setState(() => _carburant = type),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.navy : Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: selected
                              ? AppColors.navy
                              : const Color(0xFFDDE3EE),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            type.icon,
                            size: 15,
                            color: selected
                                ? Colors.white
                                : AppColors.textSecondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            type.label,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: selected
                                  ? Colors.white
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            _sectionLabel('STATUT'),
            _card(
              child: Column(
                children: VehiculeStatus.values.map((s) {
                  final selected = _status == s;
                  return GestureDetector(
                    onTap: () => setState(() => _status = s),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 13,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? s.color.withOpacity(0.08)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: selected ? s.color : const Color(0xFFDDE3EE),
                          width: 1.4,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: selected ? s.color : Colors.grey.shade300,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            s.label,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: selected
                                  ? s.color
                                  : AppColors.textSecondary,
                            ),
                          ),
                          const Spacer(),
                          if (selected)
                            Icon(Icons.check_circle, color: s.color, size: 18),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

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
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: _isSaving ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.navy,
              disabledBackgroundColor: AppColors.navy.withOpacity(0.6),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isSaving
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
