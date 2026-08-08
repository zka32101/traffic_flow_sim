import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/sample_courses.dart';
import '../models/course.dart';

final courseListProvider = Provider<List<Course>>((ref) => sampleCourses);

/// 1月1日を1とした年間通日を返す（デイリーチャレンジのコース選出に使用）。
int dayOfYear(DateTime date) => date.difference(DateTime(date.year, 1, 1)).inDays + 1;

/// 日付に応じて決定論的に選ばれる本日のコース。
/// Firestore接続後は `dailyChallenges/{dateString}` ドキュメント参照に置き換える想定。
final dailyChallengeCourseProvider = Provider<Course>((ref) {
  final courses = ref.watch(courseListProvider);
  final index = dayOfYear(DateTime.now()) % courses.length;
  return courses[index];
});
