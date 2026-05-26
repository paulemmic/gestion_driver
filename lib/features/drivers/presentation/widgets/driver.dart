import 'package:flutter/material.dart';

class Divider extends StatelessWidget {
  const Divider({
    super.key,
    required int height,
    required int indent,
    required Color color,
  });
  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, indent: 46, color: Color(0xFFEEF1F7));
  }
}
