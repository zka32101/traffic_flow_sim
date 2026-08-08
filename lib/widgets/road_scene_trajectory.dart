import 'dart:math' as math;

import '../models/course.dart';
import 'road_scene_simulation.dart';

/// 加減速を時間積分するステートフルな車の軌道。
/// 赤信号への接近（減速）・青信号後の発進（加速）の両方が物理的に連続になる
/// （瞬間停止・瞬間ジャンプをしない）。
class VehicleTrajectory {
  final List<double> positions;
  final List<bool> stoppedFlags;
  final double dt;

  const VehicleTrajectory({
    required this.positions,
    required this.stoppedFlags,
    required this.dt,
  });

  VehicleVisualState sampleAt(double simSeconds, int laneIndex) {
    if (positions.isEmpty) {
      return VehicleVisualState(laneIndex: laneIndex, progress: 0, stopped: false);
    }
    final index = (simSeconds / dt).round().clamp(0, positions.length - 1);
    return VehicleVisualState(
      laneIndex: laneIndex,
      progress: positions[index],
      stopped: stoppedFlags[index],
    );
  }
}

/// 減速を開始する交差点までの距離（進捗比率）。
const double brakingLookahead = 0.18;

/// 停止(速度0)から最高速に達するまでの目安時間（秒）。
const double accelTimeSeconds = 1.6;

/// 最高速から停止するまでの目安時間（秒）。
const double decelTimeSeconds = 1.1;

/// レーンlaneIndex・インスタンスlaneInstanceの車の軌道を、時間積分（dt刻み）で
/// simWindowSeconds分だけ事前計算する。純粋関数（同じ入力なら常に同じ結果）。
VehicleTrajectory computeVehicleTrajectory({
  required BaseLayout layout,
  required int laneIndex,
  required int laneInstance,
  required int totalInstances,
  required double simWindowSeconds,
  double dt = 0.1,
}) {
  final corridorLen = corridorLength(layout);
  final speedMetersPerSecond = layout.speedLimit * 1000 / 3600;
  final maxSpeed = speedMetersPerSecond <= 0 ? 0.01 : speedMetersPerSecond / corridorLen;
  final lanes = visualLaneCount(layout).clamp(1, maxVisualLanes);
  final instances = totalInstances < 1 ? 1 : totalInstances;

  final accel = maxSpeed / accelTimeSeconds;
  final decel = maxSpeed / decelTimeSeconds;

  var position = wrap1((laneIndex + laneInstance / instances) / lanes);
  var speed = maxSpeed;

  final steps = (simWindowSeconds / dt).ceil();
  final positions = List<double>.filled(steps + 1, 0);
  final stoppedFlags = List<bool>.filled(steps + 1, false);
  positions[0] = position;
  stoppedFlags[0] = false;

  for (var i = 1; i <= steps; i++) {
    final t = (i - 1) * dt;

    double? brakeDistance;
    for (final intersection in layout.intersections) {
      final normPos = intersectionNormPos(intersection, corridorLen);
      final dist = forwardDistance(position, normPos);
      if (dist > brakingLookahead) continue;
      if (!isGreenAt(intersection, t)) {
        brakeDistance = brakeDistance == null ? dist : math.min(brakeDistance, dist);
      }
    }

    double targetSpeed = maxSpeed;
    if (brakeDistance != null) {
      final effectiveDist = (brakeDistance - queueGap).clamp(0.0, brakingLookahead);
      targetSpeed = maxSpeed * (effectiveDist / brakingLookahead);
    }

    if (speed < targetSpeed) {
      speed = math.min(targetSpeed, speed + accel * dt);
    } else {
      speed = math.max(targetSpeed, speed - decel * dt);
    }

    position = wrap1(position + speed * dt);
    positions[i] = position;
    stoppedFlags[i] = speed < maxSpeed * 0.1;
  }

  return VehicleTrajectory(positions: positions, stoppedFlags: stoppedFlags, dt: dt);
}
