import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../shared/domain/entities/attendance.dart';
import '../providers/parent_providers.dart';
import '../widgets/parent_error_view.dart';
import '../widgets/parent_loading_view.dart';
import '../widgets/parent_page_header.dart';

class ParentAttendanceScreen extends ConsumerWidget {
  const ParentAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attendanceAsync = ref.watch(childAttendanceProvider);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: ParentPageHeader(
            title: 'Attendance History',
            subtitle: 'View attendance records',
          ),
        ),
        attendanceAsync.when(
          loading: () => const SliverToBoxAdapter(child: ParentLoadingView()),
          error: (e, _) => SliverToBoxAdapter(
            child: ParentErrorView(
              message: e.toString(),
              onRetry: () => ref.invalidate(childAttendanceProvider),
            ),
          ),
          data: (attendance) {
            if (attendance.isEmpty) {
              return SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Center(
                    child: Text(
                      'No attendance records found',
                      style: AppTypography.bodyMedium,
                    ),
                  ),
                ),
              );
            }

            final presentCount = attendance.where((a) => a.status == 'present').length;
            final percentage = (presentCount / attendance.length * 100).toStringAsFixed(1);

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
                              style: AppTypography.h3,
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              '$percentage%',
                              style: AppTypography.h1.copyWith(
                                color: double.parse(percentage) >= 75
                                    ? AppColors.success
                                    : AppColors.error,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              '$presentCount out of ${attendance.length} days present',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondaryLight,
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
                      itemCount: attendance.length,
                      itemBuilder: (context, index) {
                        final record = attendance[index];
                        return _buildAttendanceCard(context, record);
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

  Widget _buildAttendanceCard(BuildContext context, Attendance record) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isPresent = record.status == 'present';

    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: isPresent
                    ? AppColors.success.withOpacity(0.1)
                    : AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                isPresent ? Icons.check_circle : Icons.cancel,
                color: isPresent ? AppColors.success : AppColors.error,
                size: 24.w,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${record.date.day}/${record.date.month}/${record.date.year}',
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    record.status.toUpperCase(),
                    style: AppTypography.bodySmall.copyWith(
                      color: isPresent ? AppColors.success : AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (record.remarks != null) ...[
              SizedBox(width: 12.w),
              Icon(Icons.info_outline, size: 20.w, color: AppColors.textSecondaryLight),
            ],
          ],
        ),
      ),
    );
  }
}
