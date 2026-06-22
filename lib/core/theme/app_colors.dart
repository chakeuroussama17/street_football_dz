import 'package:flutter/material.dart';

/// Algerian Gen-Z palette: vivid flag green → red, a gold accent for energy,
/// over a near-black green-tinted dark surface (the default theme).
class AppColors {
  AppColors._();

  // ── Brand (Algeria flag, brightened) ────────────────────────────────────────
  static const Color green = Color(0xFF00C75A); // vivid Algerian green
  static const Color red   = Color(0xFFFF2E54); // vivid red (flag crescent)
  static const Color gold  = Color(0xFFFFC93C); // desert/energy accent

  static const LinearGradient brandGradient = LinearGradient(
    colors: [green, red],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient brandGradientHot = LinearGradient(
    colors: [green, gold, red],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Dark Mode (default) ─────────────────────────────────────────────────────
  static const Color darkBg            = Color(0xFF0A0E0C);
  static const Color darkSurface       = Color(0xFF11160F);
  static const Color darkCard          = Color(0x0AFFFFFF); // white 0.04
  static const Color darkBorder        = Color(0x14FFFFFF); // white 0.08
  static const Color darkTextPrimary   = Color(0xFFF1F5F1);
  static const Color darkTextSecondary = Color(0xFF8C968D);
  static const Color darkTextMuted     = Color(0xFF49514A);

  // ── Light Mode ──────────────────────────────────────────────────────────────
  static const Color lightBg            = Color(0xFFF6F8F6);
  static const Color lightSurface       = Color(0xFFFFFFFF);
  static const Color lightCard          = Color(0xFFFFFFFF);
  static const Color lightBorder        = Color(0xFFE9ECE9);
  static const Color lightTextPrimary   = Color(0xFF101510);
  static const Color lightTextSecondary = Color(0xFF6B746C);
  static const Color lightTextMuted     = Color(0xFFB7BEB8);

  // ── Semantic ────────────────────────────────────────────────────────────────
  static const Color win  = Color(0xFF00C75A);
  static const Color draw = Color(0xFFFFC93C);
  static const Color loss = Color(0xFFFF2E54);
  static const Color info = Color(0xFF22D3EE);
}
