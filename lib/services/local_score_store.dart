import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/score.dart';

/// スコアのローカル永続化（shared_preferences）。
/// Firestore接続後は同じインターフェースでリモートストアに差し替える想定。
class LocalScoreStore {
  static const _key = 'traffic_flow_sim.scores.v1';

  Future<List<ScoreRecord>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    return raw.map((s) {
      final map = jsonDecode(s) as Map<String, dynamic>;
      return ScoreRecord.fromMap(map['scoreId'] as String, map);
    }).toList();
  }

  Future<void> add(ScoreRecord record) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    final map = <String, dynamic>{'scoreId': record.scoreId, ...record.toMap()};
    raw.add(jsonEncode(map));
    await prefs.setStringList(_key, raw);
  }

  /// コースごとの自己ベストをスコア降順で返す。
  Future<List<ScoreRecord>> bestPerCourse() async {
    final all = await loadAll();
    final best = <String, ScoreRecord>{};
    for (final record in all) {
      final existing = best[record.courseId];
      if (existing == null || record.score > existing.score) {
        best[record.courseId] = record;
      }
    }
    final list = best.values.toList()..sort((a, b) => b.score.compareTo(a.score));
    return list;
  }
}
