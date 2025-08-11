import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _kLocaleKey = 'app_locale_code';
const String _kThemeKey = 'app_theme_mode';

final localeProvider = StateNotifierProvider<LocaleController, Locale>(
  (ref) => LocaleController()..load(),
);

final themeModeProvider = StateNotifierProvider<ThemeModeController, ThemeMode>(
  (ref) => ThemeModeController()..load(),
);

class LocaleController extends StateNotifier<Locale> {
  LocaleController() : super(const Locale('en'));

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_kLocaleKey);
    state = code == null ? const Locale('en') : Locale(code);
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLocaleKey, locale.languageCode);
  }
}

class ThemeModeController extends StateNotifier<ThemeMode> {
  ThemeModeController() : super(ThemeMode.system);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final mode = prefs.getString(_kThemeKey);
    if (mode == 'dark') {
      state = ThemeMode.dark;
    } else if (mode == 'light') {
      state = ThemeMode.light;
    }
  }

  Future<void> toggle() async {
    state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kThemeKey,
      state == ThemeMode.dark ? 'dark' : 'light',
    );
  }
}
