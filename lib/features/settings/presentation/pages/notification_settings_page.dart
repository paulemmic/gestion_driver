import 'package:flutter/material.dart';
import 'package:gestion_driver/core/theme/app_colors.dart';
import 'package:gestion_driver/core/theme/app_shadows.dart';
import 'package:gestion_driver/features/drivers/presentation/widgets/section_label.dart';

enum AlertFrequency { twicePerDay, twicePerWeek }

extension AlertFrequencyLabel on AlertFrequency {
  String get label {
    switch (this) {
      case AlertFrequency.twicePerDay:
        return '2× par jour';
      case AlertFrequency.twicePerWeek:
        return '2× par semaine';
    }
  }

  String get sublabel {
    switch (this) {
      case AlertFrequency.twicePerDay:
        return 'Matin (8h) & après-midi (16h)';
      case AlertFrequency.twicePerWeek:
        return 'Lundi & jeudi à 9h';
    }
  }

  IconData get icon {
    switch (this) {
      case AlertFrequency.twicePerDay:
        return Icons.today_outlined;
      case AlertFrequency.twicePerWeek:
        return Icons.date_range_outlined;
    }
  }
}

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool notificationsEnabled = true;

  bool fuelAlerts = true;
  bool maintenanceAlerts = true;
  bool routeAlerts = false;
  bool documentAlerts = true;
  bool incidentAlerts = true;

  AlertFrequency fuelFrequency = AlertFrequency.twicePerDay;
  AlertFrequency maintenanceFrequency = AlertFrequency.twicePerWeek;
  AlertFrequency routeFrequency = AlertFrequency.twicePerDay;
  AlertFrequency documentFrequency = AlertFrequency.twicePerWeek;
  AlertFrequency incidentFrequency = AlertFrequency.twicePerDay;

  void save() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
            SizedBox(width: 10),
            Text('Preférences de notifications enregistrées'),
          ],
        ),
        backgroundColor: AppColors.primary,
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
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: false,
        backgroundColor: AppColors.primary,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: save,
            child: const Text(
              'Enregistrer',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Master switch ────────────────────────────────────────
              MasterSwitch(
                value: notificationsEnabled,
                onChanged: (v) => setState(() => notificationsEnabled = v),
              ),
              const SizedBox(height: 20),

              if (notificationsEnabled) ...[
                // ── Info banner ──────────────────────────────────────
                InfoBanner(
                  message:
                      'Choisissez la fréquence pour chaque type d\'alerte. '
                      'Les notifications "2× par jour" sont envoyées à 8h et 16h. '
                      'Les "2× par semaine" sont envoyées le lundi et le jeudi à 9h.',
                ),
                const SizedBox(height: 20),

                // ── Alert categories ─────────────────────────────────
                SectionLabel(label: 'Types d\'alertes'),
                const SizedBox(height: 10),
                AlertCategoryCard(
                  icon: Icons.local_gas_station_outlined,
                  title: 'Carburant',
                  subtitle: 'Niveaux bas, remplissages',
                  enabled: fuelAlerts,
                  frequency: fuelFrequency,
                  onToggle: (v) => setState(() => fuelAlerts = v),
                  onFrequencyChanged: (f) => setState(() => fuelFrequency = f),
                ),
                const SizedBox(height: 10),
                AlertCategoryCard(
                  icon: Icons.build_outlined,
                  title: 'Maintenance',
                  subtitle: 'Révisions, pannes, contrôles',
                  enabled: maintenanceAlerts,
                  frequency: maintenanceFrequency,
                  onToggle: (v) => setState(() => maintenanceAlerts = v),
                  onFrequencyChanged: (f) =>
                      setState(() => maintenanceFrequency = f),
                ),
                const SizedBox(height: 10),
                AlertCategoryCard(
                  icon: Icons.route_outlined,
                  title: 'Itinéraires',
                  subtitle: 'Déviations, retards, missions',
                  enabled: routeAlerts,
                  frequency: routeFrequency,
                  onToggle: (v) => setState(() => routeAlerts = v),
                  onFrequencyChanged: (f) => setState(() => routeFrequency = f),
                ),
                const SizedBox(height: 10),
                AlertCategoryCard(
                  icon: Icons.description_outlined,
                  title: 'Documents',
                  subtitle: 'Permis, assurance, visite technique',
                  enabled: documentAlerts,
                  frequency: documentFrequency,
                  onToggle: (v) => setState(() => documentAlerts = v),
                  onFrequencyChanged: (f) =>
                      setState(() => documentFrequency = f),
                ),
                const SizedBox(height: 10),
                AlertCategoryCard(
                  icon: Icons.warning_amber_outlined,
                  title: 'Incidents',
                  subtitle: 'Accidents, infractions, anomalies',
                  enabled: incidentAlerts,
                  frequency: incidentFrequency,
                  onToggle: (v) => setState(() => incidentAlerts = v),
                  onFrequencyChanged: (f) =>
                      setState(() => incidentFrequency = f),
                ),
                const SizedBox(height: 24),
              ] else ...[
                // DisabledState(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class MasterSwitch extends StatelessWidget {
  const MasterSwitch({required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppShadows.subtle,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: (value ? AppColors.primary : Colors.grey.shade300)
                  .withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.notifications_outlined,
              color: value ? AppColors.primary : Colors.grey.shade400,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Notifications actives',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  value
                      ? 'Vous recevez des alertes selon vos préférences'
                      : 'Aucune alerte ne sera envoyée',
                  style: TextStyle(
                    fontSize: 11,
                    color: value ? AppColors.secondary : Colors.red.shade400,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class InfoBanner extends StatelessWidget {
  const InfoBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: AppColors.primary, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 11.5,
                color: AppColors.primary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AlertCategoryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool enabled;
  final AlertFrequency frequency;
  final ValueChanged<bool> onToggle;
  final ValueChanged<AlertFrequency> onFrequencyChanged;

  const AlertCategoryCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.enabled,
    required this.frequency,
    required this.onToggle,
    required this.onFrequencyChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppShadows.subtle,
        border: Border.all(
          color: enabled
              ? AppColors.primary.withOpacity(0.18)
              : Colors.transparent,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: (enabled ? AppColors.primary : Colors.grey.shade300)
                        .withOpacity(0.12),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(
                    icon,
                    color: enabled ? AppColors.primary : Colors.grey.shade400,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: enabled
                              ? AppColors.primary
                              : AppColors.secondary,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: enabled,
                  onChanged: onToggle,
                  activeColor: AppColors.primary,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
          ),
          if (enabled) ...[
            const Divider(
              height: 1,
              indent: 16,
              endIndent: 16,
              color: Color(0xFFF0F0F0),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'FRÉQUENCE',
                    style: TextStyle(
                      fontSize: 9.5,
                      letterSpacing: 0.7,
                      fontWeight: FontWeight.w700,
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: AlertFrequency.values.map((f) {
                      final selected = frequency == f;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => onFrequencyChanged(f),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            margin: EdgeInsets.only(
                              right: f == AlertFrequency.twicePerDay ? 6 : 0,
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 8,
                            ),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.primary.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  f.icon,
                                  size: 18,
                                  color: selected
                                      ? Colors.white
                                      : AppColors.primary,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  f.label,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: selected
                                        ? Colors.white
                                        : AppColors.primary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  f.sublabel,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    color: selected
                                        ? Colors.white.withOpacity(0.85)
                                        : AppColors.secondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
