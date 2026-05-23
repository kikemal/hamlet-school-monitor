// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'behaviour_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BehaviourLog _$BehaviourLogFromJson(Map<String, dynamic> json) =>
    _BehaviourLog(
      id: json['id'] as String,
      studentId: json['student_id'] as String,
      teacherId: json['teacher_id'] as String,
      incidentType: json['incident_type'] as String,
      description: json['description'] as String,
      date: DateTime.parse(json['date'] as String),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$BehaviourLogToJson(_BehaviourLog instance) =>
    <String, dynamic>{
      'id': instance.id,
      'student_id': instance.studentId,
      'teacher_id': instance.teacherId,
      'incident_type': instance.incidentType,
      'description': instance.description,
      'date': instance.date.toIso8601String(),
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
