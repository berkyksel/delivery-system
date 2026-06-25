import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kThemeModeKey = 'theme_mode';

/// Başlangıçta SharedPreferences'tan okunan tema modu.
/// main.dart'ta app başlamadan önce yüklenir ve overrideWithValue ile geçirilir.
final initialThemeModeProvider = Provider<ThemeMode>((ref) => ThemeMode.dark);

class ThemeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    // Başlangıç değeri initialThemeModeProvider'dan gelir (main'de override edilir)
    return ref.read(initialThemeModeProvider);
  }

  Future<void> setDark() async {
    state = ThemeMode.dark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kThemeModeKey, 'dark');
  }

  Future<void> setLight() async {
    state = ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kThemeModeKey, 'light');
  }

  Future<void> toggle() async {
    if (state == ThemeMode.dark) {
      await setLight();
    } else {
      await setDark();
    }
  }

  bool get isDark => state == ThemeMode.dark;
}

final themeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(
  ThemeNotifier.new,
);

/// SharedPreferences'tan tema modunu önceden yükler.
Future<ThemeMode> loadSavedThemeMode() async {
  final prefs = await SharedPreferences.getInstance();
  final value = prefs.getString(_kThemeModeKey);
  if (value == 'light') return ThemeMode.light;
  return ThemeMode.dark;
}
