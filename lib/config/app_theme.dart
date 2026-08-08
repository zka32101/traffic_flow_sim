import 'package:flutter/material.dart';

/// アプリ共通テーマ。ライト/ダーク両対応（WCAG AA コントラストを意識）。
class AppTheme {
  AppTheme._();

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: Colors.indigo,
      brightness: Brightness.light,
    );
    return ThemeData(colorScheme: scheme, useMaterial3: true);
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: Colors.indigo,
      brightness: Brightness.dark,
    );
    return ThemeData(colorScheme: scheme, useMaterial3: true);
  }

  /// 背景グラデーション（白無地NG・夜間は黒基調）
  static LinearGradient backgroundGradient(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: isDark
          ? [scheme.surface, Color.alphaBlend(scheme.primary.withValues(alpha: 0.12), scheme.surface)]
          : [scheme.surfaceContainerLowest, scheme.primaryContainer.withValues(alpha: 0.35)],
    );
  }
}
