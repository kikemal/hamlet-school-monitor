import 'package:freezed_annotation/freezed_annotation.dart';

part 'homework_submission.freezed.dart';
part 'homework_submission.g.dart';

@freezed
abstract class HomeworkSubmission with _$HomeworkSubmission {
  const factory HomeworkSubmission({
    required String id,
    required String homeworkId,
    required String studentId,
    String? submissionText,
    String? fileUrl,
    required String status,
    double? gradedMarks,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _HomeworkSubmission;

  factory HomeworkSubmission.fromJson(Map<String, dynamic> json) => _$HomeworkSubmissionFromJson(json);
}
