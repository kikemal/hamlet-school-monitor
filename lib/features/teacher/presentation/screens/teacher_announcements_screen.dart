import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../admin/presentation/widgets/admin_validated_field.dart';
import '../../../../core/utils/app_validator.dart';
import '../../../shared/domain/entities/announcement.dart';
import '../providers/teacher_providers.dart';
import '../widgets/teacher_class_selector.dart';
import '../widgets/teacher_page_header.dart';

/// Compose and send class-wide announcements (students + parents notified).
class TeacherAnnouncementsScreen extends ConsumerStatefulWidget {
  const TeacherAnnouncementsScreen({super.key});

  @override
  ConsumerState<TeacherAnnouncementsScreen> createState() =>
      _TeacherAnnouncementsScreenState();
}

class _TeacherAnnouncementsScreenState
    extends ConsumerState<TeacherAnnouncementsScreen> {
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _sending = false;
  List<Announcement> _history = [];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadHistory());
  }

  Future<void> _loadHistory() async {
    final classId = ref.read(teacherSelectedClassIdProvider);
    if (classId == null) return;
    final items =
        await ref.read(teacherRepositoryProvider).fetchClassAnnouncements(classId);
    if (mounted) setState(() => _history = items);
  }

  Future<void> _publish() async {
    if (!_formKey.currentState!.validate()) return;

    final classId = ref.read(teacherSelectedClassIdProvider);
    final teacherId = ref.read(teacherIdProvider);
    final schoolId = ref.read(teacherSchoolIdProvider).value;
    if (classId == null || teacherId == null || schoolId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Missing class or school context')),
      );
      return;
    }

    setState(() => _sending = true);
    try {
      await ref.read(teacherRepositoryProvider).publishClassAnnouncement(
            schoolId: schoolId,
            classId: classId,
            teacherId: teacherId,
            title: _titleCtrl.text.trim(),
            content: _contentCtrl.text.trim(),
          );
      _titleCtrl.clear();
      _contentCtrl.clear();
      await _loadHistory();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Announcement sent to all students and parents in this class',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(teacherSelectedClassIdProvider, (_, __) => _loadHistory());

    return Column(
      children: [
        const TeacherPageHeader(
          title: 'Class announcements',
          subtitle: 'Notify every student and parent in the class',
        ),
        const TeacherClassSelector(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.campaign,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Publishing sends an in-app notification to each student and linked parent.',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  AdminValidatedField.required(_titleCtrl, 'Title'),
                  AdminValidatedField(
                    controller: _contentCtrl,
                    label: 'Message',
                    maxLines: 6,
                    validator: (v) => AppValidator.validateRequired(v, 'Message'),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _sending ? null : _publish,
                    icon: _sending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send),
                    label: const Text('Send to class'),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Recent announcements',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  if (_history.isEmpty)
                    const Text('No announcements yet for this class')
                  else
                    ..._history.map(
                      (a) => Card(
                        child: ListTile(
                          title: Text(a.title),
                          subtitle: Text(a.content),
                          trailing: a.createdAt != null
                              ? Text(
                                  DateFormat.MMMd().format(a.createdAt!),
                                  style: Theme.of(context).textTheme.bodySmall,
                                )
                              : null,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
