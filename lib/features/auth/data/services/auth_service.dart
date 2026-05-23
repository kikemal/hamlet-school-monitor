import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/base_service.dart';
import '../../../shared/domain/entities/profile.dart';

class AuthService extends BaseService {
  Stream<AuthState> get authStateChanges =>
      supabaseClient.auth.onAuthStateChange;

  Session? get currentSession {
    final session = supabaseClient.auth.currentSession;
    if (session != null && session.isExpired) return null;
    return session;
  }

  User? get currentUser => supabaseClient.auth.currentUser;

  bool get hasValidSession => currentSession != null && currentUser != null;

  bool get hasExpiredSession {
    final session = supabaseClient.auth.currentSession;
    return session != null && session.isExpired;
  }

  /// Signs in and returns the user's profile.
  Future<Profile> signIn(String email, String password) async {
    try {
      final response = await supabaseClient.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      final user = response.user;
      if (user == null) {
        throw const AuthException('Sign-in failed. Please try again.');
      }

      return getUserProfile(user.id);
    } catch (e) {
      throw handleError(e);
    }
  }

  /// Registers a new parent or student account with profile + role record.
  Future<Profile> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String role,
    String? phone,
    String? schoolId,
  }) async {
    try {
      if (role != 'parent' && role != 'student') {
        throw Exception(
          'Self-registration is only available for parent and student accounts.',
        );
      }

      if (role == 'student' && (schoolId == null || schoolId.trim().isEmpty)) {
        throw Exception('School ID is required for student registration.');
      }

      final response = await supabaseClient.auth.signUp(
        email: email.trim(),
        password: password,
        data: {
          'first_name': firstName.trim(),
          'last_name': lastName.trim(),
          'role': role,
        },
      );

      final user = response.user;
      if (user == null) {
        throw const AuthException('Registration failed. Please try again.');
      }

      await _createProfile(
        userId: user.id,
        role: role,
        firstName: firstName.trim(),
        lastName: lastName.trim(),
        phone: phone?.trim(),
      );

      if (role == 'parent') {
        await supabaseClient.from('parents').insert({'id': user.id});
      } else {
        await supabaseClient.from('students').insert({
          'id': user.id,
          'school_id': schoolId!.trim(),
        });
      }

      if (response.session == null) {
        throw Exception(
          'Account created. Please confirm your email, then sign in.',
        );
      }

      return getUserProfile(user.id);
    } catch (e) {
      throw handleError(e);
    }
  }

  Future<void> _createProfile({
    required String userId,
    required String role,
    required String firstName,
    required String lastName,
    String? phone,
  }) async {
    await supabaseClient.from('profiles').insert({
      'id': userId,
      'role': role,
      'first_name': firstName,
      'last_name': lastName,
      if (phone != null && phone.isNotEmpty) 'phone': phone,
    });
  }

  Future<Profile> getUserProfile(String userId) async {
    try {
      final response = await supabaseClient
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      return Profile.fromJson(Map<String, dynamic>.from(response));
    } catch (e) {
      throw handleError(e);
    }
  }

  Future<void> signOut() async {
    try {
      await supabaseClient.auth.signOut();
    } catch (e) {
      throw handleError(e);
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await supabaseClient.auth.resetPasswordForEmail(email.trim());
    } catch (e) {
      throw handleError(e);
    }
  }

  Future<void> refreshSession() async {
    try {
      await supabaseClient.auth.refreshSession();
    } catch (e) {
      throw handleError(e);
    }
  }
}
