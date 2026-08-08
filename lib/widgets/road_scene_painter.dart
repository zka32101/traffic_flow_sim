import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/course.dart';
import 'loop_geometry.dart';
import 'road_scene_simulation.dart';

/// 交差点ごとの信号点灯状態（描画用）。
class IntersectionVisualState {
  final IntersectionConfig intersection;
  final bool isGreen;
  final bool isBottleneck;

  const IntersectionVisualState({
    required this.intersection,
    required this.isGreen,
    required this.isBottleneck,
  });
}

/// 周回トラック（1画面に全体が収まる俯瞰ビュー）を描画するCustomPainter。
/// 渋滞が発生すると信号手前に車が連なって見え、発生していなければ
/// 車が間隔を保ってスムーズに周回する様子がその場で視認できる。
class RoadScenePainter extends CustomPainter {
  final BaseLayout layout;
  final List<IntersectionVisualState> intersectionStates;
  final List<VehicleVisualState> vehicles;
  final bool isCongested;

  RoadScenePainter({
    required this.layout,
    required this.intersectionStates,
    required this.vehicles,
    this.isCongested = false,
  });

  double get _trackWidth => visualLaneCount(layout) * 13.0 + 12.0;

  @override
  void paint(Canvas canvas, Size size) {
    final geometry = LoopGeometry(size: size);
    _paintBackground(canvas, size);
    _paintTrack(canvas, geometry);
    _paintCenterLine(canvas, geometry);
    for (final state in intersectionStates) {
      _paintIntersection(canvas, geometry, state);
    }
    for (final vehicle in vehicles) {
      _paintVehicle(canvas, geometry, vehicle);
    }
  }

  void _paintBackground(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(rect, Paint()..color = const Color(0xFFCFE8C7));

    // 芝生っぽい装飾の木（楽しさ演出）
    final treeSpots = [
      Offset(size.width * 0.06, size.height * 0.15),
      Offset(size.width * 0.94, size.height * 0.2),
      Offset(size.width * 0.08, size.height * 0.85),
      Offset(size.width * 0.93, size.height * 0.82),
    ];
    for (final spot in treeSpots) {
      canvas.drawCircle(spot, size.shortestSide * 0.045, Paint()..color = const Color(0xFF6FA85C));
    }
  }

  void _paintTrack(Canvas canvas, LoopGeometry geometry) {
    final path = geometry.centerPathForPaint;
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF3A3F44)
        ..style = PaintingStyle.stroke
        ..strokeWidth = _trackWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  void _paintCenterLine(Canvas canvas, LoopGeometry geometry) {
    if (layout.lanes < 2) return;
    final path = geometry.centerPathForPaint;
    final dashPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    canvas.drawPath(
      _dashedPath(path, dashLength: 8, gapLength: 6),
      dashPaint,
    );
  }

  Path _dashedPath(Path source, {required double dashLength, required double gapLength}) {
    final dashed = Path();
    for (final metric in source.computeMetrics()) {
      var distance = 0.0;
      var draw = true;
      while (distance < metric.length) {
        final next = distance + (draw ? dashLength : gapLength);
        if (draw) {
          dashed.addPath(metric.extractPath(distance, next.clamp(0, metric.length)), Offset.zero);
        }
        distance = next;
        draw = !draw;
      }
    }
    return dashed;
  }

  void _paintIntersection(Canvas canvas, LoopGeometry geometry, IntersectionVisualState state) {
    final corridorLen = corridorLength(layout);
    final p = intersectionNormPos(state.intersection, corridorLen);
    final tangent = geometry.pointAt(p);
    final center = tangent.position;
    final normalAngle = tangent.vector.direction + 1.5707963267948966;
    final normal = Offset(_cosApprox(normalAngle), _sinApprox(normalAngle));

    // 停止線（道路を横切るバー）
    final halfTrack = _trackWidth / 2 + 2;
    canvas.drawLine(
      center - normal * halfTrack,
      center + normal * halfTrack,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.9)
        ..strokeWidth = 3,
    );

    final markerPos = center + normal * (halfTrack + 10);
    if (state.intersection.type == IntersectionType.signal) {
      _paintTrafficLight(canvas, markerPos, state.isGreen);
    } else {
      _paintNeutralMarker(canvas, markerPos, state.intersection.type);
    }

    if (state.isBottleneck && isCongested) {
      canvas.drawCircle(center, halfTrack + 6, Paint()..color = Colors.redAccent.withValues(alpha: 0.35));
    }
  }

  void _paintTrafficLight(Canvas canvas, Offset center, bool isGreen) {
    final boxRect = Rect.fromCenter(center: center, width: 12, height: 20);
    canvas.drawRRect(
      RRect.fromRectAndRadius(boxRect, const Radius.circular(3)),
      Paint()..color = Colors.black87,
    );
    canvas.drawCircle(
      Offset(boxRect.center.dx, boxRect.top + boxRect.height * 0.28),
      3.0,
      Paint()..color = isGreen ? Colors.red.shade900.withValues(alpha: 0.3) : Colors.red,
    );
    canvas.drawCircle(
      Offset(boxRect.center.dx, boxRect.bottom - boxRect.height * 0.28),
      3.0,
      Paint()..color = isGreen ? Colors.greenAccent : Colors.green.shade900.withValues(alpha: 0.3),
    );
  }

  void _paintNeutralMarker(Canvas canvas, Offset center, IntersectionType type) {
    canvas.drawCircle(
      center,
      7,
      Paint()..color = type == IntersectionType.roundabout ? Colors.blueAccent : Colors.orangeAccent,
    );
  }

  void _paintVehicle(Canvas canvas, LoopGeometry geometry, VehicleVisualState vehicle) {
    final lanes = visualLaneCount(layout);
    final center = geometry.laneOffsetPosition(vehicle.progress, vehicle.laneIndex, lanes);
    final angle = geometry.pointAt(vehicle.progress).vector.direction;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);
    final rect = Rect.fromCenter(center: Offset.zero, width: 12, height: 7);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(2)),
      Paint()..color = vehicleDisplayColor(vehicle.laneIndex, vehicle.stopped),
    );
    canvas.restore();
  }

  double _cosApprox(double radians) => math.cos(radians);
  double _sinApprox(double radians) => math.sin(radians);

  @override
  bool shouldRepaint(covariant RoadScenePainter oldDelegate) {
    return oldDelegate.layout != layout ||
        oldDelegate.intersectionStates != intersectionStates ||
        oldDelegate.vehicles != vehicles ||
        oldDelegate.isCongested != isCongested;
  }
}
