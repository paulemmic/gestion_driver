import 'package:flutter/material.dart';
import 'package:gestion_driver/core/theme/app_shadows.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key, required this.children});
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
