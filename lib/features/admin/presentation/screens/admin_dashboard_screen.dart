import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../providers/admin_providers.dart';
import '../widgets/admin_error_view.dart';
import '../widgets/admin_loading_view.dart';
import '../widgets/admin_page_header.dart';
import '../widgets/admin_stat_card.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminDashboardStatsProvider);
    final schoolAsync = ref.watch(adminSchoolProvider);

    return statsAsync.when(
      loading: () => const AdminLoadingView(),
      error: (e, _) => AdminErrorView(
        message: e.toString(),
        onRetry: () => ref.invalidate(adminDashboardStatsProvider),
      ),
      data: (stats) {
        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: AdminPageHeader(
                title: 'Overview',
                subtitle: schoolAsync.value?.name ?? 'School analytics',
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: MediaQuery.sizeOf(context).width > 700 ? 4 : 2,
                  mainAxisSpacing: 12.h,
                  crossAxisSpacing: 12.w,
                  childAspectRatio: 1.3,
                ),
                delegate: SliverChildListDelegate([
                  AdminStatCard(
                    label: 'Students',
                    value: '${stats.studentCount}',
                    icon: Icons.school,
                  ),
                  AdminStatCard(
                    label: 'Teachers',
                    value: '${stats.teacherCount}',
                    icon: Icons.person,
                    color: Colors.teal,
                  ),
                  AdminStatCard(
                    label: 'Parents',
                    value: '${stats.parentCount}',
                    icon: Icons.family_restroom,
                    color: Colors.orange,
                  ),
                  AdminStatCard(
                    label: 'Classes',
                    value: '${stats.classCount}',
                    icon: Icons.class_,
                    color: Colors.purple,
                  ),
                  AdminStatCard(
                    label: 'Pending fees',
                    value: '${stats.pendingFees}',
                    icon: Icons.payments,
                    color: Colors.redAccent,
                  ),
                  AdminStatCard(
                    label: 'Upcoming events',
                    value: '${stats.upcomingEvents}',
                    icon: Icons.event,
                    color: Colors.indigo,
                  ),
                  AdminStatCard(
                    label: 'Attendance rate',
                    value: '${stats.attendanceRate.toStringAsFixed(1)}%',
                    icon: Icons.fact_check,
                    color: Colors.green,
                  ),
                  AdminStatCard(
                    label: 'Avg. marks',
                    value: '${stats.averageMarks.toStringAsFixed(1)}%',
                    icon: Icons.grade,
                    color: Colors.amber,
                  ),
                ]),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: SizedBox(
                  height: 220.h,
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Performance snapshot', style: Theme.of(context).textTheme.titleMedium),
                          SizedBox(height: 16.h),
                          Expanded(
                            child: BarChart(
                              BarChartData(
                                alignment: BarChartAlignment.spaceAround,
                                maxY: 100,
                                barGroups: [
                                  BarChartGroupData(
                                    x: 0,
                                    barRods: [
                                      BarChartRodData(
                                        toY: stats.attendanceRate,
                                        color: Colors.green,
                                        width: 24,
                                      ),
                                    ],
                                  ),
                                  BarChartGroupData(
                                    x: 1,
                                    barRods: [
                                      BarChartRodData(
                                        toY: stats.averageMarks,
                                        color: Colors.blue,
                                        width: 24,
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
                                    sideTitles: SideTitles(showTitles: true, reservedSize: 32),
                                  ),
                                  topTitles: const AxisTitles(),
                                  rightTitles: const AxisTitles(),
                                ),
                                gridData: const FlGridData(show: false),
                                borderData: FlBorderData(show: false),
                              ),
                            ),
                          ),
                        ],
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
