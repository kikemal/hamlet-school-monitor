import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../providers/student_providers.dart';
import '../widgets/student_error_view.dart';
import '../widgets/student_loading_view.dart';
import '../widgets/student_page_header.dart';
import '../../../shared/domain/entities/announcement.dart';

class StudentAnnouncementsScreen extends ConsumerWidget {
  const StudentAnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final announcementsAsync = ref.watch(studentAnnouncementsProvider);
    final studentAsync = ref.watch(studentProfileProvider);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: StudentPageHeader(
            title: 'Announcements',
            subtitle: 'Latest news from school',
          ),
        ],
        announcementsAsync.when(
          loading: () => const SliverToBoxAdapter(child: StudentLoadingView()),
          error: (e, _) => SliverToBoxAdapter(
            child: StudentErrorView(
              message: e.toString(),
              onRetry: () => ref.invalidate(studentAnnouncementsProvider),
            ),
          ),
          data: (announcementsList) {
            if (announcementsList.isEmpty) {
              return SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Center(
                    child: Text(
                      'No announcements',
                      style: Theme.of(context).textTheme.bodyMedium,
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
                    final announcement = announcementsList[index];
                    return _buildAnnouncementCard(context, announcement);
                  },
                  childCount: announcementsList.length,
                ),
              );
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
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.announcement,
                    color: Theme.of(context).primaryColor,
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
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (announcement.createdAt != null) ...[
                        SizedBox(height: 4.h),
                        Text(
                          '${announcement.createdAt.day}/${announcement.createdAt.month}/${announcement.createdAt.year}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isDark
                                ? Theme.of(context).colorScheme.onSurfaceVariant
                                : Theme.of(context).colorScheme.onSurfaceVariant,
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
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isDark
                    ? Theme.of(context).colorScheme.onSurfaceVariant
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}