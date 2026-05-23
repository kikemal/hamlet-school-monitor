// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_health_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_StudentHealthRecord _$StudentHealthRecordFromJson(Map<String, dynamic> json) =>
    _StudentHealthRecord(
      id: json['id'] as String,
      studentId: json['student_id'] as String,
      bloodGroup: json['blood_group'] as String?,
      allergies: json['allergies'] as String?,
      medicalConditions: json['medical_conditions'] as String?,
      emergencyNotes: json['emergency_notes'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$StudentHealthRecordToJson(
  _StudentHealthRecord instance,
) => <String, dynamic>{
  'id': instance.id,
  'student_id': instance.studentId,
  'blood_group': instance.bloodGroup,
  'allergies': instance.allergies,
  'medical_conditions': instance.medicalConditions,
  'emergency_notes': instance.emergencyNotes,
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
};
