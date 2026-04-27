// import 'package:flutter/material.dart';
// import 'package:gestion_driver/core/theme/app_colors.dart';
// import 'package:gestion_driver/features/drivers/data/chauffeur_mock_data.dart';
// import 'package:gestion_driver/features/drivers/data/services/add_chauffeur.dart';
// import 'package:gestion_driver/features/drivers/presentation/pages/add_chauffeur_page.dart';
// import 'package:gestion_driver/features/drivers/presentation/pages/chauffeur_profile_page.dart';
// import 'package:gestion_driver/features/drivers/presentation/widgets/chauffeur_card.dart';
// import 'package:gestion_driver/shared/widgets/fleet_app_bar.dart';

// class ChauffeurPage extends StatefulWidget {
//   const ChauffeurPage({super.key});

//   @override
//   State<ChauffeurPage> createState() => _ChauffeurPageState();
// }

// class _ChauffeurPageState extends State<ChauffeurPage> {
//   final service = AddChauffeur();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.bg,
//       appBar: const FleetAppBar(),
//       floatingActionButton: FloatingActionButton(
//         backgroundColor: AppColors.navy,
//         heroTag: null,
//         onPressed: () {
//           Navigator.of(context).push(
//             MaterialPageRoute<void>(builder: (_) => const AddChauffeurPage()),
//           );
//         },
//         child: const Icon(Icons.add, color: Colors.white),
//       ),
//       body: Column(
//         children: [
//           Container(
//             color: AppColors.navy,
//             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
//             child: const Row(
//               children: [
//                 Expanded(
//                   child: StatChip(
//                     label: 'ALERTS',
//                     value: '08',
//                     valueColor: AppColors.red,
//                   ),
//                 ),
//                 _VerticalDivider(),
//                 Expanded(
//                   child: StatChip(
//                     label: 'NOTE MOYENNE',
//                     value: '4.9 ★',
//                     valueColor: Colors.white,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Expanded(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'Chauffeurs',
//                     style: TextStyle(
//                       fontSize: 26,
//                       fontWeight: FontWeight.bold,
//                       color: AppColors.textPrimary,
//                     ),
//                   ),
//                   const SizedBox(height: 2),
//                   const Text(
//                     'Gérer le personnel et le statut de conformité.',
//                     style: TextStyle(
//                       color: AppColors.textSecondary,
//                       fontSize: 13,
//                     ),
//                   ),
//                   const SizedBox(height: 14),
//                   const TextField(
//                     decoration: InputDecoration(
//                       hintText: 'Rechercher par nom ou ID...',
//                       prefixIcon: Icon(
//                         Icons.search,
//                         color: AppColors.textSecondary,
//                         size: 20,
//                       ),
//                       border: InputBorder.none,
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   for (
//                     var index = 0;
//                     index < chauffeursMockData.length;
//                     index++
//                   ) ...[
//                     ChauffeurCard(
//                       chauffeur: chauffeursMockData[index],
//                       onTap: () {
//                         Navigator.of(context).push(
//                           MaterialPageRoute<void>(
//                             builder: (_) => ChauffeurProfilePage(
//                               chauffeur: chauffeursMockData[index],
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                     if (index < chauffeursMockData.length - 1)
//                       const SizedBox(height: 12),
//                   ],
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class StatChip extends StatelessWidget {
//   const StatChip({
//     required this.label,
//     required this.value,
//     required this.valueColor,
//   });

//   final String label;
//   final String value;
//   final Color valueColor;

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Text(
//           label,
//           style: const TextStyle(
//             color: Colors.white60,
//             fontSize: 9,
//             letterSpacing: 0.5,
//           ),
//         ),
//         const SizedBox(height: 4),
//         Text(
//           value,
//           style: TextStyle(
//             color: valueColor,
//             fontSize: 22,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ],
//     );
//   }
// }

// class _VerticalDivider extends StatelessWidget {
//   const _VerticalDivider();

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 1,
//       height: 36,
//       color: Colors.white24,
//       margin: const EdgeInsets.symmetric(horizontal: 6),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:gestion_driver/core/theme/app_colors.dart';
import 'package:gestion_driver/features/drivers/models/chauffeur.dart';
import 'package:gestion_driver/features/drivers/presentation/pages/add_chauffeur_page.dart';
import 'package:gestion_driver/features/drivers/presentation/pages/chauffeur_profile_page.dart';
import 'package:gestion_driver/features/drivers/presentation/widgets/chauffeur_card.dart';
import 'package:gestion_driver/features/drivers/services/add_chauffeur.dart';
import 'package:gestion_driver/shared/widgets/fleet_app_bar.dart';

class ChauffeurPage extends StatefulWidget {
  const ChauffeurPage({super.key});

  @override
  State<ChauffeurPage> createState() => _ChauffeurPageState();
}

class _ChauffeurPageState extends State<ChauffeurPage> {
  final service = AddChauffeur();
  final _searchController = TextEditingController();
  String _searchQuery = '';

  Stream<List<Chauffeur>> get chauffeurs => service.streamAll();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Filtre local par nom ou ID
  List<Chauffeur> _filtered(List<Chauffeur> all) {
    if (_searchQuery.isEmpty) return all;
    final q = _searchQuery.toLowerCase();
    return all.where((c) {
      return c.name.toLowerCase().contains(q) || c.id.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: const FleetAppBar(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.navy,
        heroTag: 'add_chaufeur',
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const AddChauffeurPage()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: StreamBuilder<List<Chauffeur>>(
        stream: service.streamAll(),
        builder: (context, snapshot) {
          // ── Compteur d'alertes dynamique ──────────────────────────
          final allChauffeurs = snapshot.data ?? [];
          final alertCount = allChauffeurs.where((c) => !c.conforme).length;

          return Column(
            children: [
              // ── Header stats ──────────────────────────────────────
              Container(
                color: AppColors.navy,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: StatChip(
                        label: 'ALERTS',
                        value: alertCount.toString().padLeft(2, '0'),
                        valueColor: AppColors.red,
                      ),
                    ),
                    const _VerticalDivider(),
                    const Expanded(
                      child: StatChip(
                        label: 'NOTE MOYENNE',
                        value: '4.9 ★',
                        valueColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Body ──────────────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Chauffeurs',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Gérer le personnel et le statut de conformité.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // ── Barre de recherche ─────────────────────────
                      TextField(
                        controller: _searchController,
                        onChanged: (v) =>
                            setState(() => _searchQuery = v.trim()),
                        decoration: const InputDecoration(
                          hintText: 'Rechercher par nom ou ID...',
                          prefixIcon: Icon(
                            Icons.search,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── États du stream ────────────────────────────
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
                            final chauffeurs = _filtered(allChauffeurs);
                            if (chauffeurs.isEmpty) {
                              return const _EmptyState();
                            }
                            return Column(
                              children: [
                                for (var i = 0; i < chauffeurs.length; i++) ...[
                                  ChauffeurCard(
                                    chauffeur: chauffeurs[i],
                                    onTap: () => Navigator.of(context).push(
                                      MaterialPageRoute<void>(
                                        builder: (_) => ChauffeurProfilePage(
                                          chauffeur: chauffeurs[i],
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (i < chauffeurs.length - 1)
                                    const SizedBox(height: 12),
                                ],
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
              Icons.people_outline,
              size: 48,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 12),
            Text(
              'Aucun chauffeur enregistré.',
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

class StatChip extends StatelessWidget {
  const StatChip({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 9,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      color: Colors.white24,
      margin: const EdgeInsets.symmetric(horizontal: 6),
    );
  }
}
