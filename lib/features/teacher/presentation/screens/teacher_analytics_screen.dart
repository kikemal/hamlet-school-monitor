import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../domain/models/teacher_models.dart';
import '../providers/teacher_providers.dart';
import '../widgets/teacher_class_selector.dart';
import '../widgets/teacher_error_view.dart';
import '../widgets/teacher_loading_view.dart';
import '../widgets/teacher_page_header.dart';

class TeacherAnalyticsScreen extends ConsumerWidget {
  const TeacherAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(teacherClassAnalyticsProvider);
    final selectedClassId = ref.watch(teacherSelectedClassIdProvider);
    final trendAsync = selectedClassId == null
        ? const AsyncValue<List<TeacherAttendanceTrendPoint>>.data([])
        : ref.watch(teacherAttendanceTrendProvider(selectedClassId));

    return Column(
      children: [
        const TeacherPageHeader(
          title: 'Class analytics',
          subtitle: 'Attendance and performance trends',
        ),
        const TeacherClassSelector(),
        Expanded(
          child: analyticsAsync.when(
            loading: () => const TeacherLoadingView(),
            error: (e, _) => TeacherErrorView(
              message: e.toString(),
              onRetry: () => ref.invalidate(teacherClassAnalyticsProvider),
            ),
            data: (classes) {
              if (classes.isEmpty) {
                return const Center(child: Text('No analytics data yet'));
              }

              return ListView(
                padding: EdgeInsets.all(16.w),
                children: [
                  SizedBox(
                    height: 260.h,
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Class comparison — attendance %',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            SizedBox(height: 12.h),
                            Expanded(
                              child: BarChart(
                                BarChartData(
                                  maxY: 100,
                                  barGroups: [
                                    for (var i = 0; i < classes.length; i++)
                                      BarChartGroupData(
                                        x: i,
                                        barRods: [
                                          BarChartRodData(
                                            toY: classes[i].attendanceRate,
                                            color: Colors.green,
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
                                          if (i < 0 || i >= classes.length) {
                                            return const SizedBox();
                                          }
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
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 28,
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
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  SizedBox(
                    height: 260.h,
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Class comparison — average marks %',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            SizedBox(height: 12.h),
                            Expanded(
                              child: BarChart(
                                BarChartData(
                                  maxY: 100,
                                  barGroups: [
                                    for (var i = 0; i < classes.length; i++)
                                      BarChartGroupData(
                                        x: i,
                                        barRods: [
                                          BarChartRodData(
                                            toY: classes[i].averageMarks,
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
                                          if (i < 0 || i >= classes.length) {
                                            return const SizedBox();
                                          }
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
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 28,
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
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  trendAsync.when(
                    loading: () => const LinearProgressIndicator(),
                    error: (e, _) => Text('Trend: $e'),
                    data: (points) {
                      if (points.isEmpty) {
                        return const Card(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Text('No attendance trend for selected class'),
                          ),
                        );
                      }
                      return Card(
                        child: Padding(
                          padding: EdgeInsets.all(16.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Attendance trend (14 days)',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              SizedBox(height: 12.h),
                              SizedBox(
                                height: 200.h,
                                child: LineChart(
                                  LineChartData(
                                    minY: 0,
                                    maxY: 100,
                                    lineBarsData: [
                                      LineChartBarData(
                                        spots: [
                                          for (var i = 0; i < points.length; i++)
                                            FlSpot(
                                              i.toDouble(),
                                              points[i].rate,
                                            ),
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
                                            if (i < 0 || i >= points.length) {
                                              return const SizedBox();
                                            }
                                            return Text(
                                              DateFormat.Md().format(points[i].date),
                                              style: const TextStyle(fontSize: 8),
                                            );
                                          },
                                        ),
                                      ),
                                      leftTitles: const AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: 28,
                                        ),
                                      ),
                                      topTitles: const AxisTitles(),
                                      rightTitles: const AxisTitles(),
                                    ),
                                    gridData: const FlGridData(show: true),
                                    borderData: FlBorderData(show: false),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  ...classes.map(
                    (c) => Card(
                      margin: EdgeInsets.only(top: 8.h),
                      child: ListTile(
                        title: Text(c.className),
                        subtitle: Text(
                          '${c.presentCount}/${c.totalAttendanceRecords} present records · '
                          '${c.resultCount} results',
                        ),
                        trailing: Text(
                          '${c.attendanceRate.toStringAsFixed(0)}% / '
                          '${c.averageMarks.toStringAsFixed(0)}%',
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
