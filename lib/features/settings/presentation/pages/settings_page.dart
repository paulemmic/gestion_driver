import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gestion_driver/core/theme/app_colors.dart';
import 'package:gestion_driver/core/theme/app_shadows.dart';
import 'package:gestion_driver/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:gestion_driver/features/auth/presentation/cubit/auth_state.dart';
import 'package:gestion_driver/features/settings/presentation/pages/notification_settings_page.dart';
import 'package:gestion_driver/features/settings/presentation/pages/profile_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Paramètres'),
        centerTitle: false,
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Profile summary card ─────────────────────────────────────
              _ProfileSummaryCard(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfilePage()),
                ),
              ),
              const SizedBox(height: 20),

              // ── Compte ───────────────────────────────────────────────────
              _SettingsGroup(
                title: 'Compte',
                tiles: [
                  _SettingsTile(
                    icon: Icons.person_outline,
                    title: 'Modifier le profil',
                    subtitle: 'Nom, email, téléphone',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfilePage()),
                    ),
                  ),
                  _SettingsTile(
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    subtitle: 'Alertes et fréquences',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NotificationSettingsPage(),
                      ),
                    ),
                  ),
                  _SettingsTile(
                    icon: Icons.lock_outline,
                    title: 'Sécurité',
                    subtitle: 'Mot de passe, authentification',
                    onTap: () {
                      // TODO: navigate to security settings
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              _SettingsGroup(
                title: 'Gestion de flotte',
                tiles: [
                  _SettingsTile(
                    icon: Icons.local_shipping_outlined,
                    title: 'Véhicules',
                    subtitle: 'Gestion des véhicules',
                    onTap: () {},
                  ),
                  _SettingsTile(
                    icon: Icons.assignment_outlined,
                    title: 'Conformité',
                    subtitle: 'Règles et conformité',
                    onTap: () {},
                  ),
                  _SettingsTile(
                    icon: Icons.people_outline,
                    title: 'Équipe',
                    subtitle: 'Accès et permissions',
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Support ──────────────────────────────────────────────────
              _SettingsGroup(
                title: 'Support',
                tiles: [
                  _SettingsTile(
                    icon: Icons.help_outline,
                    title: 'Aide',
                    onTap: () {},
                  ),
                  _SettingsTile(
                    icon: Icons.info_outline,
                    title: 'À propos',
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileSummaryCard extends StatelessWidget {
  const _ProfileSummaryCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final user = state is Authenticated ? state.user : null;
        if (user == null) return const SizedBox.shrink();

        return GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: AppShadows.subtle,
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: const Icon(
                    Icons.person,
                    color: AppColors.primary,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name.isNotEmpty
                            ? user.name[0].toUpperCase()
                            : 'Utilisateur',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user.role != null
                            ? user.role![0].toUpperCase()
                            : 'Rôle inconnu',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.secondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Voir le profil →',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.secondary,
                  size: 20,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.title, required this.tiles});

  final String title;
  final List<Widget> tiles;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: AppColors.secondary,
            fontSize: 10,
            letterSpacing: 0.8,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: AppShadows.subtle,
          ),
          child: Column(
            children: List.generate(tiles.length, (i) {
              return Column(
                children: [
                  tiles[i],
                  if (i < tiles.length - 1)
                    const Divider(
                      height: 1,
                      indent: 50,
                      color: Color(0xFFF0F0F0),
                    ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.primary,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.secondary,
                      ),
                    ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.secondary,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
