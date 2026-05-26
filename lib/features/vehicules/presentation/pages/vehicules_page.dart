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
  final service = AddVehicules();
  final searchController = TextEditingController();
  late final Stream<List<Vehicule>> _vehiculesStream;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _vehiculesStream = service.streamAll();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<Vehicule> _filtered(List<Vehicule> all) {
    if (searchQuery.isEmpty) return all;
    final q = searchQuery.toLowerCase();
    return all
        .where((v) {
          return v.name.toLowerCase().contains(q) ||
              v.plaque.toLowerCase().contains(q) ||
              (v.vin?.toLowerCase().contains(q) ?? false);
        })
        .toList(growable: false);
  }

  Widget _buildVehiculeContent(
    BuildContext context,
    AsyncSnapshot<List<Vehicule>> snapshot,
    List<Vehicule> all,
  ) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (snapshot.hasError) {
      return _ErrorTile(message: '${snapshot.error}');
    }

    final vehicules = _filtered(all);
    if (vehicules.isEmpty) {
      return const _EmptyState();
    }

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: vehicules.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final vehicule = vehicules[index];
        return VehiculeCard(
          vehicule: vehicule,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => VehiculeDetailPage(vehicule: vehicule),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: const FleetAppBar(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        heroTag: null,
        onPressed: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const AddVehiculePage())),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: StreamBuilder<List<Vehicule>>(
        stream: _vehiculesStream,
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
                color: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: StatBlock(
                        label: 'ACTIVE MAINTENANT',
                        value: actifs.toString().padLeft(2, '0'),
                        valueColor: Colors.white,
                        dotColor: AppColors.succe,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.white24,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    Expanded(
                      child: StatBlock(
                        label: 'MAINTENANCE',
                        value: enMaintenance.toString().padLeft(2, '0'),
                        valueColor: AppColors.warning,
                        dotColor: AppColors.warning,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Body ─────────────────────────────────────────────
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Registre des véhicules',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // ── Recherche ─────────────────────────────────
                      TextField(
                        controller: searchController,
                        onChanged: (v) =>
                            setState(() => searchQuery = v.trim()),
                        decoration: const InputDecoration(
                          hintText:
                              'Recherche par modèle, plaque ou numéro VIN...',
                          prefixIcon: Icon(
                            Icons.search,
                            color: AppColors.secondary,
                            size: 20,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── États ─────────────────────────────────────
                      Expanded(
                        child: _buildVehiculeContent(context, snapshot, all),
                      ),
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

class StatBlock extends StatelessWidget {
  const StatBlock({
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
              color: AppColors.secondary,
            ),
            SizedBox(height: 12),
            Text(
              'Aucun véhicule enregistré.',
              style: TextStyle(color: AppColors.secondary, fontSize: 14),
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
        color: AppColors.accent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.accent.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.accent, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: AppColors.accent, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
