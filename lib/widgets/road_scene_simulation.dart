import 'dart:ui';

import '../models/course.dart';

/// 2.5D道路シーンの見た目用ロジック（実際の集計シミュレーションとは独立した簡易ループ再生）。
/// SimulationEngineの計算結果とは別に、車が信号で止まる様子を視覚的に表現するための
/// 決定論的な純粋関数群。

/// 車1台の描画状態。progressは0(手前)〜1(奥/消失点付近)の正規化位置。
class VehicleVisualState {
  final int laneIndex;
  final double progress;
  final bool stopped;

  const VehicleVisualState({
    required this.laneIndex,
    required this.progress,
    required this.stopped,
  });
}

/// 停止線の手前に保つ車間ギャップ（進捗比率）。
const double queueGap = 0.02;
const int maxVisualLanes = 4;

/// 1レーンあたりに描画する車の台数。複数台にすることで、渋滞時に
/// 車が連なって詰まる様子・非渋滞時に間隔を保って流れる様子が視覚的にわかる。
const int vehiclesPerLane = 4;

/// fromからtoまで、進行方向（0→1増加）に沿って進んだときの距離を返す（0以上1未満）。
/// 周回コースのラップ（1→0）を考慮する。
double forwardDistance(double from, double to) {
  final raw = (to - from) % 1.0;
  return raw < 0 ? raw + 1.0 : raw;
}

double wrap1(double x) {
  final m = x % 1.0;
  return m < 0 ? m + 1.0 : m;
}

/// 交差点を含む仮想コースの全長（m）。プレビュー描画のスケール用。
double corridorLength(BaseLayout layout) {
  if (layout.intersections.isEmpty) return 200;
  final lastPosition = layout.intersections.last.position;
  return lastPosition + 150;
}

/// simSeconds時点で信号が青かどうか。信号以外の交差点は常にtrue（別マーカーで描画）。
bool isGreenAt(IntersectionConfig intersection, double simSeconds) {
  if (intersection.type != IntersectionType.signal) return true;
  if (intersection.cycleSeconds <= 0) return false;
  final phase = simSeconds % intersection.cycleSeconds;
  return phase < intersection.greenSeconds;
}

double intersectionNormPos(IntersectionConfig intersection, double corridorLen) {
  if (corridorLen <= 0) return 0;
  return (intersection.position / corridorLen).clamp(0.0, 0.94);
}

int visualLaneCount(BaseLayout layout) {
  return layout.lanes < maxVisualLanes ? layout.lanes : maxVisualLanes;
}

/// レーンごとにカラフルな車体色を割り当てる（見た目の楽しさ向上用）。
const List<Color> vehiclePalette = [
  Color(0xFFE53935), // red
  Color(0xFF1E88E5), // blue
  Color(0xFF43A047), // green
  Color(0xFFFB8C00), // orange
];

Color vehicleColorForLane(int laneIndex) {
  return vehiclePalette[laneIndex % vehiclePalette.length];
}

/// 停止中は少し赤みを足してブレーキランプ点灯のような印象にする。
Color vehicleDisplayColor(int laneIndex, bool stopped) {
  final base = vehicleColorForLane(laneIndex);
  if (!stopped) return base;
  return Color.lerp(base, const Color(0xFFB71C1C), 0.5) ?? base;
}
