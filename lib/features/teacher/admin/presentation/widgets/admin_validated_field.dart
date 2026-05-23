import 'package:flutter/material.dart';

import '../../../../core/utils/app_validator.dart';

/// Reusable [TextFormField] wired to [AppValidator] for admin CRUD dialogs.
class AdminValidatedField extends StatelessWidget {
  const AdminValidatedField({
    super.key,
    required this.controller,
    required this.label,
    required this.validator,
    this.obscureText = false,
    this.keyboardType,
    this.maxLines = 1,
    this.autofillHints,
  });

  final TextEditingController controller;
  final String label;
  final String? Function(String?) validator;
  final bool obscureText;
  final TextInputType? keyboardType;
  final int maxLines;
  final Iterable<String>? autofillHints;

  factory AdminValidatedField.email(TextEditingController controller) {
    return AdminValidatedField(
      controller: controller,
      label: 'Email',
      keyboardType: TextInputType.emailAddress,
      autofillHints: const [AutofillHints.email],
      validator: AppValidator.validateEmail,
    );
  }

  factory AdminValidatedField.password(TextEditingController controller) {
    return AdminValidatedField(
      controller: controller,
      label: 'Password',
      obscureText: true,
      autofillHints: const [AutofillHints.newPassword],
      validator: AppValidator.validatePassword,
    );
  }

  factory AdminValidatedField.firstName(TextEditingController controller) {
    return AdminValidatedField(
      controller: controller,
      label: 'First name',
      autofillHints: const [AutofillHints.givenName],
      validator: AppValidator.validateName,
    );
  }

  factory AdminValidatedField.lastName(TextEditingController controller) {
    return AdminValidatedField(
      controller: controller,
      label: 'Last name',
      autofillHints: const [AutofillHints.familyName],
      validator: AppValidator.validateName,
    );
  }

  factory AdminValidatedField.required(
    TextEditingController controller,
    String label,
  ) {
    return AdminValidatedField(
      controller: controller,
      label: label,
      validator: (v) => AppValidator.validateRequired(v, label),
    );
  }

  factory AdminValidatedField.amount(TextEditingController controller) {
    return AdminValidatedField(
      controller: controller,
      label: 'Amount',
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: AppValidator.validateAmount,
    );
  }

  factory AdminValidatedField.phoneOptional(TextEditingController controller) {
    return AdminValidatedField(
      controller: controller,
      label: 'Phone (optional)',
      keyboardType: TextInputType.phone,
      autofillHints: const [AutofillHints.telephoneNumber],
      validator: AppValidator.validatePhoneOptional,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        maxLines: maxLines,
        autofillHints: autofillHints,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: validator,
      ),
    );
  }
}
