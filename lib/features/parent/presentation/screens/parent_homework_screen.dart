import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../homework/presentation/widgets/homework_card.dart';
import '../providers/parent_providers.dart';
import '../widgets/parent_error_view.dart';
import '../widgets/parent_loading_view.dart';
import '../widgets/parent_page_header.dart';

class ParentHomeworkScreen extends ConsumerWidget {
  const ParentHomeworkScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeworkAsync = ref.watch(childHomeworkProvider);
    final selectedChild = ref.watch(selectedChildProvider);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: ParentPageHeader(
            title: 'Homework',
            subtitle: selectedChild != null
                ? 'Tracking ${selectedChild!.fullName}\'s assignments'
                : 'Select a child to view homework',
          ),
        ),
        homeworkAsync.when(
          loading: () => const SliverToBoxAdapter(child: ParentLoadingView()),
          error: (e, _) => SliverToBoxAdapter(
            child: ParentErrorView(
              message: e.toString(),
              onRetry: () => ref.invalidate(childHomeworkProvider),
            ),
          ),
          data: (homework) {
            if (homework.isEmpty) {
              return SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Center(
                    child: Text(
                      'No homework found',
                      style: AppTypography.bodyMedium,
                    ),
                  ),
                ),
              );
            }

            final pendingCount = homework.where((h) => !h.isSubmitted).length;
            final overdueCount = homework.where((h) => h.isOverdue).length;

            return SliverToBoxAdapter(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(20.w),
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(20.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _SummaryStat(
                              value: '$pendingCount',
                              label: 'Pending',
                              color: Colors.orange,
                            ),
                            _SummaryStat(
                              value: '${homework.length - pendingCount}',
                              label: 'Submitted',
                              color: AppColors.success,
                            ),
                            _SummaryStat(
                              value: '$overdueCount',
                              label: 'Overdue',
                              color: AppColors.error,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: homework.length,
                      itemBuilder: (context, index) {
                        return HomeworkCard.fromParent(homework[index]);
                      },
                    ),
                  ),
                  SizedBox(height: 24.h),
                ],
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
    required this.value,
    required this.label,
    required this.color,
  });

  final String value;
  final String label;
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
