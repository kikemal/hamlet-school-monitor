import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/constants.dart';
import '../features/admin/presentation/screens/admin_analytics_screen.dart';
import '../features/admin/presentation/screens/admin_classes_screen.dart';
import '../features/admin/presentation/screens/admin_dashboard_screen.dart';
import '../features/admin/presentation/screens/admin_documents_screen.dart';
import '../features/admin/presentation/screens/admin_events_screen.dart';
import '../features/admin/presentation/screens/admin_exports_screen.dart';
import '../features/admin/presentation/screens/admin_fees_screen.dart';
import '../features/admin/presentation/screens/admin_parents_screen.dart';
import '../features/admin/presentation/screens/admin_shell_screen.dart';
import '../features/admin/presentation/screens/admin_students_screen.dart';
import '../features/admin/presentation/screens/admin_teachers_screen.dart';
import '../features/auth/presentation/guards/role_guard.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/teacher/presentation/screens/teacher_analytics_screen.dart';
import '../features/teacher/presentation/screens/teacher_announcements_screen.dart';
import '../features/teacher/presentation/screens/teacher_attendance_screen.dart';
import '../features/teacher/presentation/screens/teacher_behaviour_screen.dart';
import '../features/teacher/presentation/screens/teacher_classes_screen.dart';
import '../features/teacher/presentation/screens/teacher_dashboard_screen.dart';
import '../features/teacher/presentation/screens/teacher_homework_screen.dart';
import '../features/teacher/presentation/screens/teacher_results_screen.dart';
import '../features/teacher/presentation/screens/teacher_shell_screen.dart';
import '../features/teacher/presentation/screens/teacher_timetable_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _RouterRefreshNotifier(ref);
  ref.onDispose(refreshNotifier.dispose);

  return GoRouter(
    initialLocation: AppConstants.routeLogin,
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final authRepository = ref.read(authRepositoryProvider);

      if (state.matchedLocation == AppConstants.routeAdmin) {
        return AppConstants.routeAdminDashboard;
      }
      if (state.matchedLocation == AppConstants.routeTeacher) {
        return AppConstants.routeTeacherDashboard;
      }

      return RoleGuard.redirect(
        routerState: state,
        authState: authState,
        hasValidSession: authRepository.hasValidSession,
      );
    },
    routes: [
      GoRoute(
        path: AppConstants.routeLogin,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppConstants.routeRegister,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppConstants.routeForgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppConstants.routeParentDashboard,
        builder: (context, state) => const _RolePlaceholder(title: 'Parent Dashboard'),
      ),
      GoRoute(
        path: AppConstants.routeStudentDashboard,
        builder: (context, state) => const _RolePlaceholder(title: 'Student Dashboard'),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AdminShellScreen(navigationShell: navigationShell);
        },
        branches: [
          _adminBranch(AppConstants.routeAdminDashboard, const AdminDashboardScreen()),
          _adminBranch(AppConstants.routeAdminStudents, const AdminStudentsScreen()),
          _adminBranch(AppConstants.routeAdminTeachers, const AdminTeachersScreen()),
          _adminBranch(AppConstants.routeAdminParents, const AdminParentsScreen()),
          _adminBranch(AppConstants.routeAdminClasses, const AdminClassesScreen()),
          _adminBranch(AppConstants.routeAdminFees, const AdminFeesScreen()),
          _adminBranch(AppConstants.routeAdminEvents, const AdminEventsScreen()),
          _adminBranch(AppConstants.routeAdminDocuments, const AdminDocumentsScreen()),
          _adminBranch(AppConstants.routeAdminAnalytics, const AdminAnalyticsScreen()),
          _adminBranch(AppConstants.routeAdminExports, const AdminExportsScreen()),
        ],
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return TeacherShellScreen(navigationShell: navigationShell);
        },
        branches: [
          _teacherBranch(
            AppConstants.routeTeacherDashboard,
            const TeacherDashboardScreen(),
          ),
          _teacherBranch(
            AppConstants.routeTeacherClasses,
            const TeacherClassesScreen(),
          ),
          _teacherBranch(
            AppConstants.routeTeacherTimetable,
            const TeacherTimetableScreen(),
          ),
          _teacherBranch(
            AppConstants.routeTeacherAttendance,
            const TeacherAttendanceScreen(),
          ),
          _teacherBranch(
            AppConstants.routeTeacherResults,
            const TeacherResultsScreen(),
          ),
          _teacherBranch(
            AppConstants.routeTeacherHomework,
            const TeacherHomeworkScreen(),
          ),
          _teacherBranch(
            AppConstants.routeTeacherBehaviour,
            const TeacherBehaviourScreen(),
          ),
          _teacherBranch(
            AppConstants.routeTeacherAnnouncements,
            const TeacherAnnouncementsScreen(),
          ),
          _teacherBranch(
            AppConstants.routeTeacherAnalytics,
            const TeacherAnalyticsScreen(),
          ),
        ],
      ),
    ],
  );
});

StatefulShellBranch _adminBranch(String path, Widget child) {
  return StatefulShellBranch(
    routes: [
      GoRoute(
        path: path,
        pageBuilder: (context, state) => NoTransitionPage(child: child),
      ),
    ],
  );
}

StatefulShellBranch _teacherBranch(String path, Widget child) {
  return StatefulShellBranch(
    routes: [
      GoRoute(
        path: path,
        pageBuilder: (context, state) => NoTransitionPage(child: child),
      ),
    ],
  );
}

class _RouterRefreshNotifier extends ChangeNotifier {
  _RouterRefreshNotifier(this._ref) {
    _ref.listen(authProvider, (_, __) => notifyListeners());
  }

  final Ref _ref;
}

class _RolePlaceholder extends StatelessWidget {
  const _RolePlaceholder({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('$title — coming in a future step')),
    );
  }
}
