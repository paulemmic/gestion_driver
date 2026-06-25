import 'package:flutter/material.dart';
import 'package:gestion_driver/core/theme/app_colors.dart';
import 'package:gestion_driver/features/drivers/models/chauffeur.dart';
import 'package:gestion_driver/features/drivers/presentation/pages/add_chauffeur_page.dart';
import 'package:gestion_driver/features/drivers/presentation/pages/chauffeur_profile_page.dart';
import 'package:gestion_driver/features/drivers/presentation/widgets/chauffeur_header_stats.dart';
import 'package:gestion_driver/features/drivers/presentation/widgets/chauffeur_list.dart';
import 'package:gestion_driver/features/drivers/presentation/widgets/chauffeur_search_bar.dart';
import 'package:gestion_driver/features/drivers/services/add_chauffeur.dart';
import 'package:gestion_driver/shared/widgets/fleet_app_bar.dart';

class ChauffeurPage extends StatefulWidget {
  const ChauffeurPage({super.key});

  @override
  State<ChauffeurPage> createState() => _ChauffeurPageState();
}

class _ChauffeurPageState extends State<ChauffeurPage> {
  final service = AddChauffeur();
  final searchController = TextEditingController();
  late final Stream<List<Chauffeur>> chauffeursStream;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    chauffeursStream = service.streamAll();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<Chauffeur> _filtered(List<Chauffeur> all) {
    if (searchQuery.isEmpty) return all;
    final q = searchQuery.toLowerCase();
    return all
        .where(
          (c) =>
              c.name.toLowerCase().contains(q) ||
              c.id.toLowerCase().contains(q),
        )
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: const FleetAppBar(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        heroTag: 'add_chauffeur',
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const AddChauffeurPage()),
        ),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: StreamBuilder<List<Chauffeur>>(
        stream: chauffeursStream,
        builder: (context, snapshot) {
          final allChauffeurs = snapshot.data ?? [];

          return Column(
            children: [
              ChauffeurHeaderStats(chauffeurs: allChauffeurs),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Chauffeurs',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Gérer le personnel et le statut de conformité.',
                        style: TextStyle(
                          color: AppColors.secondary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 14),
                      ChauffeurSearchBar(
                        controller: searchController,
                        onChanged: (v) =>
                            setState(() => searchQuery = v.trim()),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: switch (snapshot.connectionState) {
                          ConnectionState.waiting => const Center(
                            child: CircularProgressIndicator(),
                          ),
                          _ when snapshot.hasError => _ErrorTile(
                            message: '${snapshot.error}',
                          ),
                          _ => ChauffeurList(
                            chauffeurs: _filtered(allChauffeurs),
                            onTap: (c) => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) =>
                                    ChauffeurProfilePage(chauffeur: c),
                              ),
                            ),
                          ),
                        },
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

class _ErrorTile extends StatelessWidget {
  const _ErrorTile({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
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
