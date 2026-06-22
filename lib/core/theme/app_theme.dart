import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.darkBg,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.green,
          secondary: AppColors.red,
          tertiary: AppColors.gold,
          surface: AppColors.darkSurface,
          onSurface: AppColors.darkTextPrimary,
          outline: AppColors.darkBorder,
        ),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.darkSurface,
          foregroundColor: AppColors.darkTextPrimary,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
        cardTheme: CardThemeData(
          color: AppColors.darkCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.darkBorder),
          ),
          elevation: 0,
        ),
        dividerColor: AppColors.darkBorder,
        inputDecorationTheme: _inputTheme(
          fill: AppColors.darkSurface,
          border: AppColors.darkBorder,
          hint: AppColors.darkTextMuted,
          label: AppColors.darkTextSecondary,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.darkSurface,
          selectedItemColor: AppColors.green,
          unselectedItemColor: AppColors.darkTextMuted,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
      );

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.lightBg,
        colorScheme: const ColorScheme.light(
          primary: AppColors.green,
          secondary: AppColors.red,
          tertiary: AppColors.gold,
          surface: AppColors.lightSurface,
          onSurface: AppColors.lightTextPrimary,
          outline: AppColors.lightBorder,
        ),
        textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.lightSurface,
          foregroundColor: AppColors.lightTextPrimary,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
        cardTheme: CardThemeData(
          color: AppColors.lightCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.lightBorder),
          ),
          elevation: 0,
        ),
        dividerColor: AppColors.lightBorder,
        inputDecorationTheme: _inputTheme(
          fill: AppColors.lightSurface,
          border: AppColors.lightBorder,
          hint: AppColors.lightTextMuted,
          label: AppColors.lightTextSecondary,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.lightSurface,
          selectedItemColor: AppColors.green,
          unselectedItemColor: AppColors.lightTextMuted,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
      );

  static InputDecorationTheme _inputTheme({
    required Color fill,
    required Color border,
    required Color hint,
    required Color label,
  }) =>
      InputDecorationTheme(
        filled: true,
        fillColor: fill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.green, width: 1.5),
        ),
        hintStyle: TextStyle(color: hint),
        labelStyle: TextStyle(color: label),
      );
}
