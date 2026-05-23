import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class AdminShellScreen extends ConsumerWidget {
  const AdminShellScreen({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _items = [
    (icon: Icons.dashboard_outlined, label: 'Overview', route: AppConstants.routeAdminDashboard),
    (icon: Icons.school_outlined, label: 'Students', route: AppConstants.routeAdminStudents),
    (icon: Icons.person_outline, label: 'Teachers', route: AppConstants.routeAdminTeachers),
    (icon: Icons.family_restroom_outlined, label: 'Parents', route: AppConstants.routeAdminParents),
    (icon: Icons.class_outlined, label: 'Classes', route: AppConstants.routeAdminClasses),
    (icon: Icons.payments_outlined, label: 'Fees', route: AppConstants.routeAdminFees),
    (icon: Icons.event_outlined, label: 'Calendar', route: AppConstants.routeAdminEvents),
    (icon: Icons.folder_outlined, label: 'Documents', route: AppConstants.routeAdminDocuments),
    (icon: Icons.insights_outlined, label: 'Analytics', route: AppConstants.routeAdminAnalytics),
    (icon: Icons.shield_outlined, label: 'Behaviour', route: AppConstants.routeAdminBehaviour),
    (icon: Icons.download_outlined, label: 'Export', route: AppConstants.routeAdminExports),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(authProvider).profile;
    final useRail = MediaQuery.sizeOf(context).width >= 900;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
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
              'Hamlet Admin',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
            ),
          ),
        ),
        for (var i = 0; i < AdminShellScreen._items.length; i++)
          ListTile(
            leading: Icon(AdminShellScreen._items[i].icon),
            title: Text(AdminShellScreen._items[i].label),
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
