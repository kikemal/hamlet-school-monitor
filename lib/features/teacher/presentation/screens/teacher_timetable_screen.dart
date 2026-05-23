import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/teacher_providers.dart';
import '../widgets/teacher_empty_state.dart';
import '../widgets/teacher_error_view.dart';
import '../widgets/teacher_loading_view.dart';
import '../widgets/teacher_page_header.dart';
import '../widgets/teacher_timetable_week.dart';

class TeacherTimetableScreen extends ConsumerWidget {
  const TeacherTimetableScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timetableAsync = ref.watch(teacherTimetableProvider);

    return Column(
      children: [
        const TeacherPageHeader(
          title: 'My timetable',
          subtitle: 'Weekly teaching schedule',
        ),
        Expanded(
          child: timetableAsync.when(
            loading: () => const TeacherLoadingView(),
            error: (e, _) => TeacherErrorView(
              message: e.toString(),
              onRetry: () => ref.invalidate(teacherTimetableProvider),
            ),
            data: (slots) {
              if (slots.isEmpty) {
                return const TeacherEmptyState(
                  message: 'No timetable entries yet. Ask admin to set up your schedule.',
                );
              }
              return TeacherTimetableWeek(slots: slots);
            },
          ),
        ),
      ],
    );
  }
}
