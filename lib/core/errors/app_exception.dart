class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  AppException(this.message, {this.code, this.details});

  @override
  String toString() {
    return 'AppException: $message (code: $code)';
  }
}

class AuthException extends AppException {
  AuthException(String message, {String? code}) : super(message, code: code);
}

class NetworkException extends AppException {
  NetworkException(String message, {String? code}) : super(message, code: code);
}
