import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../attendance/domain/models/attendance_models.dart';
import '../../domain/models/teacher_models.dart';
import '../providers/teacher_providers.dart';
import '../widgets/teacher_class_selector.dart';
import '../widgets/teacher_error_view.dart';
import '../widgets/teacher_loading_view.dart';
import '../widgets/teacher_page_header.dart';

class TeacherAttendanceAnalyticsScreen extends ConsumerWidget {
  const TeacherAttendanceAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedClassId = ref.watch(teacherSelectedClassIdProvider);
    final monthlyAttendanceAsync = selectedClassId == null
        ? const AsyncValue<List<MonthlyAttendanceSummary>>.data([])
        : ref.watch(teacherMonthlyAttendanceProvider(6)); // Last 6 months
    final classComparisonAsync = ref.watch(teacherClassAttendanceComparisonProvider);

    return Column(
      children: [
        const TeacherPageHeader(
          title: 'Attendance Analytics',
          subtitle: 'Monthly trends and class comparison',
        ),
        const TeacherClassSelector(),
        Expanded(
          child: monthlyAttendanceAsync.when(
            loading: () => const TeacherLoadingView(),
            error: (e, _) => TeacherErrorView(
              message: e.toString(),
              onRetry: () => ref.invalidate(teacherMonthlyAttendanceProvider(6)),
            ),
            data: (monthlyData) {
              return classComparisonAsync.when(
                loading: () => const TeacherLoadingView(),
                error: (e, _) => TeacherErrorView(
                  message: e.toString(),
                  onRetry: () => ref.invalidate(teacherClassAttendanceComparisonProvider),
                ),
                data: (comparisonData) {
                  return SingleChildScrollView(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Monthly trend chart for selected class
                        if (selectedClassId != null) ...[
                          Text(
                            'Monthly Attendance Trend',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          SizedBox(
                            height: 250.h,
                            child: Card(
                              child: Padding(
                                padding: EdgeInsets.all(16.w),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Last 6 Months',
                                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(height: 12.h),
                                    monthlyData.isEmpty
                                        ? const Center(child: Text('No attendance data available'))
                                        : LineChart(
                                            LineChartData(
                                              minY: 0,
                                              maxY: 100,
                                              lineBarsData: [
                                                LineChartBarData(
                                                  spots: monthlyData
                                                      .asMap()
                                                      .entries
                                                      .map((e) => FlSpot(
                                                          e.key.toDouble(),
                                                          e.value.attendanceRate,
                                                        ))
                                                      .toList(),
                                                  isCurved: true,
                                                  color: Colors.blue,
                                                  barWidth: 3,
                                                  dotData: const FlDotData(show: true),
                                                  belowBarData: BarData(show: true),
                                                ),
                                              ],
                                              titlesData: FlTitlesData(
                                                bottomTitles: AxisTitles(
                                                  sideTitles: SideTitles(
                                                    showTitles: true,
                                                    getTitlesWidget: (value, _) {
                                                      final index = value.toInt();
                                                      if (index < 0 ||
                                                          index >= monthlyData.length) {
                                                        return const SizedBox();
                                                      }
                                                      final month = monthlyData[index].month;
                                                      return Text(
                                                        DateFormat.MMM().format(month),
                                                        style: const TextStyle(fontSize: 10),
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
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 24.h),
                        ],
                        // Class comparison chart
                        Text(
                          'Class Attendance Comparison',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        SizedBox(
                          height: 250.h,
                          child: Card(
                            child: Padding(
                              padding: EdgeInsets.all(16.w),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Attendance Rate by Class',
                                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 12.h),
                                  comparisonData.isEmpty
                                      ? const Center(child: Text('No class data available'))
                                      : BarChart(
                                          BarChartData(
                                            maxY: 100,
                                            barGroups: comparisonData
                                                .asMap()
                                                .entries
                                                .map((e) => BarChartGroupData(
                                                    x: e.key,
                                                    barRods: [
                                                      BarChartRodData(
                                                        toY: e.value.attendanceRate,
                                                        color: Colors.green,
                                                        width: 18,
                                                      ),
                                                    ],
                                                  ))
                                                .toList(),
                                            titlesData: FlTitlesData(
                                              bottomTitles: AxisTitles(
                                                sideTitles: SideTitles(
                                                  showTitles: true,
                                                  getTitlesWidget: (value, _) {
                                                    final index = value.toInt();
                                                    if (index < 0 ||
                                                        index >= comparisonData.length) {
                                                      return const SizedBox();
                                                    }
                                                    return Text(
                                                      comparisonData[index].className,
                                                      style: const TextStyle(fontSize: 9),
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
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}