import 'package:flutter/material.dart';

class BehaviourSeverityChip extends StatelessWidget {
  const BehaviourSeverityChip({super.key, required this.severity});

  final String severity;

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (severity.toLowerCase()) {
      'minor' || 'low' => (Colors.amber, 'Minor'),
      'serious' || 'high' => (Colors.red, 'Serious'),
      'moderate' || 'medium' => (Colors.orange, 'Moderate'),
      _ => (Colors.orange, 'Moderate'),
    };

    return Chip(
      label: Text(label),
      backgroundColor: color.withValues(alpha: 0.15),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.w600),
      visualDensity: VisualDensity.compact,
    );
  }
}
