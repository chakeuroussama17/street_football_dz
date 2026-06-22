import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Shared text styles. Space Grotesk for punchy display/headlines (Gen-Z),
/// Inter for body. Arabic falls back to the platform Arabic font automatically.
class AppTextStyles {
  AppTextStyles._();

  static TextStyle display(Color color) => GoogleFonts.spaceGrotesk(
        fontSize: 34,
        fontWeight: FontWeight.w800,
        height: 1.05,
        color: color,
      );

  static TextStyle headline(Color color) => GoogleFonts.spaceGrotesk(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: color,
      );

  static TextStyle title(Color color) => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: color,
      );

  static TextStyle body(Color color) => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: color,
      );

  static TextStyle label(Color color) => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
        color: color,
      );
}
