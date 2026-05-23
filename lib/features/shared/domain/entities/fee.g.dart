// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fee.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Fee _$FeeFromJson(Map<String, dynamic> json) => _Fee(
  id: json['id'] as String,
  schoolId: json['school_id'] as String,
  classId: json['class_id'] as String?,
  studentId: json['student_id'] as String?,
  amount: (json['amount'] as num).toDouble(),
  description: json['description'] as String,
  dueDate: DateTime.parse(json['due_date'] as String),
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$FeeToJson(_Fee instance) => <String, dynamic>{
  'id': instance.id,
  'school_id': instance.schoolId,
  'class_id': instance.classId,
  'student_id': instance.studentId,
  'amount': instance.amount,
  'description': instance.description,
  'due_date': instance.dueDate.toIso8601String(),
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
};
