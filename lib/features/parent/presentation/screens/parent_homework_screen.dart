import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/models/parent_models.dart';
import '../providers/parent_providers.dart';
import '../widgets/parent_error_view.dart';
import '../widgets/parent_loading_view.dart';
import '../widgets/parent_page_header.dart';

class ParentHomeworkScreen extends ConsumerWidget {
  const ParentHomeworkScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeworkAsync = ref.watch(childHomeworkProvider);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: ParentPageHeader(
            title: 'Homework',
            subtitle: 'View assignments and submissions',
          ),
        ),
        homeworkAsync.when(
          loading: () => const SliverToBoxAdapter(child: ParentLoadingView()),
          error: (e, _) => SliverToBoxAdapter(
            child: ParentErrorView(
              message: e.toString(),
              onRetry: () => ref.invalidate(childHomeworkProvider),
            ),
          ),
          data: (homework) {
            if (homework.isEmpty) {
              return SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Center(
                    child: Text(
                      'No homework found',
                      style: AppTypography.bodyMedium,
                    ),
                  ),
                ),
              );
            }

            final pendingCount = homework.where((h) => !h.isSubmitted).length;

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
                                  style: AppTypography.h2,
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  'Pending',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.textSecondaryLight,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  '${homework.length - pendingCount}',
                                  style: AppTypography.h2,
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  'Submitted',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.textSecondaryLight,
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
                      itemCount: homework.length,
                      itemBuilder: (context, index) {
                        final hw = homework[index];
                        return _buildHomeworkCard(context, hw);
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

  Widget _buildHomeworkCard(BuildContext context, HomeworkWithSubmission hw) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final status = hw.status;

    Color statusColor;
    IconData statusIcon;

    switch (status) {
      case 'submitted':
        statusColor = AppColors.success;
        statusIcon = Icons.check_circle;
        break;
      case 'overdue':
        statusColor = AppColors.error;
        statusIcon = Icons.warning;
        break;
      default:
        statusColor = Colors.orange;
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
                    style: AppTypography.bodyMedium.copyWith(
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
                        style: AppTypography.caption.copyWith(
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
                style: AppTypography.bodySmall.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
            ],
            SizedBox(height: 12.h),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16.w, color: AppColors.textSecondaryLight),
                SizedBox(width: 8.w),
                Text(
                  'Due: ${hw.homework.dueDate.day}/${hw.homework.dueDate.month}/${hw.homework.dueDate.year}',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
            if (hw.isSubmitted && hw.submission != null) ...[
              SizedBox(height: 8.h),
              Text(
                'Submitted on: ${hw.submission!.submittedAt.day}/${hw.submission!.submittedAt.month}/${hw.submission!.submittedAt.year}',
                style: AppTypography.caption.copyWith(
                  color: AppColors.success,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
