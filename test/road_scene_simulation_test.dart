import 'package:flutter_test/flutter_test.dart';
import 'package:traffic_flow_sim/models/course.dart';
import 'package:traffic_flow_sim/widgets/road_scene_simulation.dart';

void main() {
  group('isGreenAt', () {
    test('signal is green during the green phase and red during the red phase', () {
      const intersection = IntersectionConfig(
        position: 100,
        type: IntersectionType.signal,
        greenSeconds: 30,
        redSeconds: 30,
      );

      expect(isGreenAt(intersection, 0), isTrue);
      expect(isGreenAt(intersection, 29), isTrue);
      expect(isGreenAt(intersection, 30), isFalse);
      expect(isGreenAt(intersection, 59), isFalse);
      expect(isGreenAt(intersection, 60), isTrue); // 次のサイクル
    });

    test('non-signal intersections are always green (passable)', () {
      const roundabout = IntersectionConfig(
        position: 100,
        type: IntersectionType.roundabout,
        greenSeconds: 0,
        redSeconds: 0,
      );
      expect(isGreenAt(roundabout, 12345), isTrue);
    });
  });

  group('corridorLength', () {
    test('returns a default length when there are no intersections', () {
      const layout = BaseLayout(lanes: 2, speedLimit: 50, intersections: []);
      expect(corridorLength(layout), 200);
    });

    test('extends past the last intersection', () {
      final layout = BaseLayout(
        lanes: 2,
        speedLimit: 50,
        intersections: const [
          IntersectionConfig(position: 100, type: IntersectionType.signal, greenSeconds: 30, redSeconds: 30),
          IntersectionConfig(position: 400, type: IntersectionType.signal, greenSeconds: 30, redSeconds: 30),
        ],
      );
      expect(corridorLength(layout), 550);
    });
  });

  group('visualLaneCount', () {
    test('caps at maxVisualLanes for wide roads', () {
      const layout = BaseLayout(lanes: 6, speedLimit: 50, intersections: []);
      expect(visualLaneCount(layout), maxVisualLanes);
    });

    test('matches actual lane count when below the cap', () {
      const layout = BaseLayout(lanes: 2, speedLimit: 50, intersections: []);
      expect(visualLaneCount(layout), 2);
    });
  });

  group('vehicle colors', () {
    test('cycles through the palette by lane index', () {
      expect(vehicleColorForLane(0), vehiclePalette[0]);
      expect(vehicleColorForLane(1), vehiclePalette[1]);
      expect(vehicleColorForLane(vehiclePalette.length), vehiclePalette[0]);
    });

    test('stopped vehicles get a red-shifted tint distinct from the base color', () {
      final base = vehicleColorForLane(1);
      final stoppedColor = vehicleDisplayColor(1, true);
      final movingColor = vehicleDisplayColor(1, false);

      expect(movingColor, base);
      expect(stoppedColor, isNot(base));
    });
  });
}
