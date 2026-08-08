import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/local_settings_store.dart';

final localSettingsStoreProvider = Provider<LocalSettingsStore>((ref) => LocalSettingsStore());

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final LocalSettingsStore _store;

  ThemeModeNotifier(this._store) : super(ThemeMode.system) {
    _load();
  }

  Future<void> _load() async {
    state = await _store.loadThemeMode();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await _store.saveThemeMode(mode);
  }
}

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier(ref.watch(localSettingsStoreProvider));
});

class HapticsNotifier extends StateNotifier<bool> {
  final LocalSettingsStore _store;

  HapticsNotifier(this._store) : super(true) {
    _load();
  }

  Future<void> _load() async {
    state = await _store.loadHapticsEnabled();
  }

  Future<void> setEnabled(bool enabled) async {
    state = enabled;
    await _store.saveHapticsEnabled(enabled);
  }
}

final hapticsEnabledProvider = StateNotifierProvider<HapticsNotifier, bool>((ref) {
  return HapticsNotifier(ref.watch(localSettingsStoreProvider));
});
