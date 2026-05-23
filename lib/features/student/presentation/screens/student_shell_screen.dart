import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/student_providers.dart';

class StudentShellScreen extends ConsumerWidget {
  const StudentShellScreen({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      // A common pattern when using bottom navigation bars is to support
      // navigating to the initial location when tapping the item that is
      // already active. This example demonstrates how to support this.
      initialLocation: navigationShell.currentIndex == index,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentAsync = ref.watch(studentProfileProvider);
    final selectedStudent = ref.watch(selectedStudentProvider);

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: studentAsync.when(
        loading: () => const SizedBox(),
        error: (e, _) => const SizedBox(),
        data: (student) => NavigationBar(
          onDestinationSelected: _goBranch,
          selectedIndex: navigationShell.currentIndex,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              label: 'Dashboard',
              selectedIcon: Icon(Icons.dashboard),
            ),
            NavigationDestination(
              icon: Icon(Icons.schedule_outlined),
              label: 'Timetable',
              selectedIcon: Icon(Icons.schedule),
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_today_outlined),
              label: 'Calendar',
              selectedIcon: Icon(Icons.calendar_today),
            ),
            NavigationDestination(
              icon: Icon(Icons.announcement_outlined),
              label: 'Announcements',
              selectedIcon: Icon(Icons.announcement),
            ),
            NavigationDestination(
              icon: Icon(Icons.assignment_outlined),
              label: 'Homework',
              selectedIcon: Icon(Icons.assignment),
            ),
            NavigationDestination(
              icon: Icon(Icons.assessment_outlined),
              label: 'Results',
              selectedIcon: Icon(Icons.assessment),
            ),
            NavigationDestination(
              icon: Icon(Icons.attendance_outlined),
              label: 'Attendance',
              selectedIcon: Icon(Icons.attendance),
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outlined),
              label: 'Profile',
              selectedIcon: Icon(Icons.person),
            ),
          ],
        ),
      ),
    );
  }
}