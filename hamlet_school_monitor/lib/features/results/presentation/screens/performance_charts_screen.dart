// Copyright 2026 Hamlet School Monitor. All rights reserved.
// Use of this source code is governed by a MIT-style license that can be
// found in the LICENSE file.

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../shared/providers/auth_provider.dart';
import '../../domain/models/results_models.dart';
import '../../providers/results_providers.dart';

class PerformanceChartsScreen extends ConsumerWidget {
  const PerformanceChartsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Determine who is logged in to fetch appropriate data
    final studentId = ref.watch(studentIdProvider);
    final teacherId = ref.watch(teacherIdProvider);
    final parentId = ref.watch(parentIdProvider);
    final adminId = ref.watch(adminIdProvider);

    // For simplicity, we'll show charts for:
    // - Student: their own performance over terms
    // - Teacher: class average per subject (or selected student?)
    // - Parent: child's performance
    // - Admin: school-wide analytics (maybe we have a separate screen)

    // We'll focus on student view for now, as it's the most illustrative for fl_chart.
    // We can later extend to other roles.

    final String? targetStudentId =
        studentId ?? parentId; // For parent, we'd need to know which child; we'll assume one child for now.

    if (targetStudentId == null) {
      // Teacher or admin viewing charts: we need a different approach.
      // For now, show a placeholder.
      return const Scaffold(
        body: Center(child: Text('Performance charts for teachers/admins coming soon')),
      );
    }

    final resultsAsync = ref.watch(studentResultsProvider(targetStudentId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance Charts'),
      ),
      body: resultsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (results) {
          if (results.isEmpty) {
            return const Center(child: Text('No results available to display charts'));
          }

          // Process data for charts
          // We'll create two charts:
          // 1. Line chart: GPA trend over terms (we need GPA per term from results)
          //    Since our Result entity doesn't store GPA, we'll need to compute from marks.
          //    Alternatively, we can store GPA per term in a separate entity, but for now
          //    we'll approximate by showing average percentage per term.

          // 2. Bar chart: Average percentage per subject across all terms (or latest term?)

          // Group results by term and subject
          final Map<String, List<Result>> resultsByTerm = {};
          final Map<String, List<Result>> resultsBySubject = {};

          for (final result in results) {
            // Assuming result has a term field? Our Result entity doesn't have term.
            // We need to add term to Result or fetch it differently.
            // Let's check our Result entity: it has examName, but not term.
            // We might need to adjust: either store term in Result or derive from examName.
            // For simplicity, we'll assume examName contains term info, or we ignore term for now.
            // We'll skip term grouping and just show overall subject performance.

            // For now, let's just do subject-wise average.
            resultsBySubject.putIfAbsent(result.subjectName, () => []).add(result);
          }

          // Calculate average percentage per subject
          final Map<String, double> subjectAverages = {};
          for (final entry in resultsBySubject.entries) {
            final List<Result> subjectResults = entry.value;
            final double totalPercentage =
                subjectResults.fold(0.0, (sum, r) => sum + (r.marksObtained / r.maxMarks * 100));
            subjectAverages[entry.key] = totalPercentage / subjectResults.length;
          }

          // Sort subjects by average descending
          final List<MapEntry<String, double>> sortedSubjects =
              subjectAverages.entries.toList()
                ..sort((a, b) => b.value.compareTo(a.value));

          return SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                // GPA Trend Line Chart (placeholder)
                const SizedBox(height: 20),
                Text(
                  'GPA Trend Over Terms',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 200.h,
                  child: LineChart(
                    LineChartData(
                      // We don't have term-wise GPA yet, so we'll show a dummy line.
                      lineBarsData: [
                        LineChartBarData(
                          spots: const [
                            FlSpot(0, 2.5),
                            FlSpot(1, 2.8),
                            FlSpot(2, 3.0),
                            FlSpot(3, 3.2),
                          ],
                          isCurved: true,
                          color: Theme.of(context).primaryColor,
                          barWidth: 4,
                          dotData: const FlDotData(show: true),
                        ),
                      ],
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              return Text(value.toStringAsFixed(1));
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              // We could map index to term names, but we don't have that data.
                              return Text('Term ${value.toInt() + 1}');
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: true),
                      gridData: FlGridData(show: true),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Subject Performance Bar Chart
                Text(
                  'Average Percentage by Subject',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 250.h,
                  child: BarChart(
                    BarChartData(
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          tooltipBgColor: Colors.blueGrey,
                          getTooltipItem: (
                            BarChartGroupData group,
                            int groupIndex,
                            BarChartRodData rod,
                            int rodIndex,
                          ) {
                            final String subject = sortedSubjects[groupIndex].key;
                            final double avg = sortedSubjects[groupIndex].value;
                            return BarTooltipItem(
                              '$subject\n',
                              const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              return Text('${value.toInt()}%');
                            },
                            reservedSize: 40,
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final int index = value.toInt();
                              if (index >= 0 && index < sortedSubjects.length) {
                                return SideTitleWidget(
                                  axisSide: Meta.axisSide,
                                  child: Text(
                                    sortedSubjects[index].key,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                  ),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: List.generate(
                        sortedSubjects.length,
                        (index) => BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: sortedSubjects[index].value,
                              color: Theme.of(context).primaryColor,
                              width: 20,
                              borderRadius: BorderRadius.zero,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}