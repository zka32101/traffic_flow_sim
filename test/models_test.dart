import 'package:flutter_test/flutter_test.dart';
import 'package:traffic_flow_sim/models/course.dart';
import 'package:traffic_flow_sim/models/daily_challenge.dart';
import 'package:traffic_flow_sim/models/score.dart';
import 'package:traffic_flow_sim/models/user_profile.dart';

void main() {
  group('Course serialization', () {
    test('round-trips through toMap/fromMap', () {
      final course = Course(
        courseId: 'shibuya_01',
        name: '渋谷スクランブル',
        difficulty: 3,
        city: '渋谷',
        baseLayout: const BaseLayout(
          lanes: 3,
          speedLimit: 40,
          intersections: [
            IntersectionConfig(
              position: 150,
              type: IntersectionType.signal,
              greenSeconds: 45,
              redSeconds: 45,
            ),
          ],
        ),
        contentVersion: 2,
      );

      final map = course.toMap();
      final restored = Course.fromMap('shibuya_01', map);

      expect(restored.courseId, course.courseId);
      expect(restored.name, course.name);
      expect(restored.difficulty, course.difficulty);
      expect(restored.baseLayout.lanes, 3);
      expect(restored.baseLayout.intersections.single.greenSeconds, 45);
      expect(restored.baseLayout.intersections.single.type, IntersectionType.signal);
      expect(restored.contentVersion, 2);
    });
  });

  group('ScoreRecord serialization', () {
    test('round-trips through toMap/fromMap', () {
      final record = ScoreRecord(
        scoreId: 's1',
        courseId: 'shibuya_01',
        score: 850,
        timestamp: DateTime(2026, 7, 10, 12, 0, 0),
        simulationData: const SimulationData(
          congestionTimeMs: 5000,
          avgSpeed: 32.456,
          completedVehicles: 120,
        ),
      );

      final map = record.toMap();
      final restored = ScoreRecord.fromMap('s1', map);

      expect(restored.score, 850);
      expect(restored.timestamp, record.timestamp);
      expect(restored.simulationData.completedVehicles, 120);
      // avgSpeed is rounded to 2 decimals on serialization
      expect(restored.simulationData.avgSpeed, 32.46);
    });
  });

  group('DailyChallenge serialization', () {
    test('round-trips through toMap/fromMap', () {
      const challenge = DailyChallenge(
        dateString: '2026-07-10',
        courseId: 'ikebukuro_02',
        theme: '夏祭り渋滞',
      );

      final map = challenge.toMap();
      final restored = DailyChallenge.fromMap('2026-07-10', map);

      expect(restored.courseId, 'ikebukuro_02');
      expect(restored.theme, '夏祭り渋滞');
    });
  });

  group('UserProfile.withStreakUpdate', () {
    final base = const UserProfile(userId: 'u1', displayName: 'かずき');

    test('first play sets streak to 1', () {
      final updated = base.withStreakUpdate(DateTime(2026, 7, 10));
      expect(updated.dailyStreak, 1);
    });

    test('consecutive day increments streak', () {
      final day1 = base.withStreakUpdate(DateTime(2026, 7, 9));
      final day2 = day1.withStreakUpdate(DateTime(2026, 7, 10));
      expect(day2.dailyStreak, 2);
    });

    test('same day does not increment streak', () {
      final day1 = base.withStreakUpdate(DateTime(2026, 7, 10, 9));
      final sameDayAgain = day1.withStreakUpdate(DateTime(2026, 7, 10, 18));
      expect(sameDayAgain.dailyStreak, 1);
    });

    test('gap of 2+ days resets streak to 1', () {
      final day1 = base.withStreakUpdate(DateTime(2026, 7, 1));
      final afterGap = day1.withStreakUpdate(DateTime(2026, 7, 10));
      expect(afterGap.dailyStreak, 1);
    });
  });
}
