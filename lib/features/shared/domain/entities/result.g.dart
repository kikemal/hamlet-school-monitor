// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Result _$ResultFromJson(Map<String, dynamic> json) => _Result(
  id: json['id'] as String,
  studentId: json['student_id'] as String,
  subjectId: json['subject_id'] as String,
  examName: json['exam_name'] as String,
  marksObtained: (json['marks_obtained'] as num).toDouble(),
  maxMarks: (json['max_marks'] as num).toDouble(),
  date: DateTime.parse(json['date'] as String),
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$ResultToJson(_Result instance) => <String, dynamic>{
  'id': instance.id,
  'student_id': instance.studentId,
  'subject_id': instance.subjectId,
  'exam_name': instance.examName,
  'marks_obtained': instance.marksObtained,
  'max_marks': instance.maxMarks,
  'date': instance.date.toIso8601String(),
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
};
