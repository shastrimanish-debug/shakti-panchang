import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings extends ChangeNotifier {
  AppSettings._();
  static final instance = AppSettings._();

  static const _localeKey = 'app_locale';
  static const _themeKey = 'app_theme_mode';

  Locale _locale = const Locale('hi', 'IN');
  ThemeMode _themeMode = ThemeMode.light;

  Locale get locale => _locale;
  ThemeMode get themeMode => _themeMode;

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    final code = p.getString(_localeKey);
    if (code == 'en') _locale = const Locale('en', 'US');
    if (code == 'gu') _locale = const Locale('gu', 'IN');
    final theme = p.getString(_themeKey);
    if (theme == 'dark') _themeMode = ThemeMode.dark;
    if (theme == 'light') _themeMode = ThemeMode.light;
    if (theme == 'system') _themeMode = ThemeMode.system;
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    final p = await SharedPreferences.getInstance();
    await p.setString(_localeKey, locale.languageCode);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final p = await SharedPreferences.getInstance();
    await p.setString(_themeKey, switch (mode) {
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
      ThemeMode.light => 'light',
    });
    notifyListeners();
  }
}
