import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../providers/student_providers.dart';
import '../widgets/student_error_view.dart';
import '../widgets/student_loading_view.dart';
import '../widgets/student_page_header.dart';
import '../../../shared/domain/entities/attendance.dart';

class StudentAttendanceScreen extends ConsumerWidget {
  const StudentAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attendanceAsync = ref.watch(studentAttendanceProvider);
    final studentAsync = ref.watch(studentProfileProvider);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: StudentPageHeader(
            title: 'Attendance History',
            subtitle: 'View attendance records',
          ),
        ],
        attendanceAsync.when(
          loading: () => const SliverToBoxAdapter(child: StudentLoadingView()),
          error: (e, _) => SliverToBoxAdapter(
            child: StudentErrorView(
              message: e.toString(),
              onRetry: () => ref.invalidate(studentAttendanceProvider),
            ),
          ),
          data: (attendanceSummary) {
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
                              'Overall Attendance',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              '${attendanceSummary.attendancePercentage.toStringAsFixed(1)}%',
                              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                fontSize: 32.sp,
                                fontWeight: FontWeight.bold,
                                color: attendanceSummary.attendancePercentage >= 75
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.error,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              '${attendanceSummary.presentDays} out of ${attendanceSummary.totalDays} days present',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Detailed attendance list would go here if we had the full history
                  // For now, we're showing the summary from the provider
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Text(
                      'Attendance Details',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(20.w),
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildAttendanceInfo(
                                'Present Days', attendanceSummary.presentDays.toString()),
                            _buildAttendanceInfo(
                                'Absent Days', attendanceSummary.absentDays.toString()),
                            _buildAttendanceInfo(
                                'Late Days', attendanceSummary.lateDays.toString()),
                            _buildAttendanceInfo(
                                'Total Days', attendanceSummary.totalDays.toString()),
                          ],
                        ),
                      ),
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

  Widget _buildAttendanceInfo(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}