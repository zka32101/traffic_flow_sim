import 'package:flutter_test/flutter_test.dart';
import 'package:traffic_flow_sim/models/course.dart';
import 'package:traffic_flow_sim/widgets/road_scene_simulation.dart';
import 'package:traffic_flow_sim/widgets/road_scene_trajectory.dart';

void main() {
  group('computeVehicleTrajectory', () {
    test('vehicle moves at a constant rate when there are no intersections', () {
      const layout = BaseLayout(lanes: 1, speedLimit: 50, intersections: []);
      final trajectory = computeVehicleTrajectory(
        layout: layout,
        laneIndex: 0,
        laneInstance: 0,
        totalInstances: 1,
        simWindowSeconds: 20,
      );

      expect(trajectory.stoppedFlags.every((s) => !s), isTrue);

      // 等速なので、隣接サンプル間の移動距離はほぼ一定であるはず
      final deltas = <double>[];
      for (var i = 1; i < trajectory.positions.length; i++) {
        deltas.add(forwardDistance(trajectory.positions[i - 1], trajectory.positions[i]));
      }
      final avg = deltas.reduce((a, b) => a + b) / deltas.length;
      for (final d in deltas.skip(5)) {
        // 加速直後の数ステップを除けば、平均から大きくは外れない
        expect(d, closeTo(avg, avg * 0.5 + 0.0005));
      }
    });

    test('vehicle decelerates smoothly approaching red and reaccelerates smoothly after green '
        '(no instantaneous jumps in position)', () {
      // corridorLength=250m, speedLimit=36km/h=10m/s -> maxSpeed=0.04 progress/sec
      // 信号: green=5, red=15 (cycle=20) を position=100 (normPos=0.4) に設置
      final layout = BaseLayout(
        lanes: 1,
        speedLimit: 36,
        intersections: const [
          IntersectionConfig(position: 100, type: IntersectionType.signal, greenSeconds: 5, redSeconds: 15),
        ],
      );
      final trajectory = computeVehicleTrajectory(
        layout: layout,
        laneIndex: 0,
        laneInstance: 0,
        totalInstances: 1,
        simWindowSeconds: 60,
        dt: 0.1,
      );

      final maxStepDistance = (36 * 1000 / 3600 / 250) * 0.1; // maxSpeed * dt

      // 連続性: どのステップも「最高速で進める距離」を大きく超えて動かない
      // （瞬間的なワープが無いことの直接的な検証）
      for (var i = 1; i < trajectory.positions.length; i++) {
        final delta = forwardDistance(trajectory.positions[i - 1], trajectory.positions[i]);
        expect(delta, lessThanOrEqualTo(maxStepDistance * 1.05));
      }

      // 減速が実際に発生している（どこかでほぼ停止するステップがある）
      expect(trajectory.stoppedFlags.any((s) => s), isTrue);

      // 減速後、再加速して最高速付近まで戻っている（動きが「詰んで」終わらない）。
      // cycle=20sのうち後半(green再開を含む)区間で確認する。
      final lateDeltas = <double>[];
      for (var i = trajectory.positions.length - 150; i < trajectory.positions.length; i++) {
        lateDeltas.add(forwardDistance(trajectory.positions[i - 1], trajectory.positions[i]));
      }
      expect(lateDeltas.any((d) => d > maxStepDistance * 0.7), isTrue);
    });

    test('multiple lane instances queue up behind a long red signal', () {
      final layout = BaseLayout(
        lanes: 1,
        speedLimit: 36,
        intersections: const [
          IntersectionConfig(position: 100, type: IntersectionType.signal, greenSeconds: 5, redSeconds: 95),
        ],
      );

      final trajectories = [
        for (var i = 0; i < vehiclesPerLane; i++)
          computeVehicleTrajectory(
            layout: layout,
            laneIndex: 0,
            laneInstance: i,
            totalInstances: vehiclesPerLane,
            simWindowSeconds: 30,
          ),
      ];

      final stoppedAtEnd = trajectories.where((t) => t.stoppedFlags.last).length;
      expect(stoppedAtEnd, greaterThan(1));
    });
  });
}
