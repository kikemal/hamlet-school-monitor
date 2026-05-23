import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/models/teacher_models.dart';
import 'behaviour_severity_chip.dart';

class BehaviourLogCard extends StatelessWidget {
  const BehaviourLogCard({
    super.key,
    required this.item,
    this.onDelete,
  });

  final TeacherBehaviourItem item;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final isPositive = item.log.incidentType == 'positive';
    final typeColor = isPositive ? Colors.green : Colors.redAccent;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: typeColor.withValues(alpha: 0.15),
                  child: Icon(
                    isPositive ? Icons.thumb_up : Icons.warning_amber,
                    color: typeColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.studentName,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      Text(
                        DateFormat.yMMMd().format(item.log.date),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                BehaviourSeverityChip(severity: item.severity),
                if (onDelete != null)
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: onDelete,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(item.notes),
          ],
        ),
      ),
    );
  }
}
