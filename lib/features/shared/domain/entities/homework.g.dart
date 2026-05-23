// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'homework.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Homework _$HomeworkFromJson(Map<String, dynamic> json) => _Homework(
  id: json['id'] as String,
  classId: json['class_id'] as String,
  subjectId: json['subject_id'] as String,
  teacherId: json['teacher_id'] as String,
  title: json['title'] as String,
  description: json['description'] as String?,
  dueDate: DateTime.parse(json['due_date'] as String),
  attachmentUrl: json['attachment_url'] as String?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$HomeworkToJson(_Homework instance) => <String, dynamic>{
  'id': instance.id,
  'class_id': instance.classId,
  'subject_id': instance.subjectId,
  'teacher_id': instance.teacherId,
  'title': instance.title,
  'description': instance.description,
  'due_date': instance.dueDate.toIso8601String(),
  'attachment_url': instance.attachmentUrl,
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
};
