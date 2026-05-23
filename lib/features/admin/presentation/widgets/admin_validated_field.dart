import 'package:flutter/material.dart';

class AdminValidatedField extends StatelessWidget {
  const AdminValidatedField({
    super.key,
    required this.controller,
    required this.label,
    this.validator,
    this.maxLines = 1,
  });

  factory AdminValidatedField.required(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
  }) {
    return AdminValidatedField(
      controller: controller,
      label: label,
      maxLines: maxLines,
      validator: (v) {
        if (v == null || v.trim().isEmpty) {
          return '$label is required';
        }
        return null;
      },
    );
  }

  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
