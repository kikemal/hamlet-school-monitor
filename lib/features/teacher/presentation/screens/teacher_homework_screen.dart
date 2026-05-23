import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../admin/presentation/widgets/admin_validated_field.dart';
import '../../../../core/utils/app_validator.dart';
import '../../domain/models/teacher_models.dart';
import '../providers/teacher_providers.dart';
import '../widgets/teacher_empty_state.dart';
import '../widgets/teacher_error_view.dart';
import '../widgets/teacher_loading_view.dart';
import '../widgets/teacher_page_header.dart';

class TeacherHomeworkScreen extends ConsumerWidget {
  const TeacherHomeworkScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeworkAsync = ref.watch(teacherHomeworkProvider);

    return Column(
      children: [
        TeacherPageHeader(
          title: 'Homework',
          subtitle: 'Create and manage assignments',
          action: FilledButton.icon(
            onPressed: () => _showForm(context, ref),
            icon: const Icon(Icons.add),
            label: const Text('Add'),
          ),
        ),
        Expanded(
          child: homeworkAsync.when(
            loading: () => const TeacherLoadingView(),
            error: (e, _) => TeacherErrorView(
              message: e.toString(),
              onRetry: () => ref.invalidate(teacherHomeworkProvider),
            ),
            data: (items) {
              if (items.isEmpty) {
                return TeacherEmptyState(
                  message: 'No homework yet.',
                  actionLabel: 'Create homework',
                  onAction: () => _showForm(context, ref),
                );
              }
              return ListView.builder(
                itemCount: items.length,
                itemBuilder: (_, i) {
                  final item = items[i];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.orange.shade100,
                        child: const Icon(Icons.assignment, color: Colors.orange),
                      ),
                      title: Text(item.homework.title),
                      subtitle: Text(
                        '${item.className} · ${item.subjectName}\n'
                        'Due ${DateFormat.yMMMd().format(item.homework.dueDate)}',
                      ),
                      isThreeLine: true,
                      trailing: PopupMenuButton(
                        onSelected: (v) async {
                          if (v == 'edit') {
                            await _showForm(context, ref, item: item);
                          }
                          if (v == 'delete') {
                            await ref
                                .read(teacherRepositoryProvider)
                                .deleteHomework(item.homework.id);
                            ref.invalidate(teacherHomeworkProvider);
                          }
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(value: 'edit', child: Text('Edit')),
                          PopupMenuItem(value: 'delete', child: Text('Delete')),
                        ],
                      ),
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
    TeacherHomeworkItem? item,
  }) async {
    final teacherId = ref.read(teacherIdProvider);
    final classes = await ref.read(teacherAssignedClassesProvider.future);
    final subjects = await ref.read(teacherSubjectsProvider.future);
    if (teacherId == null || classes.isEmpty || subjects.isEmpty) return;

    final titleCtrl = TextEditingController(text: item?.homework.title ?? '');
    final descCtrl = TextEditingController(text: item?.homework.description ?? '');
    String? classId = item?.homework.classId ?? ref.read(teacherSelectedClassIdProvider);
    String? subjectId = item?.homework.subjectId ?? subjects.first.id;
    var dueDate = item?.homework.dueDate ?? DateTime.now().add(const Duration(days: 7));

    if (!context.mounted) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final formKey = GlobalKey<FormState>();
        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: Text(item == null ? 'New homework' : 'Edit homework'),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (item == null) ...[
                      DropdownButtonFormField<String>(
                        value: classId,
                        decoration: const InputDecoration(
                          labelText: 'Class',
                          border: OutlineInputBorder(),
                        ),
                        items: classes
                            .map(
                              (c) => DropdownMenuItem(
                                value: c.schoolClass.id,
                                child: Text(c.schoolClass.name),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => classId = v,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: subjectId,
                        decoration: const InputDecoration(
                          labelText: 'Subject',
                          border: OutlineInputBorder(),
                        ),
                        items: subjects
                            .map(
                              (s) => DropdownMenuItem(
                                value: s.id,
                                child: Text(s.name),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => subjectId = v,
                      ),
                      const SizedBox(height: 12),
                    ],
                    AdminValidatedField.required(titleCtrl, 'Title'),
                    AdminValidatedField(
                      controller: descCtrl,
                      label: 'Description',
                      maxLines: 3,
                      validator: (v) => AppValidator.validateOptionalMaxLength(
                        v,
                        1000,
                        fieldName: 'Description',
                      ),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'Due ${DateFormat.yMMMd().format(dueDate)}',
                      ),
                      trailing: const Icon(Icons.event),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: ctx,
                          initialDate: dueDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) {
                          setDialogState(() => dueDate = picked);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    Navigator.pop(ctx, true);
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
        );
      },
    );

    if (ok != true) {
      titleCtrl.dispose();
      descCtrl.dispose();
      return;
    }

    final repo = ref.read(teacherRepositoryProvider);
    try {
      if (item == null) {
        await repo.createHomework(
          classId: classId!,
          subjectId: subjectId!,
          teacherId: teacherId,
          title: titleCtrl.text.trim(),
          dueDate: dueDate,
          description: descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
        );
      } else {
        await repo.updateHomework(
          id: item.homework.id,
          title: titleCtrl.text.trim(),
          dueDate: dueDate,
          description: descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
        );
      }
      ref.invalidate(teacherHomeworkProvider);
      teacherInvalidateAll(ref);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Homework saved')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      titleCtrl.dispose();
      descCtrl.dispose();
    }
  }
}
