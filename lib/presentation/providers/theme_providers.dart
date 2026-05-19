import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _isDarkKey = 'is_dark';
const String _backgroundImageKey = 'background_image';

class _ThemeModeNotifier extends StateNotifier<ThemeMode> {
  _ThemeModeNotifier() : super(ThemeMode.dark) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_isDarkKey);
    if (isDark == null) {
      await prefs.setBool(_isDarkKey, true);
      state = ThemeMode.dark;
    } else {
      state = isDark ? ThemeMode.dark : ThemeMode.light;
    }
  }

  Future<void> set(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isDarkKey, mode == ThemeMode.dark);
  }

  Future<void> toggle(bool isDark) =>
      set(isDark ? ThemeMode.dark : ThemeMode.light);
}

final themeModeProvider = StateNotifierProvider<_ThemeModeNotifier, ThemeMode>(
  (ref) => _ThemeModeNotifier(),
);

class _BackgroundImageNotifier extends StateNotifier<bool> {
  _BackgroundImageNotifier() : super(true) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getBool(_backgroundImageKey);
    if (value == null) {
      await prefs.setBool(_backgroundImageKey, true);
      state = true;
    } else {
      state = value;
    }
  }

  Future<void> set(bool value) async {
    state = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_backgroundImageKey, value);
  }
}

final backgroundImageProvider =
    StateNotifierProvider<_BackgroundImageNotifier, bool>(
      (ref) => _BackgroundImageNotifier(),
    );
