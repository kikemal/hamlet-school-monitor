import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../network/supabase_config.dart';
import 'base_service.dart';

class StorageService extends BaseService {
  static const String _chatAttachmentsBucket = 'chat_attachments';

  /// Uploads a file to Supabase Storage
  Future<String> uploadFile({
    required File file,
    required String conversationId,
    required String senderId,
  }) async {
    try {
      final fileExtension = file.path.split('.').last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_$senderId.$fileExtension';
      final filePath = '$conversationId/$fileName';

      final response = await supabaseClient
          .storage
          .from(_chatAttachmentsBucket)
          .upload(filePath, file);

      final publicUrl = supabaseClient
          .storage
          .from(_chatAttachmentsBucket)
          .getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      throw handleError(e);
    }
  }

  /// Uploads an image to Supabase Storage
  Future<String> uploadImage({
    required File imageFile,
    required String conversationId,
    required String senderId,
  }) async {
    try {
      final fileExtension = imageFile.path.split('.').last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_$senderId.$fileExtension';
      final filePath = '$conversationId/images/$fileName';

      final response = await supabaseClient
          .storage
          .from(_chatAttachmentsBucket)
          .upload(filePath, imageFile);

      final publicUrl = supabaseClient
          .storage
          .from(_chatAttachmentsBucket)
          .getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      throw handleError(e);
    }
  }

  /// Deletes a file from Supabase Storage
  Future<void> deleteFile(String fileUrl) async {
    try {
      final filePath = _extractFilePathFromUrl(fileUrl);
      if (filePath != null) {
        await supabaseClient
            .storage
            .from(_chatAttachmentsBucket)
            .remove([filePath]);
      }
    } catch (e) {
      throw handleError(e);
    }
  }

  /// Extracts file path from a public URL
  String? _extractFilePathFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      if (pathSegments.length >= 3 && pathSegments[0] == _chatAttachmentsBucket) {
        return pathSegments.sublist(1).join('/');
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Gets the file type from a file path
  String getFileType(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();
    if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension)) {
      return 'image';
    } else if (['pdf', 'doc', 'docx', 'txt'].contains(extension)) {
      return 'document';
    } else if (['mp4', 'mov', 'avi'].contains(extension)) {
      return 'video';
    } else if (['mp3', 'wav'].contains(extension)) {
      return 'audio';
    }
    return 'file';
  }

  /// Gets the file name from a file path
  String getFileName(String filePath) {
    return filePath.split('/').last;
  }
}
