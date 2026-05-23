import '../../../shared/domain/entities/profile.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  sessionExpired,
}

class AuthState {
  const AuthState({
    this.status = AuthStatus.initial,
    this.profile,
    this.errorMessage,
  });

  final AuthStatus status;
  final Profile? profile;
  final String? errorMessage;

  bool get isAuthenticated =>
      status == AuthStatus.authenticated && profile != null;

  bool get isLoading => status == AuthStatus.loading;

  String? get role => profile?.role;

  AuthState copyWith({
    AuthStatus? status,
    Profile? profile,
    String? errorMessage,
    bool clearProfile = false,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      profile: clearProfile ? null : (profile ?? this.profile),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
