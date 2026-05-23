import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/app_validator.dart';
import '../../domain/models/admin_models.dart';
import '../providers/admin_providers.dart';
import '../widgets/admin_empty_state.dart';
import '../widgets/admin_error_view.dart';
import '../widgets/admin_form_dialog.dart';
import '../widgets/admin_loading_view.dart';
import '../widgets/admin_page_header.dart';
import '../widgets/admin_validated_field.dart';

class AdminStudentsScreen extends ConsumerWidget {
  const AdminStudentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentsAsync = ref.watch(adminStudentsProvider);

    return Column(
      children: [
        AdminPageHeader(
          title: 'Students',
          subtitle: 'Manage student accounts and enrollment',
          action: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'Import CSV',
                onPressed: () => _importCsv(context, ref),
                icon: const Icon(Icons.upload_file),
              ),
              FilledButton.icon(
                onPressed: () => _showForm(context, ref),
                icon: const Icon(Icons.add),
                label: const Text('Add'),
              ),
            ],
          ),
        ),
        Expanded(
          child: studentsAsync.when(
            loading: () => const AdminLoadingView(),
            error: (e, _) => AdminErrorView(
              message: e.toString(),
              onRetry: () => ref.invalidate(adminStudentsProvider),
            ),
            data: (items) {
              if (items.isEmpty) {
                return AdminEmptyState(
                  message: 'No students yet. Add one or import from CSV.',
                  actionLabel: 'Add student',
                  onAction: () => _showForm(context, ref),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return ListTile(
                    leading: CircleAvatar(child: Text(item.firstName[0])),
                    title: Text(item.fullName),
                    subtitle: Text(
                      [
                        if (item.className != null) 'Class: ${item.className}',
                        if (item.parentName != null) 'Parent: ${item.parentName}',
                      ].join(' · '),
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (v) async {
                        if (v == 'edit') {
                          await _showForm(context, ref, item: item);
                        } else if (v == 'delete') {
                          await _confirmDelete(context, ref, item);
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'edit', child: Text('Edit')),
                        PopupMenuItem(value: 'delete', child: Text('Delete')),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _showForm(
    BuildContext context,
    WidgetRef ref, {
    StudentListItem? item,
  }) async {
    final schoolId = ref.read(adminSchoolIdProvider);
    if (schoolId == null) return;

    final classes = await ref.read(adminClassesProvider.future);
    final parents = await ref.read(adminParentsProvider.future);

    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    final firstCtrl = TextEditingController(text: item?.firstName ?? '');
    final lastCtrl = TextEditingController(text: item?.lastName ?? '');
    String? classId = item?.student.classId;
    String? parentId = item?.student.parentId;

    if (!context.mounted) return;

    final fields = <Widget>[
      if (item == null) ...[
        AdminValidatedField.email(emailCtrl),
        AdminValidatedField.password(passCtrl),
      ],
      AdminValidatedField.firstName(firstCtrl),
      AdminValidatedField.lastName(lastCtrl),
      _ClassParentDropdowns(
        classes: classes,
        parents: parents,
        classId: classId,
        parentId: parentId,
        onClassChanged: (v) => classId = v,
        onParentChanged: (v) => parentId = v,
      ),
    ];

    final saved = await showAdminFormDialog(
      context: context,
      title: item == null ? 'Add student' : 'Edit student',
      fields: fields,
    );

    if (saved != true) {
      emailCtrl.dispose();
      passCtrl.dispose();
      firstCtrl.dispose();
      lastCtrl.dispose();
      return;
    }

    final repo = ref.read(adminRepositoryProvider);
    try {
      if (item == null) {
        await repo.createStudent(
          schoolId: schoolId,
          email: emailCtrl.text.trim(),
          password: passCtrl.text,
          firstName: firstCtrl.text.trim(),
          lastName: lastCtrl.text.trim(),
          classId: classId,
          parentId: parentId,
        );
      } else {
        await repo.updateStudent(
          student: item.student,
          firstName: firstCtrl.text.trim(),
          lastName: lastCtrl.text.trim(),
          classId: classId,
          parentId: parentId,
        );
      }
      adminInvalidateAll(ref);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Student saved')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      emailCtrl.dispose();
      passCtrl.dispose();
      firstCtrl.dispose();
      lastCtrl.dispose();
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    StudentListItem item,
  ) async {
    final ok = await showAdminConfirmDialog(
      context: context,
      title: 'Delete student?',
      message: 'Remove ${item.fullName} permanently?',
    );
    if (!ok) return;
    try {
      await ref.read(adminRepositoryProvider).deleteStudent(item.student.id);
      adminInvalidateAll(ref);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Student deleted')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  Future<void> _importCsv(BuildContext context, WidgetRef ref) async {
    final schoolId = ref.read(adminSchoolIdProvider);
    if (schoolId == null) return;

    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
      withData: true,
    );
    if (result == null || result.files.single.bytes == null) return;

    final content = String.fromCharCodes(result.files.single.bytes!);
    final rows = ref.read(adminRepositoryProvider).parseStudentCsv(content);
    if (rows.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No rows found. Headers: email,password,first_name,last_name,class_id,parent_id',
            ),
          ),
        );
      }
      return;
    }

    for (final row in rows) {
      if (AppValidator.validateEmail(row.email) != null ||
          AppValidator.validatePassword(row.password) != null ||
          AppValidator.validateName(row.firstName) != null ||
          AppValidator.validateName(row.lastName) != null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Invalid row for ${row.email}: check email, password, and names.',
              ),
            ),
          );
        }
        return;
      }
    }

    try {
      final count = await ref
          .read(adminRepositoryProvider)
          .importStudentsFromCsv(schoolId: schoolId, rows: rows);
      adminInvalidateAll(ref);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Imported $count students')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Import failed: $e')),
        );
      }
    }
  }
}

class _ClassParentDropdowns extends StatefulWidget {
  const _ClassParentDropdowns({
    required this.classes,
    required this.parents,
    required this.classId,
    required this.parentId,
    required this.onClassChanged,
    required this.onParentChanged,
  });

  final List<ClassListItem> classes;
  final List<ParentListItem> parents;
  final String? classId;
  final String? parentId;
  final ValueChanged<String?> onClassChanged;
  final ValueChanged<String?> onParentChanged;

  @override
  State<_ClassParentDropdowns> createState() => _ClassParentDropdownsState();
}

class _ClassParentDropdownsState extends State<_ClassParentDropdowns> {
  late String? _classId;
  late String? _parentId;

  @override
  void initState() {
    super.initState();
    _classId = widget.classId;
    _parentId = widget.parentId;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownButtonFormField<String?>(
          value: _classId,
          decoration: const InputDecoration(
            labelText: 'Class',
            border: OutlineInputBorder(),
          ),
          items: [
            const DropdownMenuItem(value: null, child: Text('None')),
            ...widget.classes.map(
              (c) => DropdownMenuItem(
                value: c.schoolClass.id,
                child: Text(c.schoolClass.name),
              ),
            ),
          ],
          onChanged: (v) {
            setState(() => _classId = v);
            widget.onClassChanged(v);
          },
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String?>(
          value: _parentId,
          decoration: const InputDecoration(
            labelText: 'Parent',
            border: OutlineInputBorder(),
          ),
          items: [
            const DropdownMenuItem(value: null, child: Text('None')),
            ...widget.parents.map(
              (p) => DropdownMenuItem(
                value: p.id,
                child: Text(p.fullName),
              ),
            ),
          ],
          onChanged: (v) {
            setState(() => _parentId = v);
            widget.onParentChanged(v);
          },
        ),
      ],
    );
  }
}
