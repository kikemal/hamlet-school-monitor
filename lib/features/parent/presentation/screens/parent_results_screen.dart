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

class ParentResultsScreen extends ConsumerWidget {
  const ParentResultsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultsAsync = ref.watch(childResultsProvider);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: ParentPageHeader(
            title: 'Exam Results',
            subtitle: 'View academic performance',
          ),
        ),
        resultsAsync.when(
          loading: () => const SliverToBoxAdapter(child: ParentLoadingView()),
          error: (e, _) => SliverToBoxAdapter(
            child: ParentErrorView(
              message: e.toString(),
              onRetry: () => ref.invalidate(childResultsProvider),
            ),
          ),
          data: (results) {
            if (results.isEmpty) {
              return SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Center(
                    child: Text(
                      'No exam results found',
                      style: AppTypography.bodyMedium,
                    ),
                  ),
                ),
              );
            }

            final averagePercentage = results
                .map((r) => r.percentage)
                .reduce((a, b) => a + b) / results.length;

            return SliverToBoxAdapter(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(20.w),
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(20.w),
                        child: Column(
                          children: [
                            Text(
                              'Average Performance',
                              style: AppTypography.h3,
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              '${averagePercentage.toStringAsFixed(1)}%',
                              style: AppTypography.h1.copyWith(
                                color: averagePercentage >= 60
                                    ? AppColors.success
                                    : AppColors.error,
                              ),
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
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        final result = results[index];
                        return _buildResultCard(context, result);
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

  Widget _buildResultCard(BuildContext context, ResultWithDetails result) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result.subjectName,
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        result.result.examName,
                        style: AppTypography.bodySmall.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: _getGradeColor(result.grade).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    result.grade,
                    style: AppTypography.h3.copyWith(
                      color: _getGradeColor(result.grade),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        '${result.result.marksObtained.toStringAsFixed(1)}',
                        style: AppTypography.h3,
                      ),
                      Text(
                        'Obtained',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 40.h,
                  width: 1,
                  color: AppColors.borderLight,
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        '${result.result.maxMarks.toStringAsFixed(1)}',
                        style: AppTypography.h3,
                      ),
                      Text(
                        'Maximum',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 40.h,
                  width: 1,
                  color: AppColors.borderLight,
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        '${result.percentage.toStringAsFixed(1)}%',
                        style: AppTypography.h3.copyWith(
                          color: result.percentage >= 60
                              ? AppColors.success
                              : AppColors.error,
                        ),
                      ),
                      Text(
                        'Percentage',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              'Teacher: ${result.teacherName}',
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getGradeColor(String grade) {
    switch (grade) {
      case 'A+':
      case 'A':
        return AppColors.success;
      case 'B':
        return Colors.blue;
      case 'C':
        return Colors.orange;
      default:
        return AppColors.error;
    }
  }
}
