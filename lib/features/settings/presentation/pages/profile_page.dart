import 'package:flutter/material.dart';
import 'package:gestion_driver/core/theme/app_colors.dart';
import 'package:gestion_driver/core/theme/app_shadows.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final formKey = GlobalKey<FormState>();
  bool isEditing = false;

  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController roleController;
  late TextEditingController licenseController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: 'Jean-Baptiste Kouamé');
    emailController = TextEditingController(text: 'jb.kouame@fleet.ci');
    phoneController = TextEditingController(text: '+225 07 00 12 34 56');
    roleController = TextEditingController(text: 'Gestionnaire de flotte');
    licenseController = TextEditingController(text: 'CI-ABJ-2021-0045');
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    roleController.dispose();
    licenseController.dispose();
    super.dispose();
  }

  void toggleEdit() {
    if (isEditing) {
      if (formKey.currentState!.validate()) {
        setState(() => isEditing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
                SizedBox(width: 10),
                Text('Profil mis à jour avec succès'),
              ],
            ),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } else {
      setState(() => isEditing = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Mon profil'),
        centerTitle: false,
        backgroundColor: AppColors.primary,
        elevation: 0,
        actions: [
          TextButton.icon(
            onPressed: toggleEdit,
            icon: Icon(
              isEditing ? Icons.check : Icons.edit_outlined,
              color: Colors.white,
              size: 18,
            ),
            label: Text(
              isEditing ? 'Enregistrer' : 'Modifier',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ── Header gradient ──────────────────────────────────────
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(28),
                    bottomRight: Radius.circular(28),
                  ),
                ),
                padding: const EdgeInsets.only(bottom: 32, top: 8),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 48,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          child: const CircleAvatar(
                            radius: 44,
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.person,
                              size: 50,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        if (isEditing)
                          GestureDetector(
                            onTap: () {},
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: AppShadows.subtle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 16,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      nameController.text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        roleController.text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Form ─────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      SectionLabel(label: 'Informations personnelles'),
                      const SizedBox(height: 10),
                      ProfileCard(
                        children: [
                          ProfileField(
                            icon: Icons.person_outline,
                            label: 'Nom complet',
                            controller: nameController,
                            enabled: isEditing,
                            validator: (v) => (v == null || v.isEmpty)
                                ? 'Champ requis'
                                : null,
                          ),
                          const _Divider(),
                          ProfileField(
                            icon: Icons.mail_outline,
                            label: 'Adresse e-mail',
                            controller: emailController,
                            enabled: isEditing,
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Champ requis';
                              if (!v.contains('@')) return 'Email invalide';
                              return null;
                            },
                          ),
                          const _Divider(),
                          ProfileField(
                            icon: Icons.phone_outlined,
                            label: 'Téléphone',
                            controller: phoneController,
                            enabled: isEditing,
                            keyboardType: TextInputType.phone,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SectionLabel(label: 'Informations professionnelles'),
                      const SizedBox(height: 10),
                      ProfileCard(
                        children: [
                          ProfileField(
                            icon: Icons.work_outline,
                            label: 'Rôle',
                            controller: roleController,
                            enabled: isEditing,
                          ),
                          const _Divider(),
                          ProfileField(
                            icon: Icons.badge_outlined,
                            label: 'Numéro de licence',
                            controller: licenseController,
                            enabled: isEditing,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SectionLabel(label: 'Sécurité'),
                      const SizedBox(height: 10),
                      ProfileCard(
                        children: [
                          ActionTile(
                            icon: Icons.lock_outline,
                            label: 'Changer le mot de passe',
                            onTap: () {
                              // TODO: navigate to change password
                            },
                          ),
                          const _Divider(),
                          ActionTile(
                            icon: Icons.logout,
                            label: 'Se déconnecter',
                            color: Colors.red.shade600,
                            onTap: () {},
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Helpers ──────────────────────────────────────────────────────────────────

class SectionLabel extends StatelessWidget {
  const SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Text(
    label.toUpperCase(),
    style: const TextStyle(
      color: AppColors.secondary,
      fontSize: 10,
      letterSpacing: 0.8,
      fontWeight: FontWeight.w700,
    ),
  );
}

class ProfileCard extends StatelessWidget {
  const ProfileCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: AppShadows.subtle,
    ),
    child: Column(children: children),
  );
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) => const Divider(
    height: 1,
    indent: 50,
    endIndent: 0,
    color: Color(0xFFF0F0F0),
  );
}

class ProfileField extends StatelessWidget {
  const ProfileField({
    required this.icon,
    required this.label,
    required this.controller,
    required this.enabled,
    this.keyboardType,
    this.validator,
  });

  final IconData icon;
  final String label;
  final TextEditingController controller;
  final bool enabled;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 14),
          Expanded(
            child: TextFormField(
              controller: controller,
              enabled: enabled,
              keyboardType: keyboardType,
              validator: validator,
              style: const TextStyle(fontSize: 14, color: AppColors.primary),
              decoration: InputDecoration(
                labelText: label,
                labelStyle: const TextStyle(
                  fontSize: 11,
                  color: AppColors.secondary,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primary, width: 1.5),
                ),
                disabledBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                isDense: true,
              ),
            ),
          ),
          if (enabled)
            const Icon(Icons.edit, color: AppColors.secondary, size: 14),
        ],
      ),
    );
  }
}

class ActionTile extends StatelessWidget {
  const ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: c, size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label, style: TextStyle(fontSize: 14, color: c)),
            ),
            Icon(
              Icons.chevron_right,
              color: color ?? AppColors.secondary,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
