import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../behaviour/domain/models/behaviour_models.dart';
import '../../domain/models/parent_models.dart';

class ParentChildCard extends StatelessWidget {
  const ParentChildCard({
    super.key,
    required this.child,
    required this.onTap,
    this.isSelected = false,
    this.behaviourSummary,
  });

  final ChildSummary child;
  final VoidCallback onTap;
  final bool isSelected;
  final BehaviourSummary? behaviourSummary;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(right: 12.w),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : (isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
              blurRadius: 12.r,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: child.photoUrl != null
                  ? CachedNetworkImage(
                      imageUrl: child.photoUrl!,
                      width: 60.w,
                      height: 60.w,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 60.w,
                        height: 60.w,
                        color: AppColors.borderLight,
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 60.w,
                        height: 60.w,
                        color: AppColors.borderLight,
                        child: Icon(Icons.person, size: 30.w),
                      ),
                    )
                  : Container(
                      width: 60.w,
                      height: 60.w,
                      color: AppColors.borderLight,
                      child: Icon(Icons.person, size: 30.w),
                    ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    child.fullName,
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    child.className,
                    style: AppTypography.bodySmall.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      _buildStat(
                        'GPA',
                        child.gpa.toStringAsFixed(2),
                        AppColors.primary,
                      ),
                      SizedBox(width: 12.w),
                      _buildStat(
                        'Attendance',
                        '${child.attendancePercentage.toStringAsFixed(0)}%',
                        child.attendancePercentage >= 75
                            ? AppColors.success
                            : AppColors.error,
                      ),
                    ],
                  ),
                  if (behaviourSummary != null && behaviourSummary!.total > 0) ...[
                    SizedBox(height: 8.h),
                    Text(
                      'Behaviour: ${behaviourSummary!.headline}',
                      style: AppTypography.caption.copyWith(
                        color: behaviourSummary!.serious > 0
                            ? AppColors.error
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: AppTypography.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }
}
