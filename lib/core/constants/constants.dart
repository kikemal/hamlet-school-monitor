class AppConstants {
  // App Info
  static const String appName = 'Hamlet School Monitor';
  
  // Supabase Constants
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
  static const String supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');

  // Roles
  static const String roleAdmin = 'admin';
  static const String roleTeacher = 'teacher';
  static const String roleParent = 'parent';
  static const String roleStudent = 'student';

  // Routes
  static const String routeLogin = '/login';
  static const String routeRegister = '/register';
  static const String routeForgotPassword = '/forgot-password';
  static const String routeAdmin = '/admin';
  static const String routeAdminDashboard = '/admin/dashboard';
  static const String routeAdminStudents = '/admin/students';
  static const String routeAdminTeachers = '/admin/teachers';
  static const String routeAdminParents = '/admin/parents';
  static const String routeAdminClasses = '/admin/classes';
  static const String routeAdminFees = '/admin/fees';
  static const String routeAdminEvents = '/admin/events';
  static const String routeAdminDocuments = '/admin/documents';
  static const String routeAdminAnalytics = '/admin/analytics';
  static const String routeAdminExports = '/admin/exports';
  static const String routeTeacher = '/teacher';
  static const String routeTeacherDashboard = '/teacher/dashboard';
  static const String routeTeacherClasses = '/teacher/classes';
  static const String routeTeacherTimetable = '/teacher/timetable';
  static const String routeTeacherAttendance = '/teacher/attendance';
  static const String routeTeacherResults = '/teacher/results';
  static const String routeTeacherHomework = '/teacher/homework';
  static const String routeTeacherBehaviour = '/teacher/behaviour';
  static const String routeTeacherAnnouncements = '/teacher/announcements';
  static const String routeTeacherAnalytics = '/teacher/analytics';
  static const String routeTeacherAttendanceAnalytics = '/teacher/attendance-analytics';
  static const String routeParent = '/parent';
  static const String routeParentDashboard = '/parent/dashboard';
  static const String routeParentProfile = '/parent/profile';
  static const String routeParentCalendar = '/parent/calendar';
  static const String routeParentAnnouncements = '/parent/announcements';
  static const String routeParentAttendance = '/parent/attendance';
  static const String routeParentResults = '/parent/results';
  static const String routeParentHomework = '/parent/homework';
  static const String routeParentBehaviour = '/parent/behaviour';
  static const String routeParentFees = '/parent/fees';
  static const String routeParentMessages = '/parent/messages';
  static const String routeStudent = '/student';
  static const String routeStudentDashboard = '/student';
  static const String routeStudentProfile = '/student/profile';
  static const String routeStudentTimetable = '/student/timetable';
  static const String routeStudentCalendar = '/student/calendar';
  static const String routeStudentAnnouncements = '/student/announcements';
  static const String routeStudentAttendance = '/student/attendance';
  static const String routeStudentResults = '/student/results';
  static const String routeStudentHomework = '/student/homework';

  // Shared Preferences Keys
  static const String keyToken = 'auth_token';
  static const String keyRole = 'user_role';
}
