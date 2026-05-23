import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/teacher_providers.dart';
import '../widgets/teacher_empty_state.dart';
import '../widgets/teacher_error_view.dart';
import '../widgets/teacher_loading_view.dart';
import '../widgets/teacher_page_header.dart';
import 'teacher_class_students_screen.dart';

class TeacherClassesScreen extends ConsumerWidget {
  const TeacherClassesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classesAsync = ref.watch(teacherAssignedClassesProvider);

    return Column(
      children: [
        const TeacherPageHeader(
          title: 'My classes',
          subtitle: 'Homeroom and timetable assignments',
        ),
        Expanded(
          child: classesAsync.when(
            loading: () => const TeacherLoadingView(),
            error: (e, _) => TeacherErrorView(
              message: e.toString(),
              onRetry: () => ref.invalidate(teacherAssignedClassesProvider),
            ),
            data: (classes) {
              if (classes.isEmpty) {
                return const TeacherEmptyState(
                  message: 'No classes assigned yet. Contact your admin.',
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: classes.length,
                itemBuilder: (_, i) {
                  final item = classes[i];
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.teal.shade100,
                        child: Text(item.schoolClass.name[0]),
                      ),
                      title: Text(item.schoolClass.name),
                      subtitle: Text(
                        '${item.studentCount} students'
                        '${item.isHomeroom ? ' · Homeroom' : ''}',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        ref
                            .read(teacherSelectedClassIdProvider.notifier)
                            .select(item.schoolClass.id);
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => TeacherClassStudentsScreen(
                              classId: item.schoolClass.id,
                              className: item.schoolClass.name,
                            ),
                          ),
                        );
                      },
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
