import 'package:flutter_test/flutter_test.dart';
import 'package:traffic_flow_sim/models/course.dart';
import 'package:traffic_flow_sim/services/simulation_engine.dart';

void main() {
  group('SimulationEngine.run', () {
    test('capacity exceeds demand -> no congestion, score 1000', () {
      final layout = BaseLayout(
        lanes: 2,
        speedLimit: 50,
        intersections: const [
          IntersectionConfig(
            position: 100,
            type: IntersectionType.signal,
            greenSeconds: 60,
            redSeconds: 30,
          ),
        ],
      );
      const settings = SimulationSettings(
        durationSeconds: 180,
        demandPerLanePerSecond: 0.2,
      );

      final result = SimulationEngine.run(layout, settings);

      expect(result.isCongested, isFalse);
      expect(result.congestionTimeMs, 0);
      expect(result.avgSpeed, 50.0);
      expect(result.completedVehicles, 72);
      expect(result.score, 1000);
      expect(result.timeToCongestionMs, isNull);
      expect(result.sillyScore, 0);
    });

    test('demand exceeds bottleneck capacity -> congestion with expected values', () {
      final layout = BaseLayout(
        lanes: 2,
        speedLimit: 50,
        intersections: const [
          IntersectionConfig(
            position: 100,
            type: IntersectionType.signal,
            greenSeconds: 30,
            redSeconds: 60,
          ),
        ],
      );
      const settings = SimulationSettings(
        durationSeconds: 180,
        demandPerLanePerSecond: 0.5,
      );

      final result = SimulationEngine.run(layout, settings);

      expect(result.isCongested, isTrue);
      expect(result.congestionTimeMs, 165000);
      expect(result.avgSpeed, closeTo(16.6667, 0.001));
      expect(result.completedVehicles, 60);
      expect(result.score, 208);
      expect(result.timeToCongestionMs, 15000);
      expect(result.sillyScore, 917);
    });

    test('multiple intersections: bottleneck is the tightest signal', () {
      final layout = BaseLayout(
        lanes: 2,
        speedLimit: 50,
        intersections: const [
          IntersectionConfig(
            position: 100,
            type: IntersectionType.signal,
            greenSeconds: 80,
            redSeconds: 10, // wide capacity
          ),
          IntersectionConfig(
            position: 300,
            type: IntersectionType.signal,
            greenSeconds: 30,
            redSeconds: 60, // this is the bottleneck (same as previous test)
          ),
        ],
      );
      const settings = SimulationSettings(
        durationSeconds: 180,
        demandPerLanePerSecond: 0.5,
      );

      final result = SimulationEngine.run(layout, settings);

      // Bottleneck capacity should match the single-tight-signal case above.
      expect(result.completedVehicles, 60);
      expect(result.isCongested, isTrue);
    });

    test('roundabout has higher capacity than equivalent-cycle signal', () {
      final signalLayout = BaseLayout(
        lanes: 2,
        speedLimit: 50,
        intersections: const [
          IntersectionConfig(
            position: 100,
            type: IntersectionType.signal,
            greenSeconds: 30,
            redSeconds: 30,
          ),
        ],
      );
      final roundaboutLayout = BaseLayout(
        lanes: 2,
        speedLimit: 50,
        intersections: const [
          IntersectionConfig(
            position: 100,
            type: IntersectionType.roundabout,
            greenSeconds: 0,
            redSeconds: 0,
          ),
        ],
      );
      const settings = SimulationSettings(
        durationSeconds: 180,
        demandPerLanePerSecond: 0.45,
      );

      final signalResult = SimulationEngine.run(signalLayout, settings);
      final roundaboutResult = SimulationEngine.run(roundaboutLayout, settings);

      expect(roundaboutResult.completedVehicles, greaterThan(signalResult.completedVehicles));
    });

    test('avgSpeed never drops below minSpeedKmh floor', () {
      final layout = BaseLayout(
        lanes: 1,
        speedLimit: 50,
        intersections: const [
          IntersectionConfig(
            position: 100,
            type: IntersectionType.signal,
            greenSeconds: 5,
            redSeconds: 115,
          ),
        ],
      );
      const settings = SimulationSettings(
        durationSeconds: 180,
        demandPerLanePerSecond: 0.5,
      );

      final result = SimulationEngine.run(layout, settings);

      expect(result.avgSpeed, greaterThanOrEqualTo(SimulationEngine.minSpeedKmh));
    });

    test('sillyScore rewards faster congestion onset', () {
      final tightLayout = BaseLayout(
        lanes: 1,
        speedLimit: 50,
        intersections: const [
          IntersectionConfig(
            position: 100,
            type: IntersectionType.signal,
            greenSeconds: 5,
            redSeconds: 115,
          ),
        ],
      );
      final looseLayout = BaseLayout(
        lanes: 1,
        speedLimit: 50,
        intersections: const [
          IntersectionConfig(
            position: 100,
            type: IntersectionType.signal,
            greenSeconds: 40,
            redSeconds: 50,
          ),
        ],
      );
      const settings = SimulationSettings(
        durationSeconds: 180,
        demandPerLanePerSecond: 0.5,
      );

      final tightResult = SimulationEngine.run(tightLayout, settings);
      final looseResult = SimulationEngine.run(looseLayout, settings);

      expect(tightResult.isCongested, isTrue);
      expect(looseResult.isCongested, isTrue);
      expect(tightResult.sillyScore, greaterThan(looseResult.sillyScore));
      expect(tightResult.sillyScore, inInclusiveRange(0, 1000));
      expect(looseResult.sillyScore, inInclusiveRange(0, 1000));
    });

    test('difficulty-derived settings scale demand with difficulty', () {
      final low = SimulationSettings.fromDifficulty(1);
      final high = SimulationSettings.fromDifficulty(10);

      expect(low.demandPerLanePerSecond, closeTo(0.23, 0.0001));
      expect(high.demandPerLanePerSecond, closeTo(0.5, 0.0001));
    });
  });

  group('SimulationEngine.bottleneckIntersectionIndex', () {
    test('returns null when there are no intersections', () {
      const layout = BaseLayout(lanes: 2, speedLimit: 50, intersections: []);
      expect(SimulationEngine.bottleneckIntersectionIndex(layout), isNull);
    });

    test('returns the index of the tightest signal', () {
      final layout = BaseLayout(
        lanes: 2,
        speedLimit: 50,
        intersections: const [
          IntersectionConfig(
            position: 100,
            type: IntersectionType.signal,
            greenSeconds: 80,
            redSeconds: 10,
          ),
          IntersectionConfig(
            position: 300,
            type: IntersectionType.signal,
            greenSeconds: 20,
            redSeconds: 70,
          ),
          IntersectionConfig(
            position: 500,
            type: IntersectionType.signal,
            greenSeconds: 60,
            redSeconds: 30,
          ),
        ],
      );

      expect(SimulationEngine.bottleneckIntersectionIndex(layout), 1);
    });
  });
}
