import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app_colors.dart';

class AppTypography {
  // Title / Heading styles
  static TextStyle get h1 => GoogleFonts.nunito(
        fontSize: 32.sp,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
      );

  static TextStyle get h2 => GoogleFonts.nunito(
        fontSize: 24.sp,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.3,
      );

  static TextStyle get h3 => GoogleFonts.nunito(
        fontSize: 20.sp,
        fontWeight: FontWeight.bold,
      );

  // Body styles
  static TextStyle get bodyLarge => GoogleFonts.nunito(
        fontSize: 16.sp,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get bodyMedium => GoogleFonts.nunito(
        fontSize: 14.sp,
        fontWeight: FontWeight.normal,
      );

  static TextStyle get bodySmall => GoogleFonts.nunito(
        fontSize: 12.sp,
        fontWeight: FontWeight.normal,
      );

  // Button styles
  static TextStyle get buttonText => GoogleFonts.nunito(
        fontSize: 16.sp,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      );

  // Overlines / Captions
  static TextStyle get caption => GoogleFonts.nunito(
        fontSize: 11.sp,
        fontWeight: FontWeight.normal,
        letterSpacing: 0.2,
      );
}
