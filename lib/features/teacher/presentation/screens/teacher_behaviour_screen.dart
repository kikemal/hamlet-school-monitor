import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../admin/presentation/widgets/admin_validated_field.dart';
import '../../../behaviour/domain/models/behaviour_models.dart';
import '../../../behaviour/presentation/widgets/behaviour_log_card.dart';
import '../../../../core/utils/app_validator.dart';
import '../providers/teacher_providers.dart';
import '../widgets/teacher_class_selector.dart';
import '../widgets/teacher_empty_state.dart';
import '../widgets/teacher_page_header.dart';

class TeacherBehaviourScreen extends ConsumerStatefulWidget {
  const TeacherBehaviourScreen({super.key});

  @override
  ConsumerState<TeacherBehaviourScreen> createState() =>
      _TeacherBehaviourScreenState();
}

class _TeacherBehaviourScreenState extends ConsumerState<TeacherBehaviourScreen> {
  List<BehaviourLogDisplayItem> _logs = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final classId = ref.read(teacherSelectedClassIdProvider);
    if (classId == null) return;
    setState(() => _loading = true);
    try {
      final logs = await ref
          .read(teacherRepositoryProvider)
          .fetchBehaviourForClass(classId);
      if (mounted) setState(() => _logs = logs);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _logIncident() async {
    final classId = ref.read(teacherSelectedClassIdProvider);
    final teacherId = ref.read(teacherIdProvider);
    if (classId == null || teacherId == null) return;

    final students =
        await ref.read(teacherRepositoryProvider).fetchClassStudents(classId);
    if (students.isEmpty) return;

    String? studentId = students.first.id;
    var incidentType = 'negative';
    var severity = 'moderate';
    final descCtrl = TextEditingController();
    var date = DateTime.now();

    if (!mounted) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final formKey = GlobalKey<FormState>();
        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: const Text('Log discipline incident'),
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
                      value: incidentType,
                      decoration: const InputDecoration(
                        labelText: 'Type',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'positive',
                          child: Text('Positive recognition'),
                        ),
                        DropdownMenuItem(
                          value: 'negative',
                          child: Text('Discipline incident'),
                        ),
                      ],
                      onChanged: (v) {
                        if (v != null) setDialogState(() => incidentType = v);
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: severity,
                      decoration: const InputDecoration(
                        labelText: 'Severity',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'minor', child: Text('Minor')),
                        DropdownMenuItem(
                          value: 'moderate',
                          child: Text('Moderate'),
                        ),
                        DropdownMenuItem(
                          value: 'serious',
                          child: Text('Serious'),
                        ),
                      ],
                      onChanged: (v) {
                        if (v != null) setDialogState(() => severity = v);
                      },
                    ),
                    const SizedBox(height: 12),
                    AdminValidatedField(
                      controller: descCtrl,
                      label: 'Description',
                      maxLines: 4,
                      validator: (v) =>
                          AppValidator.validateRequired(v, 'Description'),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('Date: ${date.toString().split(' ').first}'),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: ctx,
                          initialDate: date,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setDialogState(() => date = picked);
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

    if (ok != true || studentId == null) {
      descCtrl.dispose();
      return;
    }

    try {
      await ref.read(teacherRepositoryProvider).createBehaviourLog(
            studentId: studentId!,
            teacherId: teacherId,
            incidentType: incidentType,
            severity: severity,
            notes: descCtrl.text.trim(),
            date: date,
          );
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Incident logged — parent notified')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      descCtrl.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(teacherSelectedClassIdProvider, (_, __) => _load());

    return Column(
      children: [
        TeacherPageHeader(
          title: 'Behaviour log',
          subtitle: 'Log incidents with minor, moderate, or serious severity',
          action: FilledButton.icon(
            onPressed: _logIncident,
            icon: const Icon(Icons.add),
            label: const Text('Log incident'),
          ),
        ),
        const TeacherClassSelector(),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _logs.isEmpty
                  ? const TeacherEmptyState(
                      message: 'No behaviour logs for this class yet.',
                    )
                  : ListView.builder(
                      itemCount: _logs.length,
                      itemBuilder: (_, i) => BehaviourLogCard(
                        item: _logs[i],
                        onDelete: () async {
                          await ref
                              .read(teacherRepositoryProvider)
                              .deleteBehaviourLog(_logs[i].log.id);
                          await _load();
                        },
                      ),
                    ),
        ),
      ],
    );
  }
}
