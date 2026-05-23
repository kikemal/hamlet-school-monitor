// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'school_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SchoolEvent _$SchoolEventFromJson(Map<String, dynamic> json) => _SchoolEvent(
  id: json['id'] as String,
  schoolId: json['school_id'] as String,
  title: json['title'] as String,
  description: json['description'] as String?,
  eventDate: DateTime.parse(json['event_date'] as String),
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$SchoolEventToJson(_SchoolEvent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'school_id': instance.schoolId,
      'title': instance.title,
      'description': instance.description,
      'event_date': instance.eventDate.toIso8601String(),
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
