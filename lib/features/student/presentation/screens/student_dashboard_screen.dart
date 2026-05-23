import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../providers/student_providers.dart';
import '../widgets/student_error_view.dart';
import '../widgets/student_loading_view.dart';
import '../widgets/student_page_header.dart';
import '../widgets/student_stat_card.dart';

class StudentDashboardScreen extends ConsumerWidget {
  const StudentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(studentDashboardStatsProvider);
    final student = ref.watch(selectedStudentProvider);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: StudentPageHeader(
            title: 'Dashboard',
            subtitle: student != null
                ? 'Viewing ${student.profiles.firstName}\'s progress'
                : 'Loading student info...',
          ),
        ),
        // Student selector would go here if needed (for students with multiple profiles)
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: statsAsync.when(
              loading: () => const StudentLoadingView(),
              error: (e, _) => StudentErrorView(
                message: e.toString(),
                onRetry: () => ref.invalidate(studentDashboardStatsProvider),
              ),
              data: (stats) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Overview',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    SizedBox(height: 16.h),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: MediaQuery.sizeOf(context).width > 700 ? 4 : 2,
                      mainAxisSpacing: 12.h,
                      crossAxisSpacing: 12.w,
                      childAspectRatio: 1.3,
                      children: [
                        StudentStatCard(
                          label: 'Upcoming Events',
                          value: '${stats.upcomingEvents}',
                          icon: Icons.event,
                          color: Colors.purple,
                          onTap: () => context.push('/student/calendar'),
                        ),
                        StudentStatCard(
                          label: 'Announcements',
                          value: '${stats.unreadAnnouncements}',
                          icon: Icons.announcement,
                          color: Colors.indigo,
                          onTap: () => context.push('/student/announcements'),
                        ),
                        StudentStatCard(
                          label: 'Pending Homework',
                          value: '${stats.pendingHomework}',
                          icon: Icons.assignment,
                          color: Colors.teal,
                          onTap: () => context.push('/student/homework'),
                        ),
                        StudentStatCard(
                          label: 'View Timetable',
                          value: 'Schedule',
                          icon: Icons.schedule,
                          color: Colors.blue,
                          onTap: () => context.push('/student/timetable'),
                        ),
                        StudentStatCard(
                          label: 'Exam Results',
                          value: 'Grades',
                          icon: Icons.assessment,
                          color: Colors.green,
                          onTap: () => context.push('/student/results'),
                        ),
                        StudentStatCard(
                          label: 'Attendance',
                          value: 'Record',
                          icon: Icons.calendar_today,
                          color: Colors.orange,
                          onTap: () => context.push('/student/attendance'),
                        ),
                        StudentStatCard(
                          label: 'View Profile',
                          value: 'Details',
                          icon: Icons.person,
                          color: Theme.of(context).primaryColor,
                          onTap: () => context.push('/student/profile'),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}