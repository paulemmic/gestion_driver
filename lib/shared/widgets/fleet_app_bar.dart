import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:gestion_driver/core/theme/app_colors.dart';
import 'package:gestion_driver/features/settings/presentation/pages/settings_page.dart';

class FleetAppBar extends StatelessWidget implements PreferredSizeWidget {
  const FleetAppBar({
    super.key,
    this.showBack = false,
    this.title,
    this.userName,
    this.avatarUrl,
    this.onSearchPressed,
    this.showSearch = true,
  });

  final bool showBack;
  final String? title;
  final String? userName;
  final String? avatarUrl;
  final VoidCallback? onSearchPressed;
  final bool showSearch;

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    final currentUser = firebase_auth.FirebaseAuth.instance.currentUser;
    final resolvedUserName = _resolveUserName(currentUser);
    final resolvedAvatarUrl = _firstNonEmpty(avatarUrl, currentUser?.photoURL);

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: AppColors.navy,
      centerTitle: false,
      leadingWidth: showBack ? 56 : 64,
      titleSpacing: showBack ? 0 : 4,
      leading: showBack
          ? IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
                size: 18,
              ),
              onPressed: () => Navigator.of(context).pop(),
            )
          : Padding(
              padding: const EdgeInsets.all(10),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SettingsPage(),
                    ),
                  );
                },
                child: CircleAvatar(
                  backgroundColor: Colors.white24,
                  foregroundImage: resolvedAvatarUrl != null
                      ? NetworkImage(resolvedAvatarUrl)
                      : null,
                  child: Text(
                    _buildInitials(resolvedUserName),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
      title: Text(
        showBack ? (title ?? 'Details') : resolvedUserName,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
        overflow: TextOverflow.ellipsis,
      ),
      actions: [
        if (showSearch)
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: onSearchPressed ?? () {},
          ),
      ],
    );
  }

  String _resolveUserName(firebase_auth.User? currentUser) {
    final explicitName = _firstNonEmpty(userName, title);
    if (explicitName != null) {
      return explicitName;
    }

    final displayName = _firstNonEmpty(currentUser?.displayName);
    if (displayName != null) {
      return displayName;
    }

    final email = _firstNonEmpty(currentUser?.email);
    if (email != null) {
      return email.split('@').first;
    }

    return 'Utilisateur';
  }

  String _buildInitials(String value) {
    final normalized = value
        .replaceAll('@', ' ')
        .replaceAll('.', ' ')
        .replaceAll('_', ' ')
        .replaceAll('-', ' ')
        .trim();

    final parts = normalized.split(RegExp(r'\s+')).where((part) {
      return part.isNotEmpty;
    }).toList();

    if (parts.isEmpty) {
      return 'U';
    }

    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  String? _firstNonEmpty(String? first, [String? second]) {
    if (first != null && first.trim().isNotEmpty) {
      return first.trim();
    }

    if (second != null && second.trim().isNotEmpty) {
      return second.trim();
    }

    return null;
  }
}
