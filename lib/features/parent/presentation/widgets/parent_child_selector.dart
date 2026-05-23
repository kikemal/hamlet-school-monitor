import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/models/parent_models.dart';
import '../providers/parent_providers.dart';
import 'parent_child_card.dart';

class ParentChildSelector extends ConsumerWidget {
  const ParentChildSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final childrenAsync = ref.watch(parentChildrenProvider);
    final selectedChild = ref.watch(selectedChildProvider);

    return childrenAsync.when(
      loading: () => _buildLoading(),
      error: (e, _) => _buildError(e.toString()),
      data: (children) {
        if (children.isEmpty) {
          return _buildEmpty();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Text(
                'My Children',
                style: AppTypography.h3,
              ),
            ),
            SizedBox(height: 12.h),
            SizedBox(
              height: 100.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                itemCount: children.length,
                itemBuilder: (context, index) {
                  final child = children[index];
                  return ParentChildCard(
                    child: child,
                    isSelected: selectedChild?.student.id == child.student.id,
                    onTap: () {
                      ref.read(selectedChildProvider.notifier).state = child;
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLoading() {
    return Container(
      height: 100.h,
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildError(String error) {
    return Container(
      height: 100.h,
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Center(
        child: Text(
          'Error: $error',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.error,
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Container(
      height: 100.h,
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Center(
        child: Text(
          'No children found',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondaryLight,
          ),
        ),
      ),
    );
  }
}
