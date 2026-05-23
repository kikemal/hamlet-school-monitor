import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/teacher_models.dart';
import '../providers/teacher_providers.dart';

/// Dropdown to pick the active class across teacher tools.
class TeacherClassSelector extends ConsumerWidget {
  const TeacherClassSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classesAsync = ref.watch(teacherAssignedClassesProvider);
    final selectedId = ref.watch(teacherSelectedClassIdProvider);

    return classesAsync.when(
      loading: () => const LinearProgressIndicator(),
      error: (e, _) => Text('Classes: $e'),
      data: (classes) {
        if (classes.isEmpty) {
          return const Text('No classes assigned');
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: DropdownButtonFormField<String>(
            value: selectedId ?? classes.first.schoolClass.id,
            decoration: const InputDecoration(
              labelText: 'Class',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.class_),
            ),
            items: classes
                .map(
                  (c) => DropdownMenuItem(
                    value: c.schoolClass.id,
                    child: Text(
                      '${c.schoolClass.name} (${c.studentCount} students)',
                    ),
                  ),
                )
                .toList(),
            onChanged: (id) {
              ref.read(teacherSelectedClassIdProvider.notifier).select(id);
            },
          ),
        );
      },
    );
  }
}

/// Resolves the selected [TeacherClassItem] if available.
TeacherClassItem? selectedClassItem(WidgetRef ref) {
  final id = ref.watch(teacherSelectedClassIdProvider);
  final classes = ref.watch(teacherAssignedClassesProvider).value;
  if (id == null || classes == null) return null;
  for (final c in classes) {
    if (c.schoolClass.id == id) return c;
  }
  return null;
}
