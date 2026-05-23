import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../providers/student_providers.dart';
import '../widgets/student_error_view.dart';
import '../widgets/student_loading_view.dart';
import '../widgets/student_page_header.dart';
import '../../domain/models/student_models.dart';

class StudentResultsScreen extends ConsumerWidget {
  const StudentResultsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultsAsync = ref.watch(studentResultsProvider);
    final studentAsync = ref.watch(studentProfileProvider);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: StudentPageHeader(
            title: 'Exam Results',
            subtitle: 'View academic performance',
          ),
        ],
        resultsAsync.when(
          loading: () => const SliverToBoxAdapter(child: StudentLoadingView()),
          error: (e, _) => SliverToBoxAdapter(
            child: StudentErrorView(
              message: e.toString(),
              onRetry: () => ref.invalidate(studentResultsProvider),
            ),
          ),
          data: (resultsList) {
            if (resultsList.isEmpty) {
              return SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Center(
                    child: Text(
                      'No exam results found',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
              );
            }

            final averagePercentage = resultsList
                .map((r) => r.percentage)
                .reduce((a, b) => a + b) / resultsList.length;

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
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              '${averagePercentage.toStringAsFixed(1)}%',
                              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                fontSize: 32.sp,
                                fontWeight: FontWeight.bold,
                                color: averagePercentage >= 60
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.error,
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
                      itemCount: resultsList.length,
                      itemBuilder: (context, index) {
                        final result = resultsList[index];
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

  Widget _buildResultCard(BuildContext context, StudentResultWithDetails result) {
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
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        result.result.examName,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? Theme.of(context).colorScheme.onSurfaceVariant
                              : Theme.of(context).colorScheme.onSurfaceVariant,
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
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontSize: 24.sp,
                        ),
                      ),
                      Text(
                        'Obtained',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 40.h,
                  width: 1,
                  color: Theme.of(context).dividerColor,
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        '${result.result.maxMarks.toStringAsFixed(1)}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontSize: 24.sp,
                        ),
                      ),
                      Text(
                        'Maximum',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 40.h,
                  width: 1,
                  color: Theme.of(context).dividerColor,
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        '${result.percentage.toStringAsFixed(1)}%',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontSize: 24.sp,
                          color: result.percentage >= 60
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.error,
                        ),
                      ),
                      Text(
                        'Percentage',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
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
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
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
        return Theme.of(context).colorScheme.primary;
      case 'B':
        return Theme.of(context).colorScheme.secondary;
      case 'C':
        return Theme.of(context).colorScheme.tertiary;
      default:
        return Theme.of(context).colorScheme.error;
    }
  }
}