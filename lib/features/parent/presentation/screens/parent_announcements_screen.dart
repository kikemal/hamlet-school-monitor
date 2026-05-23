import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../shared/domain/entities/announcement.dart';
import '../providers/parent_providers.dart';
import '../widgets/parent_error_view.dart';
import '../widgets/parent_loading_view.dart';
import '../widgets/parent_page_header.dart';

class ParentAnnouncementsScreen extends ConsumerWidget {
  const ParentAnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final announcementsAsync = ref.watch(parentAnnouncementsProvider);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: ParentPageHeader(
            title: 'Announcements',
            subtitle: 'Latest news from school',
          ),
        ),
        announcementsAsync.when(
          loading: () => const SliverToBoxAdapter(child: ParentLoadingView()),
          error: (e, _) => SliverToBoxAdapter(
            child: ParentErrorView(
              message: e.toString(),
              onRetry: () => ref.invalidate(parentAnnouncementsProvider),
            ),
          ),
          data: (announcements) {
            if (announcements.isEmpty) {
              return SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Center(
                    child: Text(
                      'No announcements',
                      style: AppTypography.bodyMedium,
                    ),
                  ),
                ),
              );
            }

            return SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final announcement = announcements[index];
                    return _buildAnnouncementCard(context, announcement);
                  },
                  childCount: announcements.length,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAnnouncementCard(BuildContext context, Announcement announcement) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.announcement,
                    color: AppColors.primary,
                    size: 24.w,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        announcement.title,
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (announcement.createdAt != null) ...[
                        SizedBox(height: 4.h),
                        Text(
                          _formatDate(announcement.createdAt!),
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
            SizedBox(height: 12.h),
            Text(
              announcement.content,
              style: AppTypography.bodyMedium.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
