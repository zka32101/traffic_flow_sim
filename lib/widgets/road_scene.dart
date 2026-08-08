import 'package:flutter/material.dart';

import '../models/course.dart';
import '../services/simulation_engine.dart';
import 'road_scene_painter.dart';
import 'road_scene_simulation.dart';
import 'road_scene_trajectory.dart';

/// 2.5D（疑似パース）の道路シーン。
/// animate=false: 現在の信号設定を静止画で表示（Editor用のライブプレビュー）。
/// animate=true: 一度だけ有限時間（playbackDuration）再生し、信号に合わせて車が
///   加減速する様子を見せる（Result用）。無限ループにはしない
///   （pumpAndSettle を使う widget test を止めないため）。
/// 車の動きは時間積分によるステートフルな軌道（road_scene_trajectory.dart）を
/// 事前計算して再生するため、減速・加速とも物理的に連続（瞬間ジャンプなし）。
class RoadScene extends StatefulWidget {
  final BaseLayout layout;
  final bool animate;
  final bool isCongested;
  final double simWindowSeconds;
  final Duration playbackDuration;

  const RoadScene({
    super.key,
    required this.layout,
    this.animate = false,
    this.isCongested = false,
    this.simWindowSeconds = 60,
    this.playbackDuration = const Duration(seconds: 5),
  });

  @override
  State<RoadScene> createState() => _RoadSceneState();
}

class _RoadSceneState extends State<RoadScene> with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  List<VehicleTrajectory>? _trajectories;

  @override
  void initState() {
    super.initState();
    if (widget.animate) {
      _trajectories = _computeTrajectories(widget.layout);
      _controller = AnimationController(vsync: this, duration: widget.playbackDuration)..forward();
    }
  }

  @override
  void didUpdateWidget(covariant RoadScene oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate && oldWidget.layout != widget.layout) {
      _trajectories = _computeTrajectories(widget.layout);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  List<VehicleTrajectory> _computeTrajectories(BaseLayout layout) {
    final lanes = visualLaneCount(layout);
    return [
      for (var lane = 0; lane < lanes; lane++)
        for (var instance = 0; instance < vehiclesPerLane; instance++)
          computeVehicleTrajectory(
            layout: layout,
            laneIndex: lane,
            laneInstance: instance,
            totalInstances: vehiclesPerLane,
            simWindowSeconds: widget.simWindowSeconds,
          ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      // 静止プレビュー（Editor用）: 毎回最新のlayoutで初期配置を計算する。
      final trajectories = _computeTrajectories(widget.layout);
      return _buildScene(0, trajectories);
    }
    return AnimatedBuilder(
      animation: _controller!,
      builder: (context, _) => _buildScene(_controller!.value * widget.simWindowSeconds, _trajectories!),
    );
  }

  Widget _buildScene(double simSeconds, List<VehicleTrajectory> trajectories) {
    final bottleneckIndex = SimulationEngine.bottleneckIntersectionIndex(widget.layout);
    final intersectionStates = [
      for (var i = 0; i < widget.layout.intersections.length; i++)
        IntersectionVisualState(
          intersection: widget.layout.intersections[i],
          isGreen: isGreenAt(widget.layout.intersections[i], simSeconds),
          isBottleneck: i == bottleneckIndex,
        ),
    ];

    final lanes = visualLaneCount(widget.layout);
    var trajectoryIndex = 0;
    final vehicles = <VehicleVisualState>[];
    for (var lane = 0; lane < lanes; lane++) {
      for (var instance = 0; instance < vehiclesPerLane; instance++) {
        vehicles.add(trajectories[trajectoryIndex].sampleAt(simSeconds, lane));
        trajectoryIndex++;
      }
    }

    return CustomPaint(
      painter: RoadScenePainter(
        layout: widget.layout,
        intersectionStates: intersectionStates,
        vehicles: vehicles,
        isCongested: widget.isCongested,
      ),
      child: const SizedBox.expand(),
    );
  }
}
