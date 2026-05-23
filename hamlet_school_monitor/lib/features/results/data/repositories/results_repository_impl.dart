// Copyright 2026 Hamlet School Monitor. All rights reserved.
// Use of this source code is governed by a MIT-style license that can be
// found in the LICENSE file.

import 'package:hamlet_school_monitor/features/results/data/services/results_service.dart';
import 'package:hamlet_school_monitor/features/results/data/repositories/results_repository.dart';
import 'package:hamlet_school_monitor/features/results/domain/models/results_models.dart';
import 'package:hamlet_school_monitor/features/shared/domain/entities/result.dart';

class ResultsRepositoryImpl implements ResultsRepository {
  final ResultsService remoteDataSource;

  ResultsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> uploadResult(Result result) async {
    await remoteDataSource.uploadResult(result);
  }

  @override
  Future<double> calculateGPA(List<Result> results) async {
    return await remoteDataSource.calculateGPA(results);
  }

  @override
  Future<ReportCard> generateReportCard(String studentId, String term) async {
    return await remoteDataSource.generateReportCard(studentId, term);
  }

  @override
  Future<SchoolAnalytics> getSchoolAnalytics() async {
    return await remoteDataSource.getSchoolAnalytics();
  }

  @override
  Future<List<ResultExport>> exportResults(List<String> studentIds) async {
    return await remoteDataSource.exportResults(studentIds);
  }
}