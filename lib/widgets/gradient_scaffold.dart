import 'package:flutter/material.dart';

import '../config/app_theme.dart';

/// グラデーション背景付き Scaffold（白無地NGルール対応）。
class GradientScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final EdgeInsetsGeometry padding;

  const GradientScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: false,
      body: DecoratedBox(
        decoration: BoxDecoration(gradient: AppTheme.backgroundGradient(context)),
        child: Padding(padding: padding, child: body),
      ),
    );
  }
}
