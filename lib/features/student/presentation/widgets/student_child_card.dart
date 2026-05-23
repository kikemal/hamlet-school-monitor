import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/models/student_models.dart';

/// Reusable student card for displaying student information
class StudentChildCard extends StatelessWidget {
  const StudentChildCard({
    super.key,
    required this.student,
    required this.onTap,
    this.isSelected = false,
  });

  final Student student;
  final VoidCallback onTap;
  final bool isSelected;

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
              ? Theme.of(context).primaryColor.withOpacity(0.1)
              : (isDark ? Theme.of(context).colorScheme.surfaceVariant : Theme.of(context).colorScheme.surface),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
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
              child: student.profiles.avatarUrl != null
                  ? CachedNetworkImage(
                      imageUrl: student.profiles.avatarUrl!,
                      width: 60.w,
                      height: 60.w,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 60.w,
                        height: 60.w,
                        color: Theme.of(context).dividerColor,
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 60.w,
                        height: 60.w,
                        color: Theme.of(context).dividerColor,
                        child: Icon(Icons.person, size: 30.w),
                      ),
                    )
                  : Container(
                      width: 60.w,
                      height: 60.w,
                      color: Theme.of(context).dividerColor,
                      child: Icon(Icons.person, size: 30.w),
                    ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${student.profiles.firstName} ${student.profiles.lastName}',
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? Theme.of(context).colorScheme.onSurfaceVariant
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${student.schoolClasses?.name ?? 'Unassigned'}',
                    style: AppTypography.bodySmall.copyWith(
                      color: isDark
                          ? Theme.of(context).colorScheme.onSurfaceVariant
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  // Student-specific stats could go here
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}