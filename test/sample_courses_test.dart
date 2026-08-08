import 'package:flutter_test/flutter_test.dart';
import 'package:traffic_flow_sim/data/sample_courses.dart';

void main() {
  group('sampleCourses data integrity', () {
    test('no duplicate courseIds', () {
      final ids = sampleCourses.map((c) => c.courseId).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('all fields within valid ranges', () {
      for (final course in sampleCourses) {
        expect(course.difficulty, inInclusiveRange(1, 10), reason: course.courseId);
        expect(course.baseLayout.lanes, inInclusiveRange(1, 6), reason: course.courseId);
        expect(course.baseLayout.speedLimit, greaterThan(0), reason: course.courseId);
        expect(course.baseLayout.intersections, isNotEmpty, reason: course.courseId);

        for (final intersection in course.baseLayout.intersections) {
          expect(intersection.greenSeconds, inInclusiveRange(0, 120), reason: course.courseId);
          expect(intersection.redSeconds, inInclusiveRange(0, 120), reason: course.courseId);
          expect(intersection.position, greaterThanOrEqualTo(0), reason: course.courseId);
        }
      }
    });

    test('intersection positions are strictly increasing along the corridor', () {
      for (final course in sampleCourses) {
        final positions = course.baseLayout.intersections.map((i) => i.position).toList();
        final sorted = [...positions]..sort();
        expect(positions, sorted, reason: '${course.courseId}: positions must be pre-sorted');
        expect(positions.toSet().length, positions.length,
            reason: '${course.courseId}: duplicate positions');
      }
    });
  });
}
