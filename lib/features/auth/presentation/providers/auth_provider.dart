import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

import '../../data/repositories/auth_repository.dart';
import '../../../shared/domain/entities/profile.dart';
import 'auth_state.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

class AuthNotifier extends Notifier<AuthState> {
  StreamSubscription<supa.AuthState>? _authSubscription;

  AuthRepository get _repository => ref.read(authRepositoryProvider);

  @override
  AuthState build() {
    ref.onDispose(() => _authSubscription?.cancel());
    _authSubscription = _repository.authStateChanges.listen(_onAuthStateChange);
    Future.microtask(_restoreSession);
    return const AuthState();
  }

  Future<void> _restoreSession() async {
    if (state.status != AuthStatus.initial) return;

    state = state.copyWith(status: AuthStatus.loading, clearError: true);

    try {
      if (_repository.hasExpiredSession) {
        await _handleSessionExpired();
        return;
      }

      if (!_repository.hasValidSession) {
        state = const AuthState(status: AuthStatus.unauthenticated);
        return;
      }

      final profile = await _repository.getCurrentProfile();
      if (profile == null) {
        await _repository.handleExpiredSession();
        state = const AuthState(status: AuthStatus.sessionExpired);
        return;
      }

      state = AuthState(status: AuthStatus.authenticated, profile: profile);
    } catch (_) {
      await _repository.handleExpiredSession();
      state = const AuthState(status: AuthStatus.sessionExpired);
    }
  }

  Future<void> _onAuthStateChange(supa.AuthState authEvent) async {
    final event = authEvent.event;

    switch (event) {
      case supa.AuthChangeEvent.initialSession:
      case supa.AuthChangeEvent.signedIn:
      case supa.AuthChangeEvent.tokenRefreshed:
      case supa.AuthChangeEvent.userUpdated:
        await _loadProfile();
      case supa.AuthChangeEvent.signedOut:
        state = const AuthState(status: AuthStatus.unauthenticated);
      default:
        break;
    }
  }

  Future<void> _loadProfile() async {
    if (!_repository.hasValidSession) {
      state = const AuthState(status: AuthStatus.unauthenticated);
      return;
    }

    try {
      final profile = await _repository.getCurrentProfile();
      if (profile == null) {
        await _handleSessionExpired();
        return;
      }
      state = AuthState(status: AuthStatus.authenticated, profile: profile);
    } catch (e) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> _handleSessionExpired() async {
    await _repository.handleExpiredSession();
    state = const AuthState(status: AuthStatus.sessionExpired);
  }

  Future<Profile?> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);

    try {
      final profile = await _repository.signIn(email, password);
      state = AuthState(status: AuthStatus.authenticated, profile: profile);
      return profile;
    } catch (e) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      rethrow;
    }
  }

  Future<Profile?> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String role,
    String? phone,
    String? schoolId,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);

    try {
      final profile = await _repository.signUp(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        role: role,
        phone: phone,
        schoolId: schoolId,
      );
      state = AuthState(status: AuthStatus.authenticated, profile: profile);
      return profile;
    } catch (e) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      rethrow;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);

    try {
      await _repository.signOut();
      state = const AuthState(status: AuthStatus.unauthenticated);
    } catch (e) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      rethrow;
    }
  }

  Future<void> resetPassword(String email) async {
    await _repository.resetPassword(email);
  }

  Future<void> refreshSession() async {
    try {
      await _repository.refreshSession();
      await _loadProfile();
    } catch (_) {
      await _handleSessionExpired();
    }
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
