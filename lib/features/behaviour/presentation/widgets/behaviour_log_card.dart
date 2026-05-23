import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../domain/models/behaviour_models.dart';
import '../../../teacher/presentation/widgets/behaviour_severity_chip.dart';

/// Reusable behaviour / discipline log card.
class BehaviourLogCard extends StatelessWidget {
  const BehaviourLogCard({
    super.key,
    required this.item,
    this.onDelete,
    this.showStudentName = true,
    this.showTeacherName = false,
  });

  final BehaviourLogDisplayItem item;
  final VoidCallback? onDelete;
  final bool showStudentName;
  final bool showTeacherName;

  @override
  Widget build(BuildContext context) {
    final isPositive = item.isPositive;
    final typeColor = isPositive ? Colors.green : Colors.redAccent;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 18.r,
                  backgroundColor: typeColor.withValues(alpha: 0.15),
                  child: Icon(
                    isPositive ? Icons.thumb_up : Icons.warning_amber,
                    color: typeColor,
                    size: 20.w,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (showStudentName && item.studentName != null)
                        Text(
                          item.studentName!,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      Text(
                        DateFormat.yMMMd().format(item.log.date),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      if (showTeacherName && item.teacherName != null) ...[
                        SizedBox(height: 4.h),
                        Text(
                          'By ${item.teacherName}',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ],
                  ),
                ),
                if (!isPositive)
                  BehaviourSeverityChip(severity: item.severity),
                if (onDelete != null)
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: onDelete,
                  ),
              ],
            ),
            SizedBox(height: 12.h),
            Text(item.notes),
          ],
        ),
      ),
    );
  }
}
