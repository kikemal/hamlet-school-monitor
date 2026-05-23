import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../shared/base_repository.dart';
import '../../../shared/domain/entities/profile.dart';
import '../services/auth_service.dart';

class AuthRepository extends BaseRepository {
  AuthRepository({AuthService? authService})
      : _authService = authService ?? AuthService();

  final AuthService _authService;

  Stream<AuthState> get authStateChanges => _authService.authStateChanges;

  Session? get currentSession => _authService.currentSession;

  bool get hasValidSession => _authService.hasValidSession;

  bool get hasExpiredSession => _authService.hasExpiredSession;

  Future<Profile?> getCurrentProfile() async {
    if (!_authService.hasValidSession) return null;

    final user = _authService.currentUser;
    if (user == null) return null;

    return _authService.getUserProfile(user.id);
  }

  Future<Profile> signIn(String email, String password) =>
      _authService.signIn(email, password);

  Future<Profile> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String role,
    String? phone,
    String? schoolId,
  }) =>
      _authService.signUp(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        role: role,
        phone: phone,
        schoolId: schoolId,
      );

  Future<void> signOut() => _authService.signOut();

  Future<void> resetPassword(String email) =>
      _authService.resetPassword(email);

  Future<void> refreshSession() => _authService.refreshSession();

  Future<void> handleExpiredSession() async {
    await _authService.signOut();
  }
}
