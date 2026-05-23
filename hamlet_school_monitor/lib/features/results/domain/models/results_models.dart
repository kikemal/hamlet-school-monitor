// Copyright 2026 Hamlet School Monitor. All rights reserved.
// Use of this source code is governed by a MIT-style license that can be
// found in the LICENSE file.

part of 'results_models.dart';

@freezed
class ResultRecord with _$ResultRecord {
  const factory ResultRecord({
    required String id,
    required String studentId,
    required String subjectId,
    required String classId,
    required Result result,
  }) = _ResultRecord;

  factory ResultRecord.fromJson(Map<String, dynamic> json) =>
      _$ResultRecordFromJson(json);
}

@freezed
class GPAReport with _$GPAReport {
  const factory GPAReport({
    required String studentId,
    required String term,
    required double gpa,
    required List<ResultRecord> results,
  }) = _GPAReport;

  factory GPAReport.fromJson(Map<String, dynamic> json) =>
      _$GPAReportFromJson(json);
}

@freezed
class ReportCard with _$ReportCard {
  const factory ReportCard({
    required String studentId,
    required String term,
    required Student student,
    required List<ResultWithSubject> results,
    required double gpa,
  }) = _ReportCard;

  factory ReportCard.fromJson(Map<String, dynamic> json) =>
      _$ReportCardFromJson(json);
}

@freezed
class ResultWithSubject with _$ResultWithSubject {
  const factory ResultWithSubject({
    required String subjectName,
    required String className,
    required Result result,
    required double percentage,
    required String grade,
  }) = _ResultWithSubject;

  factory ResultWithSubject.fromJson(Map<String, dynamic> json) =>
      _$ResultWithSubjectFromJson(json);
}

@freezed
class SchoolAnalytics with _$SchoolAnalytics {
  const factory SchoolAnalytics({
    required double averageGPA,
    required int totalStudents,
    required List<SubjectPerformance> subjectPerformance,
    required List<GradeDistribution> gradeDistribution,
  }) = _SchoolAnalytics;

  factory SchoolAnalytics.fromJson(Map<String, dynamic> json) =>
      _$SchoolAnalyticsFromJson(json);
}

@freezed
class SubjectPerformance with _$SubjectPerformance {
  const factory SubjectPerformance({
    required String subjectName,
    required double averagePercentage,
    required int studentCount,
  }) = _SubjectPerformance;

  factory SubjectPerformance.fromJson(Map<String, dynamic> json) =>
      _$SubjectPerformanceFromJson(json);
}

@freezed
class GradeDistribution with _$GradeDistribution {
  const factory GradeDistribution({
    required String grade,
    required int count,
  }) = _GradeDistribution;

  factory GradeDistribution.fromJson(Map<String, dynamic> json) =>
      _$GradeDistributionFromJson(json);
}

@freezed
class ResultExport with _$ResultExport {
  const factory ResultExport({
    required String studentId,
    required String studentName,
    required String className,
    required String subjectName,
    required String examName,
    required double marksObtained,
    required double maxMarks,
    required double percentage,
    required String grade,
  }) = _ResultExport;

  factory ResultExport.fromJson(Map<String, dynamic> json) =>
      _$ResultExportFromJson(json);
}