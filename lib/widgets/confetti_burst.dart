import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// 高得点達成時の紙吹雪演出。
/// 各パーティクルはフェードイン→落下→フェードアウトの**有限**アニメーション1回のみ
/// （無限ループにしない — pumpAndSettleを使うwidget testを止めないため）。
class ConfettiBurst extends StatelessWidget {
  final int particleCount;

  const ConfettiBurst({super.key, this.particleCount = 16});

  static const _colors = [
    Color(0xFFE53935),
    Color(0xFF1E88E5),
    Color(0xFF43A047),
    Color(0xFFFB8C00),
    Color(0xFF8E24AA),
    Color(0xFFFDD835),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return IgnorePointer(
          child: Stack(
            children: List.generate(particleCount, (i) {
              final leftFraction = (i * 61 % 100) / 100;
              final color = _colors[i % _colors.length];
              final delay = Duration(milliseconds: i * 53 % 400);
              final dropDistance = 60.0 + (i % 4) * 20;
              final size = 6.0 + (i % 3) * 2.0;

              return Positioned(
                left: constraints.maxWidth * leftFraction,
                top: 0,
                child: Container(
                  width: size,
                  height: size * 1.6,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                )
                    .animate(delay: delay)
                    .fadeIn(duration: 150.ms)
                    .moveY(begin: 0, end: dropDistance, duration: 900.ms, curve: Curves.easeIn)
                    .fadeOut(delay: 500.ms, duration: 400.ms),
              );
            }),
          ),
        );
      },
    );
  }
}
