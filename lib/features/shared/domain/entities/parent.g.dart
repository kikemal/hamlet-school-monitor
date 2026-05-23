// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parent.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Parent _$ParentFromJson(Map<String, dynamic> json) => _Parent(
  id: json['id'] as String,
  address: json['address'] as String?,
  emergencyContact: json['emergency_contact'] as String?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$ParentToJson(_Parent instance) => <String, dynamic>{
  'id': instance.id,
  'address': instance.address,
  'emergency_contact': instance.emergencyContact,
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
};
