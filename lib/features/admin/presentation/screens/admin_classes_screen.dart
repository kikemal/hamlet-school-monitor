import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/admin_models.dart';
import '../providers/admin_providers.dart';
import '../widgets/admin_empty_state.dart';
import '../widgets/admin_error_view.dart';
import '../widgets/admin_form_dialog.dart';
import '../widgets/admin_loading_view.dart';
import '../widgets/admin_page_header.dart';
import '../widgets/admin_validated_field.dart';

class AdminClassesScreen extends ConsumerWidget {
  const AdminClassesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(adminClassesProvider);

    return Column(
      children: [
        AdminPageHeader(
          title: 'Classes',
          subtitle: 'Create classes and assign homeroom teachers',
          action: FilledButton.icon(
            onPressed: () => _showForm(context, ref),
            icon: const Icon(Icons.add),
            label: const Text('Add'),
          ),
        ),
        Expanded(
          child: async.when(
            loading: () => const AdminLoadingView(),
            error: (e, _) => AdminErrorView(
              message: e.toString(),
              onRetry: () => ref.invalidate(adminClassesProvider),
            ),
            data: (items) => items.isEmpty
                ? AdminEmptyState(
                    message: 'No classes yet.',
                    actionLabel: 'Add class',
                    onAction: () => _showForm(context, ref),
                  )
                : ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (_, i) {
                      final c = items[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.purple.shade100,
                            child: const Icon(Icons.class_, color: Colors.purple),
                          ),
                          title: Text(c.schoolClass.name),
                          subtitle: Text(
                            'Teacher: ${c.teacherName ?? 'Unassigned'} · ${c.studentCount} students',
                          ),
                          trailing: PopupMenuButton(
                            onSelected: (v) async {
                              if (v == 'edit') {
                                await _showForm(context, ref, item: c);
                              }
                              if (v == 'assign') {
                                await _assignTeacher(context, ref, c);
                              }
                              if (v == 'delete') {
                                await _delete(context, ref, c);
                              }
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(value: 'edit', child: Text('Edit')),
                              PopupMenuItem(value: 'assign', child: Text('Assign teacher')),
                              PopupMenuItem(value: 'delete', child: Text('Delete')),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  Future<void> _showForm(
    BuildContext context,
    WidgetRef ref, {
    ClassListItem? item,
  }) async {
    final schoolId = ref.read(adminSchoolIdProvider);
    if (schoolId == null) return;

    final teachers = await ref.read(adminTeacherOptionsProvider.future);
    final name = TextEditingController(text: item?.schoolClass.name ?? '');
    String? teacherId = item?.schoolClass.teacherId;

    final ok = await showAdminFormDialog(
      context: context,
      title: item == null ? 'Add class' : 'Edit class',
      fields: [
        AdminValidatedField.required(name, 'Class name'),
        _TeacherDropdown(
          teachers: teachers,
          teacherId: teacherId,
          onChanged: (v) => teacherId = v,
        ),
      ],
    );

    if (ok != true) {
      name.dispose();
      return;
    }

    try {
      final repo = ref.read(adminRepositoryProvider);
      if (item == null) {
        await repo.createClass(
          schoolId: schoolId,
          name: name.text.trim(),
          teacherId: teacherId,
        );
      } else {
        await repo.updateClass(
          id: item.schoolClass.id,
          name: name.text.trim(),
          teacherId: teacherId,
        );
      }
      adminInvalidateAll(ref);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Class saved')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      name.dispose();
    }
  }

  Future<void> _assignTeacher(
    BuildContext context,
    WidgetRef ref,
    ClassListItem item,
  ) async {
    final teachers = await ref.read(adminTeacherOptionsProvider.future);
    String? teacherId = item.schoolClass.teacherId;

    final ok = await showAdminFormDialog(
      context: context,
      title: 'Assign teacher — ${item.schoolClass.name}',
      confirmLabel: 'Assign',
      fields: [
        _TeacherDropdown(
          teachers: teachers,
          teacherId: teacherId,
          onChanged: (v) => teacherId = v,
        ),
      ],
    );
    if (ok != true) return;

    await ref.read(adminRepositoryProvider).assignTeacher(
          classId: item.schoolClass.id,
          teacherId: teacherId,
        );
    adminInvalidateAll(ref);
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    ClassListItem item,
  ) async {
    final ok = await showAdminConfirmDialog(
      context: context,
      title: 'Delete class?',
      message: 'Delete ${item.schoolClass.name}? Students will be unassigned from this class.',
    );
    if (!ok) return;
    await ref.read(adminRepositoryProvider).deleteClass(item.schoolClass.id);
    adminInvalidateAll(ref);
  }
}

class _TeacherDropdown extends StatefulWidget {
  const _TeacherDropdown({
    required this.teachers,
    required this.teacherId,
    required this.onChanged,
  });

  final List<Map<String, String>> teachers;
  final String? teacherId;
  final ValueChanged<String?> onChanged;

  @override
  State<_TeacherDropdown> createState() => _TeacherDropdownState();
}

class _TeacherDropdownState extends State<_TeacherDropdown> {
  late String? _value;

  @override
  void initState() {
    super.initState();
    _value = widget.teacherId;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String?>(
      value: _value,
      decoration: const InputDecoration(
        labelText: 'Homeroom teacher',
        border: OutlineInputBorder(),
      ),
      items: [
        const DropdownMenuItem(value: null, child: Text('Unassigned')),
        ...widget.teachers.map(
          (t) => DropdownMenuItem(
            value: t['id'],
            child: Text(t['name']!),
          ),
        ),
      ],
      onChanged: (v) {
        setState(() => _value = v);
        widget.onChanged(v);
      },
    );
  }
}
