// Copyright 2026 Hamlet School Monitor. All rights reserved.
// Use of this source code is governed by a MIT-style license that can be
// found in the LICENSE file.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hamlet_school_monitor/features/results/data/repositories/results_repository_impl.dart';
import 'package:hamlet_school_monitor/features/results/data/services/results_service.dart';
import 'package:hamlet_school_monitor/features/results/data/repositories/results_repository.dart';
import 'package:hamlet_school_monitor/features/shared/providers/auth_provider.dart';

// Repository provider
final resultsRepositoryProvider = Provider<ResultsRepository>((ref) {
  return ResultsRepositoryImpl(
    remoteDataSource: ResultsService.instance,
  );
});

// Provider for uploading a result (returns Future<void>)
final uploadResultProvider =
    FutureProviderFamily<void, Result>((ref, result) async {
  final repository = ref.watch(resultsRepositoryProvider);
  await repository.uploadResult(result);
});

// Provider for calculating GPA (returns Future<double>)
final calculateGPAProvider =
    FutureProviderFamily<double, List<Result>>((ref, results) async {
  final repository = ref.watch(resultsRepositoryProvider);
  return await repository.calculateGPA(results);
});

// Provider for generating a report card (returns Future<ReportCard>)
final reportCardProviderFamily =
    FutureProviderFamily<ReportCard, String>((ref, studentId) {
  final term = ref.watch(selectedTermProvider);
  final repository = ref.watch(resultsRepositoryProvider);
  return repository.generateReportCard(studentId, term);
});

// Provider for school analytics (returns Future<SchoolAnalytics>)
final schoolAnalyticsProvider =
    FutureProvider<SchoolAnalytics>((ref) async {
  final repository = ref.watch(resultsRepositoryProvider);
  return await repository.getSchoolAnalytics();
});

// Provider for exporting results (returns Future<List<ResultExport>>)
final exportResultsProvider =
    FutureProviderFamily<List<ResultExport>, List<String>>((ref, studentIds) async {
  final repository = ref.watch(resultsRepositoryProvider);
  return await repository.exportResults(studentIds);
});

// Selected term provider (for the current view)
final selectedTermProvider = StateProvider<String>((ref) => 'Term 1');