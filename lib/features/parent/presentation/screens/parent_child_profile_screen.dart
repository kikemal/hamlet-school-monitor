import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../behaviour/presentation/providers/behaviour_providers.dart';
import '../../../behaviour/presentation/widgets/behaviour_summary_chip.dart';
import '../providers/parent_providers.dart';
import '../widgets/parent_error_view.dart';
import '../widgets/parent_loading_view.dart';
import '../widgets/parent_page_header.dart';

class ParentChildProfileScreen extends ConsumerWidget {
  const ParentChildProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(childProfileProvider);
    final behaviourSummary = ref.watch(childBehaviourSummaryProvider);

    return profileAsync.when(
      loading: () => const ParentLoadingView(),
      error: (e, _) => Scaffold(
        body: ParentErrorView(
          message: e.toString(),
          onRetry: () => ref.invalidate(childProfileProvider),
        ),
      ),
      data: (profile) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: ParentPageHeader(
                title: 'Child Profile',
                subtitle: profile.summary.fullName,
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(20.w),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20.r),
                              child: profile.summary.photoUrl != null
                                  ? CachedNetworkImage(
                                      imageUrl: profile.summary.photoUrl!,
                                      width: 80.w,
                                      height: 80.w,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(
                                        width: 80.w,
                                        height: 80.w,
                                        color: AppColors.borderLight,
                                        child: const Center(
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) => Container(
                                        width: 80.w,
                                        height: 80.w,
                                        color: AppColors.borderLight,
                                        child: Icon(Icons.person, size: 40.w),
                                      ),
                                    )
                                  : Container(
                                      width: 80.w,
                                      height: 80.w,
                                      color: AppColors.borderLight,
                                      child: Icon(Icons.person, size: 40.w),
                                    ),
                            ),
                            SizedBox(width: 20.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    profile.summary.fullName,
                                    style: AppTypography.h3,
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    profile.summary.className,
                                    style: AppTypography.bodyMedium.copyWith(
                                      color: isDark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondaryLight,
                                    ),
                                  ),
                                  if (profile.summary.section != null) ...[
                                    SizedBox(height: 4.h),
                                    Text(
                                      'Section: ${profile.summary.section}',
                                      style: AppTypography.bodySmall.copyWith(
                                        color: isDark
                                            ? AppColors.textSecondaryDark
                                            : AppColors.textSecondaryLight,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 24.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStat(
                              'GPA',
                              profile.summary.gpa.toStringAsFixed(2),
                              AppColors.primary,
                            ),
                            _buildStat(
                              'Attendance',
                              '${profile.summary.attendancePercentage.toStringAsFixed(0)}%',
                              profile.summary.attendancePercentage >= 75
                                  ? AppColors.success
                                  : AppColors.error,
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        behaviourSummary.when(
                          loading: () => const SizedBox.shrink(),
                          error: (_, __) => const SizedBox.shrink(),
                          data: (summary) => Align(
                            alignment: Alignment.centerLeft,
                            child: BehaviourSummaryChip(summary: summary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Personal Information',
                          style: AppTypography.h3,
                        ),
                        SizedBox(height: 16.h),
                        _buildInfoRow('Date of Birth',
                            profile.dateOfBirth != null
                                ? '${profile.dateOfBirth!.day}/${profile.dateOfBirth!.month}/${profile.dateOfBirth!.year}'
                                : 'Not set'),
                        _buildInfoRow('Enrollment Date',
                            profile.enrollmentDate != null
                                ? '${profile.enrollmentDate!.day}/${profile.enrollmentDate!.month}/${profile.enrollmentDate!.year}'
                                : 'Not set'),
                        if (profile.rollNumber != null)
                          _buildInfoRow('Roll Number', profile.rollNumber!),
                        if (profile.bloodGroup != null)
                          _buildInfoRow('Blood Group', profile.bloodGroup!),
                        if (profile.allergies != null)
                          _buildInfoRow('Allergies', profile.allergies!),
                        if (profile.emergencyContact != null)
                          _buildInfoRow('Emergency Contact', profile.emergencyContact!),
                        if (profile.address != null)
                          _buildInfoRow('Address', profile.address!),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.h2.copyWith(color: color),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.w,
            child: Text(
              label,
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondaryLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
