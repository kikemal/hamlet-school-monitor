// Copyright 2026 Hamlet School Monitor. All rights reserved.
// Use of this source code is governed by a MIT-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';

import '../../../../core/services/pdf_export_service.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../domain/models/results_models.dart';
import '../../data/repositories/results_repository.dart';
import '../../providers/results_providers.dart';

class ReportCardScreen extends ConsumerStatefulWidget {
  const ReportCardScreen({super.key, this.studentId});

  final String? studentId;

  @override
  ConsumerState<ReportCardScreen> createState() => _ReportCardScreenState();
}

class _ReportCardScreenState extends ConsumerState<ReportCardScreen> {
  bool _isGeneratingPDF = false;

  String? _getStudentId(WidgetRef ref) {
    // If studentId is passed as parameter (from route), use it
    if (widget.studentId != null && widget.studentId!.isNotEmpty) {
      return widget.studentId;
    }
    
    // Otherwise, determine based on current user role
    final authState = ref.watch(authProvider);
    final role = authState.role;
    
    switch (role) {
      case 'student':
        return ref.read(studentIdProvider);
      case 'parent':
        // TODO: Get active child ID from parent module
        // For now, we'll return null and show an error.
        return null;
      case 'teacher':
        // Teachers need to select a student; we don't have that context here.
        return null;
      case 'admin':
        // Admins might want to view any student's report card; we need a selector.
        return null;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentId = _getStudentId(ref);
    final term = ref.watch(selectedTermProvider);
    final reportCardAsync = studentId != null
        ? ref.watch(reportCardProviderFamily(studentId))
        : const AsyncValue.error('Unable to determine student ID', StackTrace.empty);

    return Scaffold(
      appBar: AppBar(
        title: Text('${term} Report Card'),
        actions: [
          IconButton(
            icon: Icon(_isGeneratingPDF ? Icons.cancel : Icons.picture_as_pdf),
            onPressed: _isGeneratingPDF
                ? null
                : () async {
                    setState(() => _isGeneratingPDF = true);
                    try {
                      final reportCard = await reportCardAsync.firstWhere(
                              (element) => true,
                              orElse: () => throw Exception('No report card data'),
                            );
                      final pdfBytes = await PDFExportService.instance
                          .generateReportCardPDF(reportCard);
                      
                      await Printing.layoutPdf(
                        onLayout: (PdfPageFormat format) async => pdfBytes,
                      );
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to generate PDF: $e')),
                        );
                      }
                    } finally {
                      if (mounted) setState(() => _isGeneratingPDF = false);
                    }
                  },
          ),
        ],
      ),
      body: reportCardAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (reportCard) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Hamlet School Monitor',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '${reportCard.term} Report Card',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        '${reportCard.student.profiles.firstName} ${reportCard.student.profiles.lastName}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontSize: 18.sp,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'Class: ${reportCard.results.isNotEmpty ? reportCard.results.first.result.classId : 'N/A'}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),

                // Student Info
                _buildInfoRow('Student Name',
                    '${reportCard.student.profiles.firstName} ${reportCard.student.profiles.lastName}'),
                _buildInfoRow('Class',
                    '${reportCard.results.isNotEmpty ? reportCard.results.first.result.classId : 'N/A'}'),
                _buildInfoRow('Term', reportCard.term),
                _buildInfoRow('Roll Number',
                    reportCard.student.rollNumber ?? 'Not set'),
                SizedBox(height: 16.h),

                // Results Table
                Text(
                  'Academic Results',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                reportCard.results.isEmpty
                    ? const Center(child: Text('No results available'))
                    : DataTable(
                        headingRowColor: MaterialStateProperty.all(
                            Theme.of(context).primaryColor.withOpacity(0.1)),
                        columns: const [
                          DataColumn(label: Text('Subject')),
                          DataColumn(label: Text('Exam')),
                          DataColumn(label: Text('Marks')),
                          DataColumn(label: Text('%')),
                          DataColumn(label: Text('Grade')),
                        ],
                        rows: reportCard.results.map((result) {
                          return DataRow(cells: [
                            DataCell(Text(result.subjectName)),
                            DataCell(Text(result.result.examName)),
                            DataCell(Text(
                                '${result.result.marksObtained.toStringAsFixed(1)} / ${result.result.maxMarks.toStringAsFixed(1)}')),
                            DataCell(Text('${result.percentage.toStringAsFixed(1)}%')),
                            DataCell(Text(result.grade,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _getGradeColor(result.grade),
                                ))),
                          ]);
                        }).toList(),
                      ),
                SizedBox(height: 20.h),

                // Summary
                Text(
                  'Summary',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                _buildInfoRow('GPA', reportCard.gpa.toStringAsFixed(2)),
                _buildInfoRow('Performance',
                    _getPerformanceDescription(reportCard.gpa)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _getPerformanceDescription(double gpa) {
    if (gpa >= 3.5) return 'Excellent';
    if (gpa >= 3.0) return 'Good';
    if (gpa >= 2.5) return 'Satisfactory';
    if (gpa >= 2.0) return 'Needs Improvement';
    return 'Unsatisfactory';
  }

  // Helper method to get color for grade
  Color _getGradeColor(String grade) {
    switch (grade) {
      case 'A+':
      case 'A':
        return Colors.green;
      case 'B+':
      case 'B':
        return Colors.lightGreen;
      case 'C+':
      case 'C':
        return Colors.orange;
      case 'D+':
      case 'D':
        return Colors.deepOrange;
      default:
        return Colors.red;
    }
  }
}