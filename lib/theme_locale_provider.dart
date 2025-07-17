import 'package:flutter/material.dart';
import 'l10n/l10n.dart';

class ThemeLocaleProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  Locale _locale = L10n.all.first;

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void toggleLocale() {
    _locale = _locale.languageCode == 'en' ? const Locale('bn') : const Locale('en');
    notifyListeners();
  }

  void setLocale(Locale locale) {
    if (!L10n.all.contains(locale)) return;
    _locale = locale;
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }
} 