import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../admin/presentation/widgets/admin_validated_field.dart';
import '../../../../core/utils/app_validator.dart';
import '../providers/teacher_providers.dart';
import '../widgets/teacher_class_selector.dart';
import '../widgets/teacher_page_header.dart';

class TeacherResultsScreen extends ConsumerStatefulWidget {
  const TeacherResultsScreen({super.key});

  @override
  ConsumerState<TeacherResultsScreen> createState() =>
      _TeacherResultsScreenState();
}

class _TeacherResultsScreenState extends ConsumerState<TeacherResultsScreen> {
  Future<void> _uploadResult() async {
    final classId = ref.read(teacherSelectedClassIdProvider);
    final teacherId = ref.read(teacherIdProvider);
    if (classId == null || teacherId == null) return;

    final students =
        await ref.read(teacherRepositoryProvider).fetchClassStudents(classId);
    final subjects = await ref.read(teacherSubjectsProvider.future);
    if (students.isEmpty || subjects.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Need students and subjects first')),
        );
      }
      return;
    }

    String? studentId = students.first.id;
    String? subjectId = subjects.first.id;
    final examCtrl = TextEditingController();
    final marksCtrl = TextEditingController();
    final maxCtrl = TextEditingController(text: '100');
    var examDate = DateTime.now();

    if (!mounted) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final formKey = GlobalKey<FormState>();
        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: const Text('Upload exam result'),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: studentId,
                      decoration: const InputDecoration(
                        labelText: 'Student',
                        border: OutlineInputBorder(),
                      ),
                      items: students
                          .map(
                            (s) => DropdownMenuItem(
                              value: s.id,
                              child: Text(s.fullName),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => studentId = v,
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
                    AdminValidatedField.required(examCtrl, 'Exam name'),
                    AdminValidatedField(
                      controller: marksCtrl,
                      label: 'Marks obtained',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (v) => AppValidator.validateMarks(
                        v,
                        maxMarks: double.tryParse(maxCtrl.text),
                      ),
                    ),
                    AdminValidatedField.amount(maxCtrl),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(DateFormat.yMMMd().format(examDate)),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: ctx,
                          initialDate: examDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setDialogState(() => examDate = picked);
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
                child: const Text('Upload'),
              ),
            ],
          ),
        );
      },
    );

    if (ok != true || studentId == null || subjectId == null) {
      examCtrl.dispose();
      marksCtrl.dispose();
      maxCtrl.dispose();
      return;
    }

    try {
      await ref.read(teacherRepositoryProvider).uploadResult(
            studentId: studentId!,
            subjectId: subjectId!,
            examName: examCtrl.text.trim(),
            marksObtained: double.parse(marksCtrl.text.trim()),
            maxMarks: double.parse(maxCtrl.text.trim()),
            date: examDate,
          );
      teacherInvalidateAll(ref);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Result uploaded')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      examCtrl.dispose();
      marksCtrl.dispose();
      maxCtrl.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final classId = ref.watch(teacherSelectedClassIdProvider);

    return Column(
      children: [
        TeacherPageHeader(
          title: 'Exam results',
          subtitle: 'Upload marks for your students',
          action: FilledButton.icon(
            onPressed: _uploadResult,
            icon: const Icon(Icons.upload),
            label: const Text('Upload'),
          ),
        ),
        const TeacherClassSelector(),
        Expanded(
          child: classId == null
              ? const Center(child: Text('Select a class'))
              : FutureBuilder(
                  future: ref
                      .read(teacherRepositoryProvider)
                      .fetchRecentResultsForClass(classId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final results = snapshot.data ?? [];
                    if (results.isEmpty) {
                      return const Center(child: Text('No results yet'));
                    }
                    return ListView.builder(
                      itemCount: results.length,
                      itemBuilder: (_, i) {
                        final r = results[i];
                        final pct = r.maxMarks > 0
                            ? (r.marksObtained / r.maxMarks * 100)
                            : 0.0;
                        return ListTile(
                          title: Text(r.examName),
                          subtitle: Text(DateFormat.yMMMd().format(r.date)),
                          trailing: Text(
                            '${r.marksObtained}/${r.maxMarks} (${pct.toStringAsFixed(0)}%)',
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
}
