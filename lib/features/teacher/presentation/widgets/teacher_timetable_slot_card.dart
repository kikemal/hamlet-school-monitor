import 'package:flutter/material.dart';

import '../../domain/models/teacher_models.dart';

class TeacherTimetableSlotCard extends StatelessWidget {
  const TeacherTimetableSlotCard({super.key, required this.slot});

  final TeacherTimetableSlot slot;

  @override
  Widget build(BuildContext context) {
    final color = _colorForSubject(slot.subjectName);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.2),
          child: Icon(Icons.menu_book, color: color, size: 20),
        ),
        title: Text(slot.subjectName, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('${slot.className} · ${slot.timeRange}'),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }

  Color _colorForSubject(String name) {
    final colors = [
      Colors.blue,
      Colors.teal,
      Colors.orange,
      Colors.purple,
      Colors.pink,
    ];
    return colors[name.hashCode.abs() % colors.length];
  }
}
