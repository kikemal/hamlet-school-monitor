// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'school_class.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SchoolClass _$SchoolClassFromJson(Map<String, dynamic> json) => _SchoolClass(
  id: json['id'] as String,
  schoolId: json['school_id'] as String,
  name: json['name'] as String,
  teacherId: json['teacher_id'] as String?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$SchoolClassToJson(_SchoolClass instance) =>
    <String, dynamic>{
      'id': instance.id,
      'school_id': instance.schoolId,
      'name': instance.name,
      'teacher_id': instance.teacherId,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
