import 'dart:math' as math;
import 'dart:ui';

/// 周回トラック（角丸長方形/スタジアム形状）のジオメトリ計算。
/// コース全体が1画面に収まるため、渋滞発生時に車が詰まる様子・
/// 発生していない時に滑らかに流れる様子がその場で視認できる。
class LoopGeometry {
  final Size size;
  final double margin;

  LoopGeometry({required this.size, this.margin = 28});

  Path? _cachedPath;
  PathMetric? _cachedMetric;

  Path get _centerPath {
    if (_cachedPath != null) return _cachedPath!;
    final rect = Rect.fromLTRB(margin, margin, size.width - margin, size.height - margin);
    final radius = rect.shortestSide / 2;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    final path = Path()..addRRect(rrect);
    _cachedPath = path;
    return path;
  }

  PathMetric get _metric {
    return _cachedMetric ??= _centerPath.computeMetrics().first;
  }

  /// トラックの中心線Path（ストローク描画・破線描画用に公開）。
  Path get centerPathForPaint => _centerPath;

  double get totalLength => _metric.length;

  /// 進捗率p(0〜1、周回でラップ)における中心線上の位置と進行方向角度。
  Tangent pointAt(double p) {
    final normalized = p - p.floorToDouble();
    final distance = (normalized * totalLength).clamp(0.0, totalLength);
    return _metric.getTangentForOffset(distance) ?? const Tangent(Offset.zero, Offset(1, 0));
  }

  /// レーンオフセットを加味した描画位置。laneIndexが大きいほど内側にずれる。
  Offset laneOffsetPosition(double p, int laneIndex, int totalLanes, {double laneSpacing = 9}) {
    final tangent = pointAt(p);
    final lanes = totalLanes < 1 ? 1 : totalLanes;
    final centerOffset = (lanes - 1) / 2.0;
    final lateral = (laneIndex - centerOffset) * laneSpacing;
    final normalAngle = tangent.vector.direction + math.pi / 2;
    return tangent.position + Offset(lateral * math.cos(normalAngle), lateral * math.sin(normalAngle));
  }
}
