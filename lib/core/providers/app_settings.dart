import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Theme mode (the app is locked to dark for now, but the notifier is kept for
/// the persisted value loaded in main()).
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier(super.initial);

  static const _key = 'theme_mode';

  static ThemeMode decode(String? saved) => switch (saved) {
        'light' => ThemeMode.light,
        'system' => ThemeMode.system,
        _ => ThemeMode.dark,
      };

  Future<void> set(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, mode.name);
  }
}

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(ThemeMode.dark),
);

/// The current UI language. Defaults to Arabic; each signed-in user's saved
/// preference is applied on login (see applySessionState). The local value is
/// also persisted so the app opens in the last language before login.
class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier(super.initial);

  static const _key = 'app_locale';
  static const fallback = Locale('ar'); // Arabic by default (Algeria)

  /// Languages offered in the picker, in order.
  static const supported = [Locale('ar'), Locale('fr')];

  static Locale decode(String? code) =>
      (code == null || code.isEmpty) ? fallback : Locale(code);

  Future<void> set(Locale locale) async {
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, locale.languageCode);
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>(
  (ref) => LocaleNotifier(LocaleNotifier.fallback),
);
