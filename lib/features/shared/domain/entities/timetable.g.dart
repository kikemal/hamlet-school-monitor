// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timetable.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Timetable _$TimetableFromJson(Map<String, dynamic> json) => _Timetable(
  id: json['id'] as String,
  classId: json['class_id'] as String,
  subjectId: json['subject_id'] as String,
  teacherId: json['teacher_id'] as String,
  dayOfWeek: (json['day_of_week'] as num).toInt(),
  startTime: json['start_time'] as String,
  endTime: json['end_time'] as String,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$TimetableToJson(_Timetable instance) =>
    <String, dynamic>{
      'id': instance.id,
      'class_id': instance.classId,
      'subject_id': instance.subjectId,
      'teacher_id': instance.teacherId,
      'day_of_week': instance.dayOfWeek,
      'start_time': instance.startTime,
      'end_time': instance.endTime,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
