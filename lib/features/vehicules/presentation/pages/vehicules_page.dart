import 'package:flutter/material.dart';
import 'package:gestion_driver/core/theme/app_colors.dart';
import 'package:gestion_driver/features/vehicules/models/vehicule.dart';
import 'package:gestion_driver/features/vehicules/presentation/pages/add_vehicule_page.dart';
import 'package:gestion_driver/features/vehicules/presentation/pages/vehicule_detail_page.dart';
import 'package:gestion_driver/features/vehicules/presentation/widgets/vehicule_card.dart';
import 'package:gestion_driver/features/vehicules/services/add_vehicules.dart';
import 'package:gestion_driver/shared/widgets/fleet_app_bar.dart';

class VehiculesPage extends StatefulWidget {
  const VehiculesPage({super.key});

  @override
  State<VehiculesPage> createState() => _VehiculesPageState();
}

class _VehiculesPageState extends State<VehiculesPage> {
  final _service = AddVehicules();
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Vehicule> _filtered(List<Vehicule> all) {
    if (_searchQuery.isEmpty) return all;
    final q = _searchQuery.toLowerCase();
    return all.where((v) {
      return v.name.toLowerCase().contains(q) ||
          v.plaque.toLowerCase().contains(q) ||
          (v.vin?.toLowerCase().contains(q) ?? false);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: const FleetAppBar(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.navy,
        heroTag: null,
        onPressed: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const AddVehiculePage())),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: StreamBuilder<List<Vehicule>>(
        stream: _service.streamAll(),
        builder: (context, snapshot) {
          final all = snapshot.data ?? [];
          final actifs = all.where((v) => v.statut == 'Actif').length;
          final enMaintenance = all
              .where((v) => v.statut == 'En maintenance')
              .length;

          return Column(
            children: [
              // ── Header stats dynamiques ──────────────────────────
              Container(
                color: AppColors.navy,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _StatBlock(
                        label: 'ACTIVE NOW',
                        value: actifs.toString().padLeft(2, '0'),
                        valueColor: Colors.white,
                        dotColor: AppColors.green,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.white24,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    Expanded(
                      child: _StatBlock(
                        label: 'MAINTENANCE',
                        value: enMaintenance.toString().padLeft(2, '0'),
                        valueColor: AppColors.red,
                        dotColor: AppColors.red,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Body ─────────────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Registre des véhicules',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // ── Recherche ─────────────────────────────────
                      TextField(
                        controller: _searchController,
                        onChanged: (v) =>
                            setState(() => _searchQuery = v.trim()),
                        decoration: const InputDecoration(
                          hintText:
                              'Recherche par modèle, plaque ou numéro VIN...',
                          prefixIcon: Icon(
                            Icons.search,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── États ─────────────────────────────────────
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) ...[
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 40),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ] else if (snapshot.hasError) ...[
                        _ErrorTile(message: '${snapshot.error}'),
                      ] else ...[
                        Builder(
                          builder: (_) {
                            final vehicules = _filtered(all);
                            if (vehicules.isEmpty) {
                              return const _EmptyState();
                            }
                            return Column(
                              children: [
                                for (var i = 0; i < vehicules.length; i++) ...[
                                  VehiculeCard(
                                    vehicule: vehicules[i],
                                    onTap: () => Navigator.of(context).push(
                                      MaterialPageRoute<void>(
                                        builder: (_) => VehiculeDetailPage(
                                          vehicule: vehicules[i],
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (i < vehicules.length - 1)
                                    const SizedBox(height: 14),
                                ],
                                const SizedBox(height: 80),
                              ],
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─── Widgets utilitaires ──────────────────────────────────────────────────────

class _StatBlock extends StatelessWidget {
  const _StatBlock({
    required this.label,
    required this.value,
    required this.valueColor,
    required this.dotColor,
  });

  final String label;
  final String value;
  final Color valueColor;
  final Color dotColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 9,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            Text(
              value,
              style: TextStyle(
                color: valueColor,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 6),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.directions_car_outlined,
              size: 48,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 12),
            Text(
              'Aucun véhicule enregistré.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorTile extends StatelessWidget {
  const _ErrorTile({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.red.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.red, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: AppColors.red, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
