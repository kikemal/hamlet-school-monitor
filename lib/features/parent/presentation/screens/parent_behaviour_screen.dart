import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../behaviour/domain/models/behaviour_models.dart';
import '../../../behaviour/presentation/providers/behaviour_providers.dart';
import '../../../behaviour/presentation/widgets/behaviour_log_card.dart';
import '../../domain/models/parent_models.dart';
import '../providers/parent_providers.dart';
import '../widgets/parent_error_view.dart';
import '../widgets/parent_loading_view.dart';
import '../widgets/parent_page_header.dart';

class ParentBehaviourScreen extends ConsumerWidget {
  const ParentBehaviourScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final behaviourAsync = ref.watch(childBehaviourProvider);
    final summaryAsync = ref.watch(childBehaviourSummaryProvider);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: ParentPageHeader(
            title: 'Behaviour Log',
            subtitle: 'Discipline records for your child',
          ),
        ),
        summaryAsync.when(
          loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
          error: (_, __) => const SliverToBoxAdapter(child: SizedBox.shrink()),
          data: (summary) => SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _SummaryStat(
                        label: 'Minor',
                        value: '${summary.minor}',
                        color: Colors.amber,
                      ),
                      _SummaryStat(
                        label: 'Moderate',
                        value: '${summary.moderate}',
                        color: Colors.orange,
                      ),
                      _SummaryStat(
                        label: 'Serious',
                        value: '${summary.serious}',
                        color: AppColors.error,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        behaviourAsync.when(
          loading: () => const SliverToBoxAdapter(child: ParentLoadingView()),
          error: (e, _) => SliverToBoxAdapter(
            child: ParentErrorView(
              message: e.toString(),
              onRetry: () => ref.invalidate(childBehaviourProvider),
            ),
          ),
          data: (logs) {
            if (logs.isEmpty) {
              return SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Center(
                    child: Text(
                      'No behaviour records found',
                      style: AppTypography.bodyMedium,
                    ),
                  ),
                ),
              );
            }

            final items = logs
                .map(
                  (l) => BehaviourLogDisplayItem.fromLog(
                    l.log,
                    teacherName: l.teacherName,
                  ),
                )
                .toList();

            return SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  itemBuilder: (_, i) => BehaviourLogCard(
                    item: items[i],
                    showStudentName: false,
                    showTeacherName: true,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppTypography.h2.copyWith(color: color)),
        SizedBox(height: 4.h),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }
}
