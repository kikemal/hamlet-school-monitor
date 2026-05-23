import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../shared/domain/entities/document.dart';
import '../../domain/models/admin_models.dart';
import 'admin_service_base.dart';

class AdminDocumentService extends AdminServiceBase {
  static const String bucketName = 'documents';

  Future<List<DocumentListItem>> fetchDocuments({String? schoolId}) async {
    var builder = supabaseClient
        .from('documents')
        .select('*, profiles:uploaded_by(first_name, last_name)');

    if (schoolId != null) {
      builder = builder.eq('entity_type', 'school').eq('entity_id', schoolId);
    }

    final rows = await builder.order('created_at', ascending: false);
    return rows.map((row) {
      final map = mapRow(row);
      String? uploaderName;
      final profile = map['profiles'] as Map?;
      if (profile != null) {
        uploaderName = '${profile['first_name']} ${profile['last_name']}';
      }
      return DocumentListItem(
        document: Document.fromJson(map),
        uploaderName: uploaderName,
      );
    }).toList();
  }

  Future<Document> uploadDocument({
    required String entityType,
    required String entityId,
    required String documentType,
    required String fileName,
    required Uint8List bytes,
    String? uploadedBy,
  }) async {
    final path = '$entityType/$entityId/${DateTime.now().millisecondsSinceEpoch}_$fileName';

    await supabaseClient.storage.from(bucketName).uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(upsert: true),
        );

    final fileUrl =
        supabaseClient.storage.from(bucketName).getPublicUrl(path);

    final row = await supabaseClient
        .from('documents')
        .insert({
          'entity_type': entityType,
          'entity_id': entityId,
          'document_type': documentType,
          'file_url': fileUrl,
          if (uploadedBy != null) 'uploaded_by': uploadedBy,
        })
        .select()
        .single();

    return Document.fromJson(mapRow(row));
  }

  Future<void> deleteDocument(String id, String fileUrl) async {
    await supabaseClient.from('documents').delete().eq('id', id);
    final path = _pathFromPublicUrl(fileUrl);
    if (path != null) {
      await supabaseClient.storage.from(bucketName).remove([path]);
    }
  }

  String? _pathFromPublicUrl(String url) {
    final marker = '/storage/v1/object/public/$bucketName/';
    final index = url.indexOf(marker);
    if (index == -1) return null;
    return url.substring(index + marker.length);
  }
}
