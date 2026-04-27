import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gestion_driver/core/theme/app_colors.dart';
import 'package:gestion_driver/core/theme/app_shadows.dart';
import 'package:gestion_driver/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:gestion_driver/features/drivers/presentation/pages/chauffeur_page.dart';
import 'package:gestion_driver/features/vehicules/presentation/pages/vehicules_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardPage(),
    ChauffeurPage(),
    VehiculesPage(),
    // SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.navy,
          boxShadow: AppShadows.card,
        ),
        child: SafeArea(
          child: SizedBox(
            height: 60,
            child: Row(
              children: [
                _NavDestination(
                  icon: CupertinoIcons.square_grid_2x2,
                  label: 'DASHBOARD',
                  active: _currentIndex == 0,
                  onTap: () => setState(() => _currentIndex = 0),
                ),
                _NavDestination(
                  icon: CupertinoIcons.person,
                  label: 'CHAUFFEURS',
                  active: _currentIndex == 1,
                  onTap: () => setState(() => _currentIndex = 1),
                ),
                _NavDestination(
                  icon: CupertinoIcons.car_detailed,
                  label: 'VEHICULES',
                  active: _currentIndex == 2,
                  onTap: () => setState(() => _currentIndex = 2),
                ),
                // _NavDestination(
                //   icon: Icons.settings_outlined,
                //   label: 'SETTINGS',
                //   active: _currentIndex == 3,
                //   onTap: () => setState(() => _currentIndex = 3),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavDestination extends StatelessWidget {
  const _NavDestination({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 22,
              color: active ? AppColors.blue : AppColors.textSecondary,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                color: active ? AppColors.blue : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
