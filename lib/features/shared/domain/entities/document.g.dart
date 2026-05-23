// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Document _$DocumentFromJson(Map<String, dynamic> json) => _Document(
  id: json['id'] as String,
  entityType: json['entity_type'] as String,
  entityId: json['entity_id'] as String,
  documentType: json['document_type'] as String,
  fileUrl: json['file_url'] as String,
  uploadedBy: json['uploaded_by'] as String?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$DocumentToJson(_Document instance) => <String, dynamic>{
  'id': instance.id,
  'entity_type': instance.entityType,
  'entity_id': instance.entityId,
  'document_type': instance.documentType,
  'file_url': instance.fileUrl,
  'uploaded_by': instance.uploadedBy,
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
};
