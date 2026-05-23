import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../providers/parent_providers.dart';
import '../widgets/parent_child_selector.dart';
import '../widgets/parent_error_view.dart';
import '../widgets/parent_loading_view.dart';
import '../widgets/parent_page_header.dart';
import '../widgets/parent_stat_card.dart';

class ParentDashboardScreen extends ConsumerWidget {
  const ParentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(parentDashboardStatsProvider);
    final selectedChild = ref.watch(selectedChildProvider);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: ParentPageHeader(
            title: 'Dashboard',
            subtitle: selectedChild != null
                ? 'Viewing ${selectedChild.fullName}\'s progress'
                : 'Select a child to view',
          ),
        ),
        const SliverToBoxAdapter(child: ParentChildSelector()),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: statsAsync.when(
              loading: () => const ParentLoadingView(),
              error: (e, _) => ParentErrorView(
                message: e.toString(),
                onRetry: () => ref.invalidate(parentDashboardStatsProvider),
              ),
              data: (stats) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Overview',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    SizedBox(height: 16.h),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: MediaQuery.sizeOf(context).width > 700 ? 4 : 2,
                      mainAxisSpacing: 12.h,
                      crossAxisSpacing: 12.w,
                      childAspectRatio: 1.3,
                      children: [
                        ParentStatCard(
                          label: 'Total Fees',
                          value: '\$${stats.totalFees.toStringAsFixed(0)}',
                          icon: Icons.account_balance_wallet,
                          color: Colors.blue,
                          onTap: () => context.push('/parent/fees'),
                        ),
                        ParentStatCard(
                          label: 'Paid',
                          value: '\$${stats.paidFees.toStringAsFixed(0)}',
                          icon: Icons.check_circle,
                          color: AppColors.success,
                          onTap: () => context.push('/parent/fees'),
                        ),
                        ParentStatCard(
                          label: 'Pending',
                          value: '\$${stats.pendingFees.toStringAsFixed(0)}',
                          icon: Icons.pending,
                          color: Colors.orange,
                          onTap: () => context.push('/parent/fees'),
                        ),
                        ParentStatCard(
                          label: 'Overdue',
                          value: '\$${stats.overdueFees.toStringAsFixed(0)}',
                          icon: Icons.warning,
                          color: AppColors.error,
                          onTap: () => context.push('/parent/fees'),
                        ),
                        ParentStatCard(
                          label: 'Upcoming Events',
                          value: '${stats.upcomingEvents}',
                          icon: Icons.event,
                          color: Colors.purple,
                          onTap: () => context.push('/parent/calendar'),
                        ),
                        ParentStatCard(
                          label: 'Announcements',
                          value: '${stats.unreadAnnouncements}',
                          icon: Icons.announcement,
                          color: Colors.indigo,
                          onTap: () => context.push('/parent/announcements'),
                        ),
                        ParentStatCard(
                          label: 'Pending Homework',
                          value: '${stats.pendingHomework}',
                          icon: Icons.assignment,
                          color: Colors.teal,
                          onTap: () => context.push('/parent/homework'),
                        ),
                        ParentStatCard(
                          label: 'View Profile',
                          value: 'Details',
                          icon: Icons.person,
                          color: AppColors.primary,
                          onTap: () => context.push('/parent/profile'),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
