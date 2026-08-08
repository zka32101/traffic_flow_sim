import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:traffic_flow_sim/widgets/loop_geometry.dart';

void main() {
  final geometry = LoopGeometry(size: const Size(400, 200));

  group('LoopGeometry', () {
    test('totalLength is positive and roughly matches the stadium perimeter', () {
      expect(geometry.totalLength, greaterThan(0));
      // 角丸長方形の外周は矩形の周長よりは短いが、極端に小さくはならない
      final rectPerimeter = 2 * ((400 - 56) + (200 - 56));
      expect(geometry.totalLength, lessThan(rectPerimeter));
      expect(geometry.totalLength, greaterThan(rectPerimeter * 0.5));
    });

    test('pointAt wraps around for p outside [0,1)', () {
      final a = geometry.pointAt(0.3);
      final b = geometry.pointAt(1.3);
      expect(a.position.dx, closeTo(b.position.dx, 0.01));
      expect(a.position.dy, closeTo(b.position.dy, 0.01));
    });

    test('pointAt(0) and pointAt(0.5) are on opposite sides of the loop', () {
      final start = geometry.pointAt(0);
      final half = geometry.pointAt(0.5);
      final distance = (start.position - half.position).distance;
      // 反対側なので、それなりに離れているはず
      expect(distance, greaterThan(100));
    });

    test('laneOffsetPosition moves lanes to opposite sides of center for a 2-lane road', () {
      const p = 0.25;
      final center = geometry.pointAt(p).position;
      final lane0 = geometry.laneOffsetPosition(p, 0, 2);
      final lane1 = geometry.laneOffsetPosition(p, 1, 2);

      expect((lane0 - center).distance, greaterThan(0));
      expect((lane1 - center).distance, greaterThan(0));
      // 反対方向にずれているはず
      final d0 = lane0 - center;
      final d1 = lane1 - center;
      expect(d0.dx * d1.dx + d0.dy * d1.dy, lessThan(0));
    });

    test('single lane sits on the center line', () {
      final center = geometry.pointAt(0.6).position;
      final lane = geometry.laneOffsetPosition(0.6, 0, 1);
      expect((lane - center).distance, closeTo(0, 0.01));
    });
  });
}
