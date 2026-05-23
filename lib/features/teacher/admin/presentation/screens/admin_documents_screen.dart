import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/models/admin_models.dart';
import '../providers/admin_providers.dart';
import '../widgets/admin_empty_state.dart';
import '../widgets/admin_error_view.dart';
import '../widgets/admin_form_dialog.dart';
import '../widgets/admin_loading_view.dart';
import '../widgets/admin_page_header.dart';
import '../widgets/admin_validated_field.dart';

class AdminDocumentsScreen extends ConsumerWidget {
  const AdminDocumentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(adminDocumentsProvider);

    return Column(
      children: [
        AdminPageHeader(
          title: 'Documents library',
          subtitle: 'School policies, forms, and shared files',
          action: FilledButton.icon(
            onPressed: () => _upload(context, ref),
            icon: const Icon(Icons.upload),
            label: const Text('Upload'),
          ),
        ),
        Expanded(
          child: async.when(
            loading: () => const AdminLoadingView(),
            error: (e, _) => AdminErrorView(
              message: e.toString(),
              onRetry: () => ref.invalidate(adminDocumentsProvider),
            ),
            data: (docs) => docs.isEmpty
                ? AdminEmptyState(
                    message: 'No documents uploaded yet.',
                    actionLabel: 'Upload document',
                    onAction: () => _upload(context, ref),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: docs.length,
                    itemBuilder: (_, i) {
                      final d = docs[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.indigo.shade50,
                            child: const Icon(Icons.description, color: Colors.indigo),
                          ),
                          title: Text(d.document.documentType),
                          subtitle: Text(
                            '${d.document.entityType} · ${d.uploaderName ?? 'Unknown'}',
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => _delete(context, ref, d),
                          ),
                          onTap: () => _copyDocumentUrl(context, d.document.fileUrl),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  void _copyDocumentUrl(BuildContext context, String url) {
    Clipboard.setData(ClipboardData(text: url));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Document URL copied to clipboard')),
    );
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    DocumentListItem docItem,
  ) async {
    final ok = await showAdminConfirmDialog(
      context: context,
      title: 'Delete document?',
      message: 'Remove "${docItem.document.documentType}" from the library?',
    );
    if (!ok) return;
    await ref.read(adminRepositoryProvider).deleteDocument(
          docItem.document.id,
          docItem.document.fileUrl,
        );
    ref.invalidate(adminDocumentsProvider);
  }

  Future<void> _upload(BuildContext context, WidgetRef ref) async {
    final schoolId = ref.read(adminSchoolIdProvider);
    final profile = ref.read(authProvider).profile;
    if (schoolId == null) return;

    final picked = await FilePicker.pickFiles(withData: true);
    if (picked == null || picked.files.single.bytes == null) return;

    final docType = TextEditingController(text: 'General');

    final ok = await showAdminFormDialog(
      context: context,
      title: 'Upload document',
      confirmLabel: 'Upload',
      fields: [
        AdminValidatedField.required(docType, 'Document type'),
      ],
    );

    if (ok != true) {
      docType.dispose();
      return;
    }

    try {
      await ref.read(adminRepositoryProvider).uploadDocument(
            entityType: 'school',
            entityId: schoolId,
            documentType: docType.text.trim(),
            fileName: picked.files.single.name,
            bytes: picked.files.single.bytes!,
            uploadedBy: profile?.id,
          );
      ref.invalidate(adminDocumentsProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Document uploaded')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Upload failed. Create a public "documents" bucket in Supabase Storage. $e',
            ),
          ),
        );
      }
    } finally {
      docType.dispose();
    }
  }
}
