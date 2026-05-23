import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/models/teacher_models.dart';
import '../providers/teacher_providers.dart';
import '../widgets/teacher_class_selector.dart';
import '../widgets/teacher_page_header.dart';

class TeacherAttendanceScreen extends ConsumerStatefulWidget {
  const TeacherAttendanceScreen({super.key});

  @override
  ConsumerState<TeacherAttendanceScreen> createState() =>
      _TeacherAttendanceScreenState();
}

class _TeacherAttendanceScreenState extends ConsumerState<TeacherAttendanceScreen> {
  DateTime _date = DateTime.now();
  List<TeacherAttendanceRow> _rows = [];
  bool _loading = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadSheet());
  }

  Future<void> _loadSheet() async {
    final classId = ref.read(teacherSelectedClassIdProvider);
    if (classId == null) return;

    setState(() => _loading = true);
    try {
      final rows = await ref.read(teacherRepositoryProvider).fetchAttendanceSheet(
            classId: classId,
            date: _date,
          );
      if (mounted) setState(() => _rows = rows);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    final classId = ref.read(teacherSelectedClassIdProvider);
    if (classId == null || _rows.isEmpty) return;

    setState(() => _saving = true);
    try {
      await ref.read(teacherRepositoryProvider).saveAttendance(
            classId: classId,
            date: _date,
            rows: _rows,
          );
      teacherInvalidateAll(ref);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Attendance saved')),
        );
      }
      await _loadSheet();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _setStatus(int index, String status) {
    setState(() {
      _rows[index] = _rows[index].copyWith(status: status);
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(teacherSelectedClassIdProvider, (_, __) => _loadSheet());

    return Column(
      children: [
        TeacherPageHeader(
          title: 'Take attendance',
          subtitle: DateFormat.yMMMd().format(_date),
          action: FilledButton.icon(
            onPressed: _saving || _rows.isEmpty ? null : _save,
            icon: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
            label: const Text('Save'),
          ),
        ),
        const TeacherClassSelector(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              OutlinedButton.icon(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _date,
                    firstDate: DateTime.now().subtract(const Duration(days: 30)),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() => _date = picked);
                    await _loadSheet();
                  }
                },
                icon: const Icon(Icons.calendar_today),
                label: const Text('Change date'),
              ),
            ],
          ),
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _rows.isEmpty
                  ? const Center(child: Text('No students in this class'))
                  : ListView.builder(
                      itemCount: _rows.length,
                      itemBuilder: (_, i) {
                        final row = _rows[i];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  row.student.fullName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SegmentedButton<String>(
                                  segments: const [
                                    ButtonSegment(
                                      value: 'present',
                                      label: Text('Present'),
                                      icon: Icon(Icons.check, size: 16),
                                    ),
                                    ButtonSegment(
                                      value: 'late',
                                      label: Text('Late'),
                                      icon: Icon(Icons.schedule, size: 16),
                                    ),
                                    ButtonSegment(
                                      value: 'absent',
                                      label: Text('Absent'),
                                      icon: Icon(Icons.close, size: 16),
                                    ),
                                  ],
                                  selected: {row.status},
                                  onSelectionChanged: (s) =>
                                      _setStatus(i, s.first),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}
