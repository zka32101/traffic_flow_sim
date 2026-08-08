import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'config/app_theme.dart';
import 'providers/settings_providers.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const ProviderScope(child: TrafficFlowSimApp()));
}

class TrafficFlowSimApp extends ConsumerWidget {
  const TrafficFlowSimApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp(
      title: '渋滞シミュレーター',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      home: const HomeScreen(),
    );
  }
}
