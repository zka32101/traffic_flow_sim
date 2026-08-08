import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// アプリ設定（テーマ・ハプティクス）のローカル永続化。
class LocalSettingsStore {
  static const _themeModeKey = 'traffic_flow_sim.settings.themeMode';
  static const _hapticsKey = 'traffic_flow_sim.settings.hapticsEnabled';

  Future<ThemeMode> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_themeModeKey);
    return switch (raw) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, mode.name);
  }

  Future<bool> loadHapticsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hapticsKey) ?? true;
  }

  Future<void> saveHapticsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hapticsKey, enabled);
  }
}
