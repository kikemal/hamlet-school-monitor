import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../providers/student_providers.dart';
import '../widgets/student_error_view.dart';
import '../widgets/student_loading_view.dart';
import '../widgets/student_page_header.dart';
import '../../domain/models/student_models.dart';

class StudentHomeworkScreen extends ConsumerWidget {
  const StudentHomeworkScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeworkAsync = ref.watch(studentHomeworkProvider);
    final studentAsync = ref.watch(studentProfileProvider);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: StudentPageHeader(
            title: 'Homework',
            subtitle: 'View assignments and submissions',
          ),
        ],
        homeworkAsync.when(
          loading: () => const SliverToBoxAdapter(child: StudentLoadingView()),
          error: (e, _) => SliverToBoxAdapter(
            child: StudentErrorView(
              message: e.toString(),
              onRetry: () => ref.invalidate(studentHomeworkProvider),
            ),
          ),
          data: (homeworkList) {
            if (homeworkList.isEmpty) {
              return SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Center(
                    child: Text(
                      'No homework found',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
              );
            }

            final pendingCount = homeworkList.where((h) => !h.isSubmitted).length;

            return SliverToBoxAdapter(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(20.w),
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(20.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                Text(
                                  '$pendingCount',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontSize: 24.sp,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  'Pending',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  '${homeworkList.length - pendingCount}',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontSize: 24.sp,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  'Submitted',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: homeworkList.length,
                      itemBuilder: (context, index) {
                        final homework = homeworkList[index];
                        return _buildHomeworkCard(context, homework);
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildHomeworkCard(BuildContext context, StudentHomeworkWithSubmission hw) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final status = hw.status;

    Color statusColor;
    IconData statusIcon;

    switch (status) {
      case 'submitted':
        statusColor = Theme.of(context).colorScheme.primary;
        statusIcon = Icons.check_circle;
        break;
      case 'overdue':
        statusColor = Theme.of(context).colorScheme.error;
        statusIcon = Icons.warning;
        break;
      default:
        statusColor = Theme.of(context).colorScheme.secondary;
        statusIcon = Icons.pending;
    }

    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    hw.homework.title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 16.w, color: statusColor),
                      SizedBox(width: 4.w),
                      Text(
                        status.toUpperCase(),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (hw.homework.description != null) ...[
              SizedBox(height: 8.h),
              Text(
                hw.homework.description!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark
                      ? Theme.of(context).colorScheme.onSurfaceVariant
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            SizedBox(height: 12.h),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16.w, color: Theme.of(context).colorScheme.onSurfaceVariant),
                SizedBox(width: 8.w),
                Text(
                  'Due: ${hw.homework.dueDate.day}/${hw.homework.dueDate.month}/${hw.homework.dueDate.year}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            if (hw.isSubmitted && hw.submission != null) ...[
              SizedBox(height: 8.h),
              Text(
                'Submitted on: ${hw.submission!.submittedAt.day}/${hw.submission!.submittedAt.month}/${hw.submission!.submittedAt.year}',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              if (hw.submission!.grade != null) ...[
                SizedBox(height: 4.h),
                Text(
                  'Grade: ${hw.submission!.grade!.toStringAsFixed(1)}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}