import 'package:flutter/material.dart';
import 'package:gestion_driver/core/theme/app_colors.dart';
import 'package:gestion_driver/features/drivers/models/chauffeur.dart';
import 'package:gestion_driver/features/drivers/presentation/widgets/chauffeur_card.dart';

class ChauffeurList extends StatelessWidget {
  const ChauffeurList({
    super.key,
    required this.chauffeurs,
    required this.onTap,
  });

  final List<Chauffeur> chauffeurs;
  final void Function(Chauffeur) onTap;

  @override
  Widget build(BuildContext context) {
    if (chauffeurs.isEmpty) return const _EmptyState();

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: chauffeurs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final chauffeur = chauffeurs[index];
        return ChauffeurCard(
          chauffeur: chauffeur,
          onTap: () => onTap(chauffeur),
        );
      },
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
            Icon(Icons.people_outline, size: 48, color: AppColors.secondary),
            SizedBox(height: 12),
            Text(
              'Aucun chauffeur enregistré.',
              style: TextStyle(color: AppColors.secondary, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
