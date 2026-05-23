import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../admin/presentation/widgets/admin_stat_card.dart';
import '../providers/teacher_providers.dart';
import '../widgets/teacher_error_view.dart';
import '../widgets/teacher_loading_view.dart';
import '../widgets/teacher_page_header.dart';
import '../widgets/teacher_timetable_slot_card.dart';

class TeacherDashboardScreen extends ConsumerWidget {
  const TeacherDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(teacherDashboardStatsProvider);
    final timetableAsync = ref.watch(teacherTimetableProvider);
    final today = DateTime.now().weekday;

    return statsAsync.when(
      loading: () => const TeacherLoadingView(),
      error: (e, _) => TeacherErrorView(
        message: e.toString(),
        onRetry: () => ref.invalidate(teacherDashboardStatsProvider),
      ),
      data: (stats) {
        final todaySlots = timetableAsync.value
                ?.where((s) => s.timetable.dayOfWeek == today)
                .toList() ??
            [];

        return CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(
              child: TeacherPageHeader(
                title: 'Good day!',
                subtitle: 'Your teaching overview',
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: MediaQuery.sizeOf(context).width > 700 ? 3 : 2,
                  mainAxisSpacing: 12.h,
                  crossAxisSpacing: 12.w,
                  childAspectRatio: 1.35,
                ),
                delegate: SliverChildListDelegate([
                  AdminStatCard(
                    label: 'Classes',
                    value: '${stats.classCount}',
                    icon: Icons.class_,
                    color: Colors.purple,
                  ),
                  AdminStatCard(
                    label: 'Students',
                    value: '${stats.studentCount}',
                    icon: Icons.school,
                    color: Colors.teal,
                  ),
                  AdminStatCard(
                    label: "Today's lessons",
                    value: '${stats.todaysLessons}',
                    icon: Icons.schedule,
                    color: Colors.indigo,
                  ),
                  AdminStatCard(
                    label: 'Open homework',
                    value: '${stats.openHomework}',
                    icon: Icons.assignment,
                    color: Colors.orange,
                  ),
                  AdminStatCard(
                    label: 'Attendance',
                    value: '${stats.attendanceRate.toStringAsFixed(0)}%',
                    icon: Icons.fact_check,
                    color: Colors.green,
                  ),
                  AdminStatCard(
                    label: 'Avg. marks',
                    value: '${stats.averageMarks.toStringAsFixed(0)}%',
                    icon: Icons.grade,
                    color: Colors.amber,
                  ),
                ]),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Today's schedule",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        SizedBox(height: 12.h),
                        if (todaySlots.isEmpty)
                          const Text('No lessons scheduled today — enjoy your break!')
                        else
                          ...todaySlots.take(4).map(
                                (s) => TeacherTimetableSlotCard(slot: s),
                              ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
                child: SizedBox(
                  height: 200.h,
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.w),
                      child: BarChart(
                        BarChartData(
                          maxY: 100,
                          barGroups: [
                            BarChartGroupData(
                              x: 0,
                              barRods: [
                                BarChartRodData(
                                  toY: stats.attendanceRate,
                                  color: Colors.green,
                                  width: 28,
                                ),
                              ],
                            ),
                            BarChartGroupData(
                              x: 1,
                              barRods: [
                                BarChartRodData(
                                  toY: stats.averageMarks,
                                  color: Colors.blue,
                                  width: 28,
                                ),
                              ],
                            ),
                          ],
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (v, _) => Text(
                                  v.toInt() == 0 ? 'Attend.' : 'Marks',
                                  style: const TextStyle(fontSize: 11),
                                ),
                              ),
                            ),
                            leftTitles: const AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 32,
                              ),
                            ),
                            topTitles: const AxisTitles(),
                            rightTitles: const AxisTitles(),
                          ),
                          gridData: const FlGridData(show: false),
                          borderData: FlBorderData(show: false),
                        ),
                      ),
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
}
