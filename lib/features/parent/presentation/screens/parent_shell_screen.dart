import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ParentShellScreen extends ConsumerWidget {
  const ParentShellScreen({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _items = [
    (icon: Icons.dashboard_outlined, label: 'Dashboard', route: '/parent/dashboard'),
    (icon: Icons.person_outline, label: 'Profile', route: '/parent/profile'),
    (icon: Icons.calendar_today_outlined, label: 'Calendar', route: '/parent/calendar'),
    (icon: Icons.announcement_outlined, label: 'Announcements', route: '/parent/announcements'),
    (icon: Icons.fact_check_outlined, label: 'Attendance', route: '/parent/attendance'),
    (icon: Icons.grade_outlined, label: 'Results', route: '/parent/results'),
    (icon: Icons.assignment_outlined, label: 'Homework', route: '/parent/homework'),
    (icon: Icons.psychology_outlined, label: 'Behaviour', route: '/parent/behaviour'),
    (icon: Icons.account_balance_wallet_outlined, label: 'Fees', route: '/parent/fees'),
    (icon: Icons.chat_outlined, label: 'Messages', route: '/parent/messages'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(authProvider).profile;
    final useRail = MediaQuery.sizeOf(context).width >= 900;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Parent Portal'),
        actions: [
          if (profile != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Center(
                child: Text('${profile.firstName} ${profile.lastName}'),
              ),
            ),
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go(AppConstants.routeLogin);
            },
          ),
        ],
      ),
      drawer: useRail
          ? null
          : Drawer(child: _NavList(navigationShell: navigationShell, extended: true)),
      body: Row(
        children: [
          if (useRail)
            NavigationRail(
              extended: MediaQuery.sizeOf(context).width >= 1100,
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: navigationShell.goBranch,
              destinations: _items
                  .map(
                    (d) => NavigationRailDestination(
                      icon: Icon(d.icon),
                      label: Text(d.label),
                    ),
                  )
                  .toList(),
            ),
          if (useRail) const VerticalDivider(width: 1),
          Expanded(child: navigationShell),
        ],
      ),
    );
  }
}

class _NavList extends StatelessWidget {
  const _NavList({required this.navigationShell, required this.extended});

  final StatefulNavigationShell navigationShell;
  final bool extended;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        DrawerHeader(
          decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Text(
              'Hamlet Parent',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
            ),
          ),
        ),
        for (var i = 0; i < ParentShellScreen._items.length; i++)
          ListTile(
            leading: Icon(ParentShellScreen._items[i].icon),
            title: Text(ParentShellScreen._items[i].label),
            selected: navigationShell.currentIndex == i,
            onTap: () {
              Navigator.pop(context);
              navigationShell.goBranch(i);
            },
          ),
      ],
    );
  }
}
