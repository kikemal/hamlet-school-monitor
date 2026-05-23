// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'homework_submission.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_HomeworkSubmission _$HomeworkSubmissionFromJson(Map<String, dynamic> json) =>
    _HomeworkSubmission(
      id: json['id'] as String,
      homeworkId: json['homework_id'] as String,
      studentId: json['student_id'] as String,
      submissionText: json['submission_text'] as String?,
      fileUrl: json['file_url'] as String?,
      status: json['status'] as String,
      gradedMarks: (json['graded_marks'] as num?)?.toDouble(),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$HomeworkSubmissionToJson(_HomeworkSubmission instance) =>
    <String, dynamic>{
      'id': instance.id,
      'homework_id': instance.homeworkId,
      'student_id': instance.studentId,
      'submission_text': instance.submissionText,
      'file_url': instance.fileUrl,
      'status': instance.status,
      'graded_marks': instance.gradedMarks,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
