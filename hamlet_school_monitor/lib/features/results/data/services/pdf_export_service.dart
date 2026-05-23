// Copyright 2026 Hamlet School Monitor. All rights reserved.
// Use of this source code is governed by a MIT-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';

import 'package:hamlet_school_monitor/features/results/domain/models/results_models.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

class PDFExportService {
  PDFExportService._internal();

  static final PDFExportService instance = PDFExportService._internal();

  Future<Uint8List> generateReportCardPDF(ReportCard reportCard) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(16),
                decoration: const pw.BoxDecoration(
                  color: PdfColors.blueGrey,
                ),
                child: pw.Column(
                  children: [
                    pw.Text(
                      'Hamlet School Monitor',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      '${reportCard.term} Report Card',
                      style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Student: ${reportCard.student.profiles.firstName} ${reportCard.student.profiles.lastName}',
                style: pw.TextStyle(fontSize: 16),
              ),
              pw.Text(
                'Class: ${reportCard.results.isNotEmpty ? reportCard.results.first.result.classId : 'N/A'}',
                style: pw.TextStyle(fontSize: 16),
              ),
              pw.Text(
                'Term: ${reportCard.term}',
                style: pw.TextStyle(fontSize: 16),
              ),
              pw.Text(
                'Roll Number: ${reportCard.student.rollNumber ?? 'Not set'}',
                style: pw.TextStyle(fontSize: 16),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Academic Results',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    children: [
                      pw.Container(
                        padding: const pw.EdgeInsets.all(8),
                        color: PdfColors.blueGrey,
                        child: pw.Text(
                          'Subject',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white,
                          ),
                        ),
                      ),
                      pw.Container(
                        padding: const pw.EdgeInsets.all(8),
                        color: PdfColors.blueGrey,
                        child: pw.Text(
                          'Exam',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white,
                          ),
                        ),
                      ),
                      pw.Container(
                        padding: const pw.EdgeInsets.all(8),
                        color: PdfColors.blueGrey,
                        child: pw.Text(
                          'Marks',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white,
                          ),
                        ),
                      ),
                      pw.Container(
                        padding: const pw.EdgeInsets.all(8),
                        color: PdfColors.blueGrey,
                        child: pw.Text(
                          'Percentage',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white,
                          ),
                        ),
                      ),
                      pw.Container(
                        padding: const pw.EdgeInsets.all(8),
                        color: PdfColors.blueGrey,
                        child: pw.Text(
                          'Grade',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  for (final result in reportCard.results)
                    pw.TableRow(
                      children: [
                        pw.Container(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(result.subjectName),
                        ),
                        pw.Container(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(result.result.examName),
                        ),
                        pw.Container(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            '${result.result.marksObtained}/${result.result.maxMarks}',
                          ),
                        ),
                        pw.Container(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('${result.percentage.toStringAsFixed(1)}%'),
                        ),
                        pw.Container(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            result.grade,
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              color: _getGradeColor(result.grade),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Summary',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'GPA: ${reportCard.gpa.toStringAsFixed(2)}',
                style: pw.TextStyle(fontSize: 16),
              ),
              pw.Text(
                'Performance: ${_getPerformanceDescription(reportCard.gpa)}',
                style: pw.TextStyle(fontSize: 16),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  pw.Color _getGradeColor(String grade) {
    switch (grade) {
      case 'A+':
      case 'A':
        return PdfColors.green;
      case 'B+':
      case 'B':
        return PdfColors.lightGreen;
      case 'C+':
      case 'C':
        return PdfColors.orange;
      case 'D+':
      case 'D':
        return PdfColors.red;
      default:
        return PdfColors.grey;
    }
  }

  String _getPerformanceDescription(double gpa) {
    if (gpa >= 3.5) return 'Excellent';
    if (gpa >= 3.0) return 'Good';
    if (gpa >= 2.5) return 'Satisfactory';
    if (gpa >= 2.0) return 'Needs Improvement';
    return 'Unsatisfactory';
  }
}