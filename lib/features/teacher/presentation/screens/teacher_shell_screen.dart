import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class TeacherShellScreen extends ConsumerWidget {
  const TeacherShellScreen({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _items = [
    (icon: Icons.home_outlined, label: 'Home'),
    (icon: Icons.class_outlined, label: 'Classes'),
    (icon: Icons.calendar_view_week_outlined, label: 'Timetable'),
    (icon: Icons.fact_check_outlined, label: 'Attendance'),
    (icon: Icons.grade_outlined, label: 'Results'),
    (icon: Icons.assignment_outlined, label: 'Homework'),
    (icon: Icons.psychology_outlined, label: 'Behaviour'),
    (icon: Icons.campaign_outlined, label: 'Announce'),
    (icon: Icons.insights_outlined, label: 'Analytics'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(authProvider).profile;
    final useRail = MediaQuery.sizeOf(context).width >= 900;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Dashboard'),
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
          : Drawer(child: _NavList(navigationShell: navigationShell)),
      body: Row(
        children: [
          if (useRail)
            NavigationRail(
              extended: MediaQuery.sizeOf(context).width >= 1200,
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
  const _NavList({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

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
              'Hamlet Teacher',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                  ),
            ),
          ),
        ),
        for (var i = 0; i < TeacherShellScreen._items.length; i++)
          ListTile(
            leading: Icon(TeacherShellScreen._items[i].icon),
            title: Text(TeacherShellScreen._items[i].label),
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
