import 'dart:math' as math;

import '../models/course.dart';

/// 交通工学の飽和交通流モデルを簡略化した決定論的シミュレーション。
/// 1車線あたりの飽和交通流量（緑信号中に通過できる台数/秒）を基準に、
/// 需要（到着率）がボトルネック交差点の処理能力を超えると渋滞が発生する。
class SimulationSettings {
  final int durationSeconds;

  /// 1車線あたりの到着需要（台/秒）。値が大きいほど混みやすい。
  final double demandPerLanePerSecond;

  const SimulationSettings({
    this.durationSeconds = 180,
    this.demandPerLanePerSecond = 0.35,
  });

  /// 難易度(1-10)から到着需要を算出する。難易度が高いほど交通量が多い。
  factory SimulationSettings.fromDifficulty(int difficulty, {int durationSeconds = 180}) {
    final clamped = difficulty.clamp(1, 10);
    return SimulationSettings(
      durationSeconds: durationSeconds,
      demandPerLanePerSecond: 0.2 + clamped * 0.03,
    );
  }
}

class SimulationResult {
  final int congestionTimeMs;
  final double avgSpeed;
  final int completedVehicles;
  final int score;
  final bool isCongested;

  /// シミュレーション開始から渋滞判定（キュー閾値超過）に達するまでの時間。
  /// 渋滞が一度も発生しない場合は null。
  final int? timeToCongestionMs;

  /// わざと渋滞モード用スコア。渋滞発生が速いほど高得点（0-1000）。
  /// 渋滞が発生しなかった場合は 0。
  final int sillyScore;

  const SimulationResult({
    required this.congestionTimeMs,
    required this.avgSpeed,
    required this.completedVehicles,
    required this.score,
    required this.isCongested,
    this.timeToCongestionMs,
    this.sillyScore = 0,
  });
}

class SimulationEngine {
  /// 1車線・緑信号1秒あたりに通過できる台数（飽和交通流量の簡略値）
  static const double saturationFlowPerLanePerSecond = 0.5;

  /// 渋滞と判定するキュー閾値（1車線あたりの滞留台数）
  static const double congestionQueueThresholdPerLane = 5.0;

  /// 渋滞時の最低速度（km/h）
  static const double minSpeedKmh = 5.0;

  static SimulationResult run(BaseLayout layout, SimulationSettings settings) {
    if (layout.intersections.isEmpty) {
      return SimulationResult(
        congestionTimeMs: 0,
        avgSpeed: layout.speedLimit.toDouble(),
        completedVehicles: (settings.demandPerLanePerSecond * layout.lanes * settings.durationSeconds).round(),
        score: 1000,
        isCongested: false,
      );
    }

    final arrivalRate = settings.demandPerLanePerSecond * layout.lanes;

    double bottleneckCapacity = double.infinity;
    for (final intersection in layout.intersections) {
      final cap = _intersectionCapacity(intersection, layout.lanes);
      if (cap < bottleneckCapacity) {
        bottleneckCapacity = cap;
      }
    }

    final durationMs = settings.durationSeconds * 1000;

    if (bottleneckCapacity <= 0 || arrivalRate <= bottleneckCapacity) {
      // 渋滞なし
      final completed = (arrivalRate * settings.durationSeconds).round();
      final score = _calculateScore(
        congestionTimeMs: 0,
        durationMs: durationMs,
        avgSpeed: layout.speedLimit.toDouble(),
        speedLimit: layout.speedLimit,
        completedVehicles: completed,
        expectedVehicles: completed,
      );
      return SimulationResult(
        congestionTimeMs: 0,
        avgSpeed: layout.speedLimit.toDouble(),
        completedVehicles: completed,
        score: score,
        isCongested: false,
      );
    }

    // 渋滞発生: 需要がボトルネック容量を超過
    final congestionRatio = arrivalRate / bottleneckCapacity;
    final excessRate = arrivalRate - bottleneckCapacity; // 台/秒 の滞留増加

    final queueThreshold = congestionQueueThresholdPerLane * layout.lanes;
    final timeToThresholdSec = queueThreshold / excessRate;

    final congestionTimeSec = math.max(0.0, settings.durationSeconds - timeToThresholdSec);
    final congestionTimeMs = math.min(durationMs, (congestionTimeSec * 1000).round());
    final timeToCongestionMs = congestionTimeMs > 0
        ? math.min(durationMs, (timeToThresholdSec * 1000).round())
        : null;

    final avgSpeed = math.max(
      minSpeedKmh,
      layout.speedLimit / congestionRatio,
    );

    final completedVehicles = (bottleneckCapacity * settings.durationSeconds).round();
    final expectedVehicles = (arrivalRate * settings.durationSeconds).round();

    final score = _calculateScore(
      congestionTimeMs: congestionTimeMs,
      durationMs: durationMs,
      avgSpeed: avgSpeed,
      speedLimit: layout.speedLimit,
      completedVehicles: completedVehicles,
      expectedVehicles: expectedVehicles,
    );

    return SimulationResult(
      congestionTimeMs: congestionTimeMs,
      avgSpeed: avgSpeed,
      completedVehicles: completedVehicles,
      score: score,
      isCongested: congestionTimeMs > 0,
      timeToCongestionMs: timeToCongestionMs,
      sillyScore: _calculateSillyScore(timeToCongestionMs: timeToCongestionMs, durationMs: durationMs),
    );
  }

  static int _calculateSillyScore({required int? timeToCongestionMs, required int durationMs}) {
    if (timeToCongestionMs == null || durationMs == 0) return 0;
    final speedRatio = 1.0 - (timeToCongestionMs / durationMs).clamp(0.0, 1.0);
    return (speedRatio * 1000).round().clamp(0, 1000);
  }

  static double _intersectionCapacity(IntersectionConfig intersection, int lanes) {
    switch (intersection.type) {
      case IntersectionType.signal:
        if (intersection.cycleSeconds <= 0) return 0;
        final greenRatio = intersection.greenSeconds / intersection.cycleSeconds;
        return lanes * saturationFlowPerLanePerSecond * greenRatio;
      case IntersectionType.roundabout:
        // ラウンドアバウトは信号待ちなしとみなし、飽和流量の80%を通年適用
        return lanes * saturationFlowPerLanePerSecond * 0.8;
      case IntersectionType.stopSign:
        // 一時停止は各車が減速するため飽和流量の40%
        return lanes * saturationFlowPerLanePerSecond * 0.4;
    }
  }

  /// 処理能力が最も低い（ボトルネックとなる）交差点のインデックスを返す。
  /// 交差点が存在しない場合は null。ビジュアライズで渋滞発生箇所を示すのに使う。
  static int? bottleneckIntersectionIndex(BaseLayout layout) {
    if (layout.intersections.isEmpty) return null;
    var minIndex = 0;
    var minCapacity = double.infinity;
    for (var i = 0; i < layout.intersections.length; i++) {
      final cap = _intersectionCapacity(layout.intersections[i], layout.lanes);
      if (cap < minCapacity) {
        minCapacity = cap;
        minIndex = i;
      }
    }
    return minIndex;
  }

  static int _calculateScore({
    required int congestionTimeMs,
    required int durationMs,
    required double avgSpeed,
    required int speedLimit,
    required int completedVehicles,
    required int expectedVehicles,
  }) {
    final congestionFreeRatio = durationMs == 0
        ? 1.0
        : 1.0 - (congestionTimeMs / durationMs).clamp(0.0, 1.0);
    final speedRatio = speedLimit == 0 ? 1.0 : (avgSpeed / speedLimit).clamp(0.0, 1.0);
    final completionRatio =
        expectedVehicles == 0 ? 1.0 : (completedVehicles / expectedVehicles).clamp(0.0, 1.0);

    final raw = congestionFreeRatio * 500 + speedRatio * 300 + completionRatio * 200;
    return raw.round().clamp(0, 1000);
  }
}
