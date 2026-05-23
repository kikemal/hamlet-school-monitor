// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Student _$StudentFromJson(Map<String, dynamic> json) => _Student(
  id: json['id'] as String,
  schoolId: json['school_id'] as String,
  classId: json['class_id'] as String?,
  parentId: json['parent_id'] as String?,
  dateOfBirth: json['date_of_birth'] == null
      ? null
      : DateTime.parse(json['date_of_birth'] as String),
  enrollmentDate: json['enrollment_date'] == null
      ? null
      : DateTime.parse(json['enrollment_date'] as String),
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$StudentToJson(_Student instance) => <String, dynamic>{
  'id': instance.id,
  'school_id': instance.schoolId,
  'class_id': instance.classId,
  'parent_id': instance.parentId,
  'date_of_birth': instance.dateOfBirth?.toIso8601String(),
  'enrollment_date': instance.enrollmentDate?.toIso8601String(),
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
};
