import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/teacher_models.dart';
import '../providers/teacher_providers.dart';
import '../widgets/teacher_loading_view.dart';
import '../widgets/teacher_page_header.dart';

/// Roster for a single class — opened from [TeacherClassesScreen].
class TeacherClassStudentsScreen extends ConsumerStatefulWidget {
  const TeacherClassStudentsScreen({
    super.key,
    required this.classId,
    required this.className,
  });

  final String classId;
  final String className;

  @override
  ConsumerState<TeacherClassStudentsScreen> createState() =>
      _TeacherClassStudentsScreenState();
}

class _TeacherClassStudentsScreenState
    extends ConsumerState<TeacherClassStudentsScreen> {
  late Future<List<TeacherStudentItem>> _studentsFuture;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _studentsFuture =
        ref.read(teacherRepositoryProvider).fetchClassStudents(widget.classId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.className)),
      body: Column(
        children: [
          TeacherPageHeader(
            title: 'Students',
            subtitle: widget.className,
          ),
          Expanded(
            child: FutureBuilder<List<TeacherStudentItem>>(
              future: _studentsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const TeacherLoadingView();
                }
                if (snapshot.hasError) {
                  return Center(child: Text(snapshot.error.toString()));
                }
                final students = snapshot.data ?? [];
                if (students.isEmpty) {
                  return const Center(child: Text('No students in this class'));
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: students.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final s = students[i];
                    return ListTile(
                      leading: CircleAvatar(child: Text(s.firstName[0])),
                      title: Text(s.fullName),
                      subtitle: Text(s.parentId != null ? 'Parent linked' : 'No parent'),
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
}
