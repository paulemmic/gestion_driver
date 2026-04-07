import 'package:flutter/material.dart';

class DashboardOverviewItem {
  const DashboardOverviewItem({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;
}
