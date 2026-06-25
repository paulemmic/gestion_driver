import 'package:flutter/material.dart';

class Divider extends StatelessWidget {
  const Divider({
    super.key,
    required int height,
    required int indent,
    required int endIndent,
    required Color color,
  });

  @override
  Widget build(BuildContext context) => const Divider(
    height: 1,
    indent: 50,
    endIndent: 0,
    color: Color(0xFFF0F0F0),
  );
}
