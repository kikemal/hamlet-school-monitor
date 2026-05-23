// Copyright 2026 Hamlet School Monitor. All rights reserved.
// Use of this source code is governed by a MIT-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';

import 'package:hamlet_school_monitor/features/results/domain/models/results_models.dart';
import 'package:hamlet_school_monitor/features/shared/domain/entities/result.dart';
import 'package:hamlet_school_monitor/features/shared/domain/entities/student.dart';

class ResultsService {
  ResultsService._internal();

  static final ResultsService instance = ResultsService._internal();

  // Mock implementation - in a real app, this would call Supabase API
  Future<void> uploadResult(Result result) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // In a real implementation, this would insert into Supabase
    // For now, we just return successfully
    return;
  }

  Future<double> calculateGPA(List<Result> results) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    
    if (results.isEmpty) return 0.0;
    
    // Simple GPA calculation: average of percentage scores converted to 4.0 scale
    double totalPoints = 0.0;
    
    for (final result in results) {
      final percentage = (result.marksObtained / result.maxMarks) * 100;
      // Convert percentage to GPA scale (simplified)
      double gpaPoints;
      if (percentage >= 90) gpaPoints = 4.0;
      else if (percentage >= 80) gpaPoints = 3.0;
      else if (percentage >= 70) gpaPoints = 2.0;
      else if (percentage >= 60) gpaPoints = 1.0;
      else gpaPoints = 0.0;
      
      totalPoints += gpaPoints;
    }
    
    return totalPoints / results.length;
  }

  Future<ReportCard> generateReportCard(String studentId, String term) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    // In a real implementation, this would fetch from Supabase
    // For now, return mock data
    final mockStudent = Student(
      id: studentId,
      profiles: StudentProfiles(
        firstName: 'John',
        lastName: 'Doe',
        email: 'john.doe@example.com',
        phoneNumber: '123-456-7890',
        dateOfBirth: DateTime(2010, 5, 15),
        gender: 'Male',
        address: '123 Main St',
      ),
      rollNumber: 'ST001',
      admissionDate: DateTime(2020, 9, 1),
      status: 'active',
    );
    
    final mockResults = [
      ResultWithSubject(
        subjectName: 'Mathematics',
        className: 'Grade 10A',
        result: Result(
          id: 'result1',
          studentId: studentId,
          subjectId: 'math101',
          classId: 'class10a',
          examName: 'Mid Term Exam',
          marksObtained: 85,
          maxMarks: 100,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        percentage: 85.0,
        grade: 'B',
      ),
      ResultWithSubject(
        subjectName: 'Science',
        className: 'Grade 10A',
        result: Result(
          id: 'result2',
          studentId: studentId,
          subjectId: 'sci101',
          classId: 'class10a',
          examName: 'Mid Term Exam',
          marksObtained: 92,
          maxMarks: 100,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        percentage: 92.0,
        grade: 'A',
      ),
      ResultWithSubject(
        subjectName: 'English',
        className: 'Grade 10A',
        result: Result(
          id: 'result3',
          studentId: studentId,
          subjectId: 'eng101',
          classId: 'class10a',
          examName: 'Mid Term Exam',
          marksObtained: 78,
          maxMarks: 100,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        percentage: 78.0,
        grade: 'C',
      ),
    ];
    
    return ReportCard(
      studentId: studentId,
      term: term,
      student: mockStudent,
      results: mockResults,
      gpa: 3.2, // Calculated from the mock results
    );
  }

  Future<SchoolAnalytics> getSchoolAnalytics() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1000));
    
    // Return mock analytics data
    return SchoolAnalytics(
      averageGPA: 3.1,
      totalStudents: 1250,
      subjectPerformance: [
        SubjectPerformance(
          subjectName: 'Mathematics',
          averagePercentage: 78.5,
          studentCount: 320,
        ),
        SubjectPerformance(
          subjectName: 'Science',
          averagePercentage: 82.3,
          studentCount: 315,
        ),
        SubjectPerformance(
          subjectName: 'English',
          averagePercentage: 85.1,
          studentCount: 330,
        ),
        SubjectPerformance(
          subjectName: 'History',
          averagePercentage: 80.7,
          studentCount: 298,
        ),
        SubjectPerformance(
          subjectName: 'Computer Science',
          averagePercentage: 88.9,
          studentCount: 180,
        ),
      ],
      gradeDistribution: [
        GradeDistribution(grade: 'A+', count: 45),
        GradeDistribution(grade: 'A', count: 120),
        GradeDistribution(grade: 'B+', count: 200),
        GradeDistribution(grade: 'B', count: 280),
        GradeDistribution(grade: 'C+', count: 190),
        GradeDistribution(grade: 'C', count: 150),
        GradeDistribution(grade: 'D+', count: 80),
        GradeDistribution(grade: 'D', count: 45),
        GradeDistribution(grade: 'F', count: 30),
      ],
    );
  }

  Future<List<ResultExport>> exportResults(List<String> studentIds) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 600));
    
    // Return mock export data
    final List<ResultExport> exports = [];
    
    for (final studentId in studentIds) {
      exports.add(
        ResultExport(
          studentId: studentId,
          studentName: 'John Doe',
          className: 'Grade 10A',
          subjectName: 'Mathematics',
          examName: 'Final Exam',
          marksObtained: 85.0,
          maxMarks: 100.0,
          percentage: 85.0,
          grade: 'B',
        ),
      );
      
      exports.add(
        ResultExport(
          studentId: studentId,
          studentName: 'John Doe',
          className: 'Grade 10A',
          subjectName: 'Science',
          examName: 'Final Exam',
          marksObtained: 92.0,
          maxMarks: 100.0,
          percentage: 92.0,
          grade: 'A',
        ),
      );
    }
    
    return exports;
  }

  // Mock PDF generation - in a real app, this would use the pdf package
  Future<Uint8List> generateReportCardPDF(ReportCard reportCard) async {
    // Simulate processing delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Return a minimal PDF-like byte array for demonstration
    // In a real implementation, this would generate an actual PDF
    return Uint8List.fromList([0x25, 0x50, 0x44, 0x46]); // PDF magic number
  }
}