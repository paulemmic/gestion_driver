import 'package:flutter/material.dart';
import 'package:gestion_driver/core/theme/app_colors.dart';

enum VidangeStatus { ok, bientot, depasse }

extension VidangeStatusExt on VidangeStatus {
  Color get color => switch (this) {
    VidangeStatus.ok => AppColors.succe,
    VidangeStatus.bientot => AppColors.warning,
    VidangeStatus.depasse => AppColors.accent,
  };

  String get label => switch (this) {
    VidangeStatus.ok => 'À jour',
    VidangeStatus.bientot => 'Bientôt',
    VidangeStatus.depasse => 'Dépassée',
  };
}

class VidangeCard extends StatelessWidget {
  const VidangeCard({super.key, required this.kilometrage});

  final int kilometrage;

  /// Intervalle standard entre deux vidanges (modifiable)
  static const int intervalle = 10000;

  int get _prochaine {
    final done = (kilometrage ~/ intervalle);
    return (done + 1) * intervalle;
  }

  int get _restant => _prochaine - kilometrage;

  VidangeStatus get _status {
    if (_restant <= 0) return VidangeStatus.depasse;
    if (_restant <= 1000) return VidangeStatus.bientot;
    return VidangeStatus.ok;
  }

  double get _progress {
    final remaining = _restant.clamp(0, intervalle);
    return remaining / intervalle;
  }

  @override
  Widget build(BuildContext context) {
    final status = _status;
    final restant = _restant;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: status.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.oil_barrel_outlined,
                  size: 18,
                  color: status.color,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Prochaine vidange',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: status.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: status.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      status.label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: status.color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: _progress.clamp(0.0, 1.0),
              minHeight: 7,
              backgroundColor: AppColors.bg,
              valueColor: AlwaysStoppedAnimation<Color>(status.color),
            ),
          ),
          const SizedBox(height: 12),

          // ── Chiffres ──────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _KmBlock(
                label: 'Actuel',
                value: '${_fmt(kilometrage)} km',
                color: AppColors.black,
              ),
              _KmBlock(
                label: restant > 0 ? 'Restant' : 'Dépassement',
                value: '${_fmt(restant.abs())} km',
                color: status.color,
                bold: true,
              ),
              _KmBlock(
                label: 'À faire à',
                value: '${_fmt(_prochaine)} km',
                color: AppColors.primary,
              ),
            ],
          ),

          if (status != VidangeStatus.ok) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: status.color.withOpacity(0.07),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 14, color: status.color),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      status == VidangeStatus.depasse
                          ? 'Vidange dépassée de ${_fmt(restant.abs())} km. Intervention recommandée.'
                          : 'Vidange à prévoir dans ${_fmt(restant)} km.',
                      style: TextStyle(
                        fontSize: 11,
                        color: status.color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _fmt(int n) {
    // Formatage avec espace comme séparateur des milliers : 12000 → "12 000"
    return n.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+$)'),
      (m) => '${m[1]} ',
    );
  }
}

class _KmBlock extends StatelessWidget {
  const _KmBlock({
    required this.label,
    required this.value,
    required this.color,
    this.bold = false,
  });

  final String label;
  final String value;
  final Color color;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.secondary,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
