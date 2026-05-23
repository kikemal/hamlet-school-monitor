import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color primary = Color(0xFF4A90E2);      // Bright Premium Blue
  static const Color secondary = Color(0xFFFFB300);    // Warm Amber / Cheerful Yellow
  static const Color accent = Color(0xFF4CAF50);       // Fresh Green
  static const Color error = Color(0xFFE57373);        // Soft Crimson Red
  static const Color success = Color(0xFF81C784);      // Mint Green

  // Light Theme Neutrals
  static const Color bgLight = Color(0xFFF8FAFC);      // Slate Light Gray
  static const Color surfaceLight = Color(0xFFFFFFFF); // Pure White
  static const Color textPrimaryLight = Color(0xFF1E293B); // Deep Slate
  static const Color textSecondaryLight = Color(0xFF64748B); // Cool Gray
  static const Color borderLight = Color(0xFFE2E8F0);  // Border Gray

  // Dark Theme Neutrals
  static const Color bgDark = Color(0xFF0F172A);       // Rich Obsidian Blue
  static const Color surfaceDark = Color(0xFF1E293B);  // Slate Dark
  static const Color textPrimaryDark = Color(0xFFF1F5F9);  // Ice White
  static const Color textSecondaryDark = Color(0xFF94A3B8); // Dim Slate
  static const Color borderDark = Color(0xFF334155);   // Border Slate

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFFF8FAFC), Color(0xFFE2E8F0)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
