import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:traffic_flow_sim/models/score.dart';
import 'package:traffic_flow_sim/services/local_profile_store.dart';
import 'package:traffic_flow_sim/services/local_score_store.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('LocalScoreStore', () {
    test('add + loadAll round-trips records', () async {
      final store = LocalScoreStore();
      await store.add(ScoreRecord(
        scoreId: 's1',
        courseId: 'shibuya_01',
        score: 700,
        timestamp: DateTime(2026, 7, 10),
        simulationData: const SimulationData(congestionTimeMs: 0, avgSpeed: 40, completedVehicles: 50),
      ));

      final all = await store.loadAll();
      expect(all, hasLength(1));
      expect(all.first.score, 700);
      expect(all.first.courseId, 'shibuya_01');
    });

    test('bestPerCourse keeps only the highest score per course, sorted desc', () async {
      final store = LocalScoreStore();
      Future<void> addScore(String courseId, int score) => store.add(ScoreRecord(
            scoreId: 'id-$courseId-$score',
            courseId: courseId,
            score: score,
            timestamp: DateTime(2026, 7, 10),
            simulationData: const SimulationData(congestionTimeMs: 0, avgSpeed: 40, completedVehicles: 50),
          ));

      await addScore('shibuya_01', 500);
      await addScore('shibuya_01', 900); // 上書きされるべき（自己ベスト）
      await addScore('ikebukuro_01', 700);

      final best = await store.bestPerCourse();
      expect(best, hasLength(2));
      expect(best.first.courseId, 'shibuya_01');
      expect(best.first.score, 900);
      expect(best.last.courseId, 'ikebukuro_01');
    });
  });

  group('LocalProfileStore', () {
    test('load returns default profile when nothing saved', () async {
      final store = LocalProfileStore();
      final profile = await store.load();
      expect(profile.dailyStreak, 0);
    });

    test('recordPlay increments streak on consecutive days', () async {
      final store = LocalProfileStore();
      await store.recordPlay(DateTime(2026, 7, 9));
      final updated = await store.recordPlay(DateTime(2026, 7, 10));
      expect(updated.dailyStreak, 2);
    });
  });
}
