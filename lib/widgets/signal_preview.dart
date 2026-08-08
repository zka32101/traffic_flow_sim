import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// 信号の青/赤比率を視覚化するプレビューバー。
/// 値が変わるたびにフェードインして「動作表現」を演出する（無限ループにはしない —
/// pumpAndSettle を用いる widget test を止まらせないため、有限アニメーションのみ使用）。
class SignalPreview extends StatelessWidget {
  final int greenSeconds;
  final int redSeconds;

  const SignalPreview({
    super.key,
    required this.greenSeconds,
    required this.redSeconds,
  });

  @override
  Widget build(BuildContext context) {
    final total = greenSeconds + redSeconds;

    return LayoutBuilder(
      builder: (context, constraints) {
        final greenWidth =
            total == 0 ? constraints.maxWidth / 2 : constraints.maxWidth * greenSeconds / total;
        final redWidth = constraints.maxWidth - greenWidth;

        return ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Row(
            children: [
              Container(width: greenWidth, height: 14, color: Colors.green.shade500),
              Container(width: redWidth, height: 14, color: Colors.red.shade400),
            ],
          ),
        )
            .animate(key: ValueKey('$greenSeconds-$redSeconds'))
            .fadeIn(duration: 200.ms)
            .slideY(begin: 0.2, end: 0, duration: 200.ms, curve: Curves.easeOut);
      },
    );
  }
}
