import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/settings_providers.dart';
import '../widgets/gradient_scaffold.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  String _themeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'システム設定に従う';
      case ThemeMode.light:
        return 'ライト';
      case ThemeMode.dark:
        return 'ダーク';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final hapticsEnabled = ref.watch(hapticsEnabledProvider);

    return GradientScaffold(
      appBar: AppBar(title: const Text('設定'), backgroundColor: Colors.transparent),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('外観', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Card(
            child: RadioGroup<ThemeMode>(
              groupValue: themeMode,
              onChanged: (value) {
                if (value != null) {
                  ref.read(themeModeProvider.notifier).setThemeMode(value);
                }
              },
              child: Column(
                children: ThemeMode.values.map((mode) {
                  return RadioListTile<ThemeMode>(
                    title: Text(_themeModeLabel(mode)),
                    value: mode,
                  );
                }).toList(),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('操作', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Card(
            child: SwitchListTile(
              title: const Text('ハプティクス'),
              subtitle: const Text('ボタン操作時に振動でフィードバック'),
              value: hapticsEnabled,
              onChanged: (value) {
                ref.read(hapticsEnabledProvider.notifier).setEnabled(value);
              },
            ),
          ),
        ],
      ),
    );
  }
}
