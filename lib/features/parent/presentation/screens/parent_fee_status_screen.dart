import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../providers/parent_providers.dart';
import '../widgets/parent_error_view.dart';
import '../widgets/parent_loading_view.dart';
import '../widgets/parent_page_header.dart';

class ParentFeeStatusScreen extends ConsumerWidget {
  const ParentFeeStatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feesAsync = ref.watch(childFeesProvider);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: ParentPageHeader(
            title: 'Fee Status',
            subtitle: 'Track payments and dues',
          ),
        ),
        feesAsync.when(
          loading: () => const SliverToBoxAdapter(child: ParentLoadingView()),
          error: (e, _) => SliverToBoxAdapter(
            child: ParentErrorView(
              message: e.toString(),
              onRetry: () => ref.invalidate(childFeesProvider),
            ),
          ),
          data: (fees) {
            if (fees.isEmpty) {
              return SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Center(
                    child: Text(
                      'No fees found',
                      style: AppTypography.bodyMedium,
                    ),
                  ),
                ),
              );
            }

            return SliverPadding(
              padding: EdgeInsets.all(20.w),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final feeWithPayments = fees[index];
                    return _buildFeeCard(context, feeWithPayments);
                  },
                  childCount: fees.length,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFeeCard(BuildContext context, feeWithPayments) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fee = feeWithPayments.fee;
    final status = feeWithPayments.status;

    Color statusColor;
    IconData statusIcon;

    switch (status) {
      case 'paid':
        statusColor = AppColors.success;
        statusIcon = Icons.check_circle;
        break;
      case 'overdue':
        statusColor = AppColors.error;
        statusIcon = Icons.warning;
        break;
      default:
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
    }

    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    fee.description,
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 16.w, color: statusColor),
                      SizedBox(width: 4.w),
                      Text(
                        status.toUpperCase(),
                        style: AppTypography.caption.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                _buildFeeDetail('Total Amount', '\$${fee.amount.toStringAsFixed(2)}'),
                SizedBox(width: 20.w),
                _buildFeeDetail('Paid', '\$${feeWithPayments.totalPaid.toStringAsFixed(2)}'),
                SizedBox(width: 20.w),
                _buildFeeDetail('Remaining', '\$${feeWithPayments.remaining.toStringAsFixed(2)}'),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16.w, color: AppColors.textSecondaryLight),
                SizedBox(width: 8.w),
                Text(
                  'Due: ${fee.dueDate.day}/${fee.dueDate.month}/${fee.dueDate.year}',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
            if (feeWithPayments.payments.isNotEmpty) ...[
              SizedBox(height: 12.h),
              const Divider(),
              SizedBox(height: 8.h),
              Text(
                'Payment History',
                style: AppTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8.h),
              ...feeWithPayments.payments.map((payment) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${payment.amount.toStringAsFixed(2)}',
                        style: AppTypography.bodySmall,
                      ),
                      Text(
                        payment.status,
                        style: AppTypography.bodySmall.copyWith(
                          color: payment.status == 'paid' ? AppColors.success : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFeeDetail(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: AppColors.textSecondaryLight,
          ),
        ),
        Text(
          value,
          style: AppTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
