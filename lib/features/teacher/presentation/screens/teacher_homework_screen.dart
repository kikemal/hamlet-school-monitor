import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../admin/presentation/widgets/admin_validated_field.dart';
import '../../../homework/presentation/widgets/homework_card.dart';
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
          subtitle: 'Create assignments, review submissions, and grade work',
          action: FilledButton.icon(
            onPressed: () => _showHomeworkForm(context, ref),
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
                  onAction: () => _showHomeworkForm(context, ref),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: items.length,
                itemBuilder: (_, i) {
                  final item = items[i];
                  return HomeworkCard.fromTeacher(
                    item,
                    onTap: () => _showSubmissions(context, ref, item),
                    trailing: PopupMenuButton<String>(
                      onSelected: (v) async {
                        if (v == 'edit') {
                          await _showHomeworkForm(context, ref, item: item);
                        } else if (v == 'grade') {
                          _showSubmissions(context, ref, item);
                        } else if (v == 'delete') {
                          await ref
                              .read(teacherRepositoryProvider)
                              .deleteHomework(item.homework.id);
                          ref.invalidate(teacherHomeworkProvider);
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'edit', child: Text('Edit')),
                        PopupMenuItem(value: 'grade', child: Text('Submissions')),
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

  Future<void> _showSubmissions(
    BuildContext context,
    WidgetRef ref,
    TeacherHomeworkItem item,
  ) async {
    if (!context.mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => SizedBox(
        height: MediaQuery.of(ctx).size.height * 0.75,
        child: _SubmissionsSheet(homeworkItem: item),
      ),
    );
  }

  Future<void> _showHomeworkForm(
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
    Uint8List? pickedBytes;
    String? pickedName;

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
                      title: Text('Due ${DateFormat.yMMMd().format(dueDate)}'),
                      trailing: const Icon(Icons.event),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: ctx,
                          initialDate: dueDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) setDialogState(() => dueDate = picked);
                      },
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.attach_file),
                      title: Text(pickedName ?? 'Attach file (optional)'),
                      onTap: () async {
                        final result = await FilePicker.platform.pickFiles(
                          withData: true,
                        );
                        if (result != null && result.files.single.bytes != null) {
                          setDialogState(() {
                            pickedBytes = result.files.single.bytes;
                            pickedName = result.files.single.name;
                          });
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
          attachmentBytes: pickedBytes,
          attachmentFileName: pickedName,
        );
      } else {
        await repo.updateHomework(
          id: item.homework.id,
          title: titleCtrl.text.trim(),
          dueDate: dueDate,
          description: descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
          attachmentBytes: pickedBytes,
          attachmentFileName: pickedName,
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

class _SubmissionsSheet extends ConsumerWidget {
  const _SubmissionsSheet({required this.homeworkItem});

  final TeacherHomeworkItem homeworkItem;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final submissionsAsync = ref.watch(
      teacherHomeworkSubmissionsProvider(homeworkItem.homework.id),
    );

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Submissions — ${homeworkItem.homework.title}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Expanded(
            child: submissionsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text(e.toString())),
              data: (submissions) {
                if (submissions.isEmpty) {
                  return const Center(child: Text('No submissions yet'));
                }
                return ListView.builder(
                  itemCount: submissions.length,
                    itemBuilder: (_, i) {
                      final row = submissions[i];
                      return Card(
                        child: ListTile(
                          title: Text(row.studentName),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (row.submission.submissionText != null)
                                Text(row.submission.submissionText!),
                              Text('Status: ${row.submission.status}'),
                              if (row.submission.gradedMarks != null)
                                Text('Marks: ${row.submission.gradedMarks}'),
                            ],
                          ),
                          trailing: row.submission.status == 'graded'
                              ? const Icon(Icons.check, color: Colors.green)
                              : IconButton(
                                  icon: const Icon(Icons.grade),
                                  onPressed: () => _gradeSubmission(
                                    context,
                                    ref,
                                    row,
                                  ),
                                ),
                        ),
                      );
                    },
                  );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _gradeSubmission(
    BuildContext context,
    WidgetRef ref,
    TeacherHomeworkSubmissionItem row,
  ) async {
    final marksCtrl = TextEditingController(
      text: row.submission.gradedMarks?.toString() ?? '',
    );

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Grade ${row.studentName}'),
        content: TextField(
          controller: marksCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Marks',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Save')),
        ],
      ),
    );

    if (ok != true) {
      marksCtrl.dispose();
      return;
    }

    final marks = double.tryParse(marksCtrl.text.trim());
    marksCtrl.dispose();
    if (marks == null) return;

    try {
      await ref.read(teacherRepositoryProvider).gradeHomeworkSubmission(
            submissionId: row.submission.id,
            gradedMarks: marks,
          );
      ref.invalidate(teacherHomeworkSubmissionsProvider(homeworkItem.homework.id));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Submission graded')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }
}
