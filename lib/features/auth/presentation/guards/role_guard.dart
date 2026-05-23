import 'package:go_router/go_router.dart';

import '../../../../core/constants/constants.dart';
import '../providers/auth_state.dart';

/// Role-based route protection and redirects for [GoRouter].
class RoleGuard {
  RoleGuard._();

  static const _publicRoutes = {
    AppConstants.routeLogin,
    AppConstants.routeRegister,
    AppConstants.routeForgotPassword,
  };

  static bool isPublicRoute(String location) =>
      _publicRoutes.contains(location);

  static String dashboardRouteForRole(String role) {
    switch (role) {
      case AppConstants.roleAdmin:
        return AppConstants.routeAdminDashboard; // /admin/dashboard
      case AppConstants.roleTeacher:
        return AppConstants.routeTeacherDashboard;
      case AppConstants.roleParent:
        return AppConstants.routeParentDashboard;
      case AppConstants.roleStudent:
        return AppConstants.routeStudentDashboard;
      default:
        return AppConstants.routeLogin;
    }
  }

  static bool canAccessRoute(String role, String location) {
    if (location.startsWith(AppConstants.routeAdmin)) {
      return role == AppConstants.roleAdmin;
    }
    if (location.startsWith(AppConstants.routeTeacher)) {
      return role == AppConstants.roleTeacher;
    }
    switch (location) {
      case AppConstants.routeTeacherDashboard:
        return role == AppConstants.roleTeacher;
      case AppConstants.routeParentDashboard:
        return role == AppConstants.roleParent;
      case AppConstants.routeStudentDashboard:
        return role == AppConstants.roleStudent;
      default:
        return isPublicRoute(location);
    }
  }

  /// Central redirect logic: session, expiry, and role enforcement.
  static String? redirect({
    required GoRouterState routerState,
    required AuthState authState,
    required bool hasValidSession,
  }) {
    final location = routerState.matchedLocation;
    final isPublic = isPublicRoute(location);

    if (authState.status == AuthStatus.sessionExpired) {
      if (location != AppConstants.routeLogin) {
        return AppConstants.routeLogin;
      }
      return null;
    }

    if (authState.status == AuthStatus.loading ||
        authState.status == AuthStatus.initial) {
      return null;
    }

    if (!hasValidSession || !authState.isAuthenticated) {
      return isPublic ? null : AppConstants.routeLogin;
    }

    final role = authState.role;
    if (role == null) {
      return AppConstants.routeLogin;
    }

    if (location == AppConstants.routeLogin ||
        location == AppConstants.routeRegister) {
      return dashboardRouteForRole(role);
    }

    if (!canAccessRoute(role, location)) {
      return dashboardRouteForRole(role);
    }

    return null;
  }
}
