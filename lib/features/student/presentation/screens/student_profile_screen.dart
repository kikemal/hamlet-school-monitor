import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../behaviour/presentation/providers/behaviour_providers.dart';
import '../../../behaviour/presentation/widgets/behaviour_summary_chip.dart';
import '../providers/student_providers.dart';
import '../widgets/student_error_view.dart';
import '../widgets/student_loading_view.dart';
import '../widgets/student_page_header.dart';
import '../../../shared/domain/entities/student.dart';

class StudentProfileScreen extends ConsumerWidget {
  const StudentProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(studentProfileProvider);
    final behaviourSummary = ref.watch(studentBehaviourSummaryProvider);

    return profileAsync.when(
      loading: () => const StudentLoadingView(),
      error: (e, _) => Scaffold(
        body: StudentErrorView(
          message: e.toString(),
          onRetry: () => ref.invalidate(studentProfileProvider),
        ),
      ),
      data: (student) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: StudentPageHeader(
                title: 'My Profile',
                subtitle: '${student.profiles.firstName} ${student.profiles.lastName}',
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
                              child: student.profiles.avatarUrl != null
                                  ? CachedNetworkImage(
                                      imageUrl: student.profiles.avatarUrl!,
                                      width: 80.w,
                                      height: 80.w,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(
                                        width: 80.w,
                                        height: 80.w,
                                        color: Theme.of(context).dividerColor,
                                        child: const Center(
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) => Container(
                                        width: 80.w,
                                        height: 80.w,
                                        color: Theme.of(context).dividerColor,
                                        child: Icon(Icons.person, size: 40.w),
                                      ),
                                    )
                                  : Container(
                                      width: 80.w,
                                      height: 80.w,
                                      color: Theme.of(context).dividerColor,
                                      child: Icon(Icons.person, size: 40.w),
                                    ),
                            ),
                            SizedBox(width: 20.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${student.profiles.firstName} ${student.profiles.lastName}',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    '${student.schoolClasses?.name ?? 'Unassigned'}',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: isDark
                                          ? Theme.of(context).colorScheme.onSurfaceVariant
                                          : Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  if (student.schoolClasses?.section != null) ...[
                                    SizedBox(height: 4.h),
                                    Text(
                                      'Section: ${student.schoolClasses!.section}',
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
                        SizedBox(height: 24.h),
                        behaviourSummary.when(
                          loading: () => const SizedBox.shrink(),
                          error: (_, __) => const SizedBox.shrink(),
                          data: (summary) => Padding(
                            padding: EdgeInsets.only(bottom: 16.h),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: BehaviourSummaryChip(summary: summary),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStat(
                              'Roll Number',
                              student.rollNumber ?? 'Not set',
                            ),
                            _buildStat(
                              'Class',
                              student.schoolClasses?.name ?? 'Unassigned',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Additional sections can be added here (contact info, etc.)
          ],
        );
      },
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}