import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:table_calendar/table_calendar.dart';

import '../providers/student_providers.dart';
import '../widgets/student_error_view.dart';
import '../widgets/student_loading_view.dart';
import '../widgets/student_page_header.dart';
import '../../../shared/domain/entities/timetable.dart';

class StudentTimetableScreen extends ConsumerStatefulWidget {
  const StudentTimetableScreen({super.key});

  @override
  ConsumerState<StudentTimetableScreen> createState() => _StudentTimetableScreenState();
}

class _StudentTimetableScreenState extends ConsumerState<StudentTimetableScreen> {
  // For timetable, we'll show it as a weekly schedule rather than calendar
  // This could be enhanced with a proper timetable view later

  @override
  Widget build(BuildContext context) {
    final timetableAsync = ref.watch(studentTimetableProvider);
    final studentAsync = ref.watch(studentProfileProvider);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: StudentPageHeader(
            title: 'Timetable',
            subtitle: 'View your class schedule',
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: studentAsync.when(
              loading: () => const StudentLoadingView(),
              error: (e, _) => StudentErrorView(
                message: e.toString(),
                onRetry: () => ref.invalidate(studentProfileProvider),
              ),
              data: (student) {
                return timetableAsync.when(
                  loading: () => const StudentLoadingView(),
                  error: (e, _) => StudentErrorView(
                    message: e.toString(),
                    onRetry: () => ref.invalidate(studentTimetableProvider),
                  ),
                  data: (timetableItems) {
                    if (timetableItems.isEmpty) {
                      return Center(
                        child: Text(
                          'No timetable found',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      );
                    }

                    // Group timetable items by day
                    final Map<String, List<StudentTimetableItem>> groupedByDay = {};
                    for (final item in timetableItems) {
                      final day = item.day;
                      if (!groupedByDay.containsKey(day)) {
                        groupedByDay[day] = [];
                      }
                      groupedByDay[day]!.add(item);
                    }

                    // Sort days in weekday order
                    final dayOrder = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                    final sortedDays = groupedByDay.keys
                        .where((day) => dayOrder.contains(day))
                        .toList()
                        .sort((a, b) => dayOrder.indexOf(a).compareTo(dayOrder.indexOf(b)));

                    return ListView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: dayOrder
                          .where((day) => groupedByDay.containsKey(day))
                          .map((day) => _buildDaySection(
                                context,
                                day,
                                groupedByDay[day]!,
                              ))
                          .toList(),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDaySection(
      BuildContext context, String day, List<StudentTimetableItem> items) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                topRight: Radius.circular(16.r),
              ),
            ),
            child: Text(
              day,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: Theme.of(context).dividerColor,
            ),
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                leading: Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.access_time,
                    color: Theme.of(context).primaryColor,
                    size: 20.w,
                  ),
                ),
                title: Text(
                  item.subjectName,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${item.className} • ${item.timeRange}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      'Teacher: ${item.teacherName}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 10.sp,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}