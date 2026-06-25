import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gestion_driver/core/theme/app_colors.dart';
import 'package:gestion_driver/core/theme/app_shadows.dart';
import 'package:gestion_driver/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:gestion_driver/features/auth/presentation/cubit/auth_state.dart';
import 'package:gestion_driver/features/drivers/presentation/widgets/section_label.dart';
import 'package:gestion_driver/features/settings/presentation/widgets/action_title.dart';
import 'package:gestion_driver/features/settings/presentation/widgets/profile_card.dart';
import 'package:gestion_driver/features/settings/presentation/widgets/profile_field.dart';

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
    final user = context.read<AuthCubit>().state is Authenticated
        ? (context.read<AuthCubit>().state as Authenticated).user
        : null;
    nameController = TextEditingController(text: user?.name ?? '');
    emailController = TextEditingController(text: user?.email ?? '');
    phoneController = TextEditingController(text: user?.phone ?? '');
    roleController = TextEditingController(text: user?.role ?? '');
    licenseController = TextEditingController(text: user?.licenseNumber ?? '');
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
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is! Authenticated) {
          Navigator.of(context).pop();
        }
      },
      builder: (context, state) {
        final user = state is Authenticated ? state.user : null;
        if (user == null) return const SizedBox.shrink();
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
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.2,
                              ),
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
                          user.name.isNotEmpty
                              ? user.name[0].toUpperCase()
                              : 'Utilisateur',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user.email.isNotEmpty
                              ? user.email
                              : 'utilisateur@example.com',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Container(
                        //   padding: const EdgeInsets.symmetric(
                        //     horizontal: 12,
                        //     vertical: 4,
                        //   ),
                        //   decoration: BoxDecoration(
                        //     color: Colors.white.withValues(alpha: 0.2),
                        //     borderRadius: BorderRadius.circular(20),
                        //   ),
                        //   child: Text(
                        //     user.role?.isNotEmpty == true
                        //         ? user.role!
                        //         : 'Rôle non défini',
                        //     style: const TextStyle(
                        //       color: Colors.white,
                        //       fontSize: 12,
                        //       fontWeight: FontWeight.w500,
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),

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
                              const Divider(
                                height: 1,
                                indent: 50,
                                endIndent: 0,
                                color: Color(0xFFF0F0F0),
                              ),
                              ProfileField(
                                icon: Icons.mail_outline,
                                label: 'Adresse e-mail',
                                controller: emailController,
                                enabled: isEditing,
                                keyboardType: TextInputType.emailAddress,
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return 'Champ requis';
                                  }
                                  if (!v.contains('@')) return 'Email invalide';
                                  return null;
                                },
                              ),
                              const Divider(
                                height: 1,
                                indent: 50,
                                endIndent: 0,
                                color: Color(0xFFF0F0F0),
                              ),
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
                              const Divider(
                                height: 1,
                                indent: 50,
                                endIndent: 0,
                                color: Color(0xFFF0F0F0),
                              ),
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
                              // ActionTile(
                              //   icon: Icons.lock_outline,
                              //   label: 'Changer le mot de passe',
                              //   onTap: () {
                              //     // TODO: navigate to change password
                              //   },
                              // ),
                              const Divider(
                                height: 1,
                                indent: 50,
                                endIndent: 0,
                                color: Color(0xFFF0F0F0),
                              ),
                              ActionTile(
                                icon: Icons.logout,
                                label: 'Se déconnecter',
                                color: Colors.red.shade600,
                                onTap: () {
                                  final authCubit = context.read<AuthCubit>();
                                  authCubit.logout();
                                },
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
      },
    );
  }
}
