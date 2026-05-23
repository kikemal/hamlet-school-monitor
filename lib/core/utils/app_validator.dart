class AppValidator {
  // Email Validation
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
    );
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  // Password Validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }

  // Required Field Validation
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  // Name Validation
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters long';
    }
    return null;
  }

  /// Positive monetary amount (fees, payments).
  static String? validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Amount is required';
    }
    final amount = double.tryParse(value.trim());
    if (amount == null || amount <= 0) {
      return 'Enter a valid positive amount';
    }
    return null;
  }

  /// Optional phone — validates format only when non-empty.
  static String? validatePhoneOptional(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 7) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  /// Exam / homework marks (0 through [maxMarks] when set).
  static String? validateMarks(String? value, {double? maxMarks}) {
    if (value == null || value.trim().isEmpty) {
      return 'Marks are required';
    }
    final marks = double.tryParse(value.trim());
    if (marks == null || marks < 0) {
      return 'Enter valid marks (0 or greater)';
    }
    if (maxMarks != null && marks > maxMarks) {
      return 'Marks cannot exceed $maxMarks';
    }
    return null;
  }

  /// Optional text with max length when provided.
  static String? validateOptionalMaxLength(
    String? value,
    int maxLength, {
    String fieldName = 'Field',
  }) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    if (value.trim().length > maxLength) {
      return '$fieldName must be at most $maxLength characters';
    }
    return null;
  }
}
