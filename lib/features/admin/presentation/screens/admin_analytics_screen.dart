import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../providers/admin_providers.dart';
import '../widgets/admin_error_view.dart';
import '../widgets/admin_loading_view.dart';
import '../widgets/admin_page_header.dart';

class AdminAnalyticsScreen extends ConsumerWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classAsync = ref.watch(adminClassPerformanceProvider);
    final subjectAsync = ref.watch(adminSubjectTrendsProvider);

    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(child: AdminPageHeader(
          title: 'Performance analytics',
          subtitle: 'Class vs class and subject trends',
        )),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Text('Class comparison', style: Theme.of(context).textTheme.titleMedium),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 260.h,
            child: classAsync.when(
              loading: () => const AdminLoadingView(),
              error: (e, _) => AdminErrorView(message: e.toString()),
              data: (classes) => Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: BarChart(
                  BarChartData(
                    maxY: 100,
                    barGroups: [
                      for (var i = 0; i < classes.length; i++)
                        BarChartGroupData(
                          x: i,
                          barRods: [
                            BarChartRodData(
                              toY: classes[i].averagePercentage,
                              color: Colors.blue,
                              width: 18,
                            ),
                          ],
                        ),
                    ],
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (v, _) {
                            final i = v.toInt();
                            if (i < 0 || i >= classes.length) return const SizedBox();
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                classes[i].className,
                                style: const TextStyle(fontSize: 9),
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: true, reservedSize: 28),
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
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 8.h),
            child: Text('Subject trends', style: Theme.of(context).textTheme.titleMedium),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 260.h,
            child: subjectAsync.when(
              loading: () => const AdminLoadingView(),
              error: (e, _) => AdminErrorView(message: e.toString()),
              data: (subjects) => Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: LineChart(
                  LineChartData(
                    minY: 0,
                    maxY: 100,
                    lineBarsData: [
                      LineChartBarData(
                        spots: [
                          for (var i = 0; i < subjects.length; i++)
                            FlSpot(i.toDouble(), subjects[i].averagePercentage),
                        ],
                        isCurved: true,
                        color: Colors.teal,
                        barWidth: 3,
                        dotData: const FlDotData(show: true),
                      ),
                    ],
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (v, _) {
                            final i = v.toInt();
                            if (i < 0 || i >= subjects.length) return const SizedBox();
                            return Text(subjects[i].subjectName, style: const TextStyle(fontSize: 9));
                          },
                        ),
                      ),
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: true, reservedSize: 28),
                      ),
                      topTitles: const AxisTitles(),
                      rightTitles: const AxisTitles(),
                    ),
                    gridData: const FlGridData(show: true),
                    borderData: FlBorderData(show: false),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
