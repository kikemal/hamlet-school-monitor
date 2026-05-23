import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../parent/domain/models/parent_models.dart';
import '../../../student/domain/models/student_models.dart';
import '../../../teacher/domain/models/teacher_models.dart';

/// Reusable homework card for teacher, student, and parent views.
class HomeworkCard extends StatelessWidget {
  const HomeworkCard({
    super.key,
    required this.title,
    required this.dueDate,
    required this.status,
    this.description,
    this.subjectName,
    this.className,
    this.submittedAt,
    this.grade,
    this.attachmentUrl,
    this.onTap,
    this.trailing,
  });

  factory HomeworkCard.fromStudent(
    StudentHomeworkWithSubmission item, {
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    final submission = item.submission;
    return HomeworkCard(
      title: item.homework.title,
      description: item.homework.description,
      dueDate: item.homework.dueDate,
      status: _displayStatus(item),
      submittedAt: submission?.createdAt,
      grade: submission?.gradedMarks,
      attachmentUrl: item.homework.attachmentUrl,
      onTap: onTap,
      trailing: trailing,
    );
  }

  factory HomeworkCard.fromParent(
    HomeworkWithSubmission item, {
    VoidCallback? onTap,
  }) {
    final submission = item.submission;
    return HomeworkCard(
      title: item.homework.title,
      description: item.homework.description,
      dueDate: item.homework.dueDate,
      status: _displayStatusParent(item),
      submittedAt: submission?.createdAt,
      grade: submission?.gradedMarks,
      attachmentUrl: item.homework.attachmentUrl,
      onTap: onTap,
    );
  }

  factory HomeworkCard.fromTeacher(
    TeacherHomeworkItem item, {
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return HomeworkCard(
      title: item.homework.title,
      description: item.homework.description,
      dueDate: item.homework.dueDate,
      status: DateTime.now().isAfter(item.homework.dueDate) ? 'overdue' : 'open',
      subjectName: item.subjectName,
      className: item.className,
      attachmentUrl: item.homework.attachmentUrl,
      onTap: onTap,
      trailing: trailing,
    );
  }

  final String title;
  final String? description;
  final DateTime dueDate;
  final String status;
  final String? subjectName;
  final String? className;
  final DateTime? submittedAt;
  final double? grade;
  final String? attachmentUrl;
  final VoidCallback? onTap;
  final Widget? trailing;

  static String _displayStatus(StudentHomeworkWithSubmission item) {
    if (item.submission?.status == 'graded') return 'graded';
    if (item.isSubmitted) return 'submitted';
    if (item.isOverdue) return 'overdue';
    return 'pending';
  }

  static String _displayStatusParent(HomeworkWithSubmission item) {
    if (item.submission?.status == 'graded') return 'graded';
    if (item.isSubmitted) return 'submitted';
    if (item.isOverdue) return 'overdue';
    return 'pending';
  }

  @override
  Widget build(BuildContext context) {
    final (statusColor, statusIcon) = _statusStyle(context, status);

    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  _StatusChip(
                    label: status.toUpperCase(),
                    color: statusColor,
                    icon: statusIcon,
                  ),
                  if (trailing != null) ...[
                    SizedBox(width: 8.w),
                    trailing!,
                  ],
                ],
              ),
              if (className != null || subjectName != null) ...[
                SizedBox(height: 6.h),
                Text(
                  [className, subjectName].whereType<String>().join(' · '),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
              if (description != null && description!.isNotEmpty) ...[
                SizedBox(height: 8.h),
                Text(
                  description!,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              SizedBox(height: 12.h),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16.w,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Due ${DateFormat.yMMMd().format(dueDate)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
              if (submittedAt != null) ...[
                SizedBox(height: 8.h),
                Text(
                  'Submitted ${DateFormat.yMMMd().format(submittedAt!)}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ],
              if (grade != null) ...[
                SizedBox(height: 4.h),
                Text(
                  'Grade: ${grade!.toStringAsFixed(1)}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
              if (attachmentUrl != null && attachmentUrl!.isNotEmpty) ...[
                SizedBox(height: 8.h),
                TextButton.icon(
                  onPressed: () async {
                    await _openUrl(attachmentUrl!);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Attachment link copied to clipboard'),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.attach_file, size: 18),
                  label: const Text('Copy attachment link'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  (Color, IconData) _statusStyle(BuildContext context, String status) {
    switch (status) {
      case 'graded':
        return (Colors.green, Icons.grade);
      case 'submitted':
        return (Theme.of(context).colorScheme.primary, Icons.check_circle);
      case 'overdue':
        return (Theme.of(context).colorScheme.error, Icons.warning);
      case 'open':
        return (Colors.blue, Icons.assignment);
      default:
        return (Theme.of(context).colorScheme.secondary, Icons.pending);
    }
  }

  Future<void> _openUrl(String url) async {
    await Clipboard.setData(ClipboardData(text: url));
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.color,
    required this.icon,
  });

  final String label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.w, color: color),
          SizedBox(width: 4.w),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
