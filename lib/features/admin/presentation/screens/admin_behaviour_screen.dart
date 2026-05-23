import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../behaviour/presentation/providers/behaviour_providers.dart';
import '../../../behaviour/presentation/widgets/behaviour_log_card.dart';
import '../../../teacher/admin/presentation/providers/admin_providers.dart';
import '../../../teacher/admin/presentation/widgets/admin_empty_state.dart';
import '../../../teacher/admin/presentation/widgets/admin_error_view.dart';
import '../../../teacher/admin/presentation/widgets/admin_loading_view.dart';
import '../../../teacher/admin/presentation/widgets/admin_page_header.dart';

class AdminBehaviourScreen extends ConsumerWidget {
  const AdminBehaviourScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schoolAsync = ref.watch(adminSchoolProvider);
    final logsAsync = ref.watch(adminSchoolBehaviourProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AdminPageHeader(
          title: 'Behaviour & discipline',
          subtitle: 'All incidents across the school',
        ),
        Expanded(
          child: schoolAsync.when(
            loading: () => const AdminLoadingView(),
            error: (e, _) => AdminErrorView(
              message: e.toString(),
              onRetry: () => ref.invalidate(adminSchoolProvider),
            ),
            data: (school) {
              if (school == null) {
                return const AdminEmptyState(message: 'No school configured.');
              }
              return logsAsync.when(
                loading: () => const AdminLoadingView(),
                error: (e, _) => AdminErrorView(
                  message: e.toString(),
                  onRetry: () =>
                      ref.invalidate(adminSchoolBehaviourProvider),
                ),
                data: (logs) {
                  if (logs.isEmpty) {
                    return const AdminEmptyState(
                      message: 'No behaviour logs recorded yet.',
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 24),
                    itemCount: logs.length,
                    itemBuilder: (_, i) => BehaviourLogCard(
                      item: logs[i],
                      showStudentName: true,
                      showTeacherName: true,
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

final adminSchoolBehaviourProvider =
    FutureProvider.autoDispose((ref) async {
  final school = await ref.watch(adminSchoolProvider.future);
  if (school == null) return [];
  return ref.read(behaviourRepositoryProvider).fetchSchoolLogs(school.id);
});
