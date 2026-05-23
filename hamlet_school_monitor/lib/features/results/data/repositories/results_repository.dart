// Copyright 2026 Hamlet School Monitor. All rights reserved.
// Use of this source code is governed by a MIT-style license that can be
// found in the LICENSE file.

import 'package:hamlet_school_monitor/features/results/domain/models/results_models.dart';
import 'package:hamlet_school_monitor/features/shared/domain/entities/result.dart';

abstract class ResultsRepository {
  Future<void> uploadResult(Result result);
  Future<double> calculateGPA(List<Result> results);
  Future<ReportCard> generateReportCard(String studentId, String term);
  Future<SchoolAnalytics> getSchoolAnalytics();
  Future<List<ResultExport>> exportResults(List<String> studentIds);
}