import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/course_providers.dart';
import '../providers/score_providers.dart';
import '../widgets/gradient_scaffold.dart';

/// 自己ベスト一覧（コース別）。
/// Firestore接続後はグローバルランキングに置き換える想定で、
/// scoreHistoryProvider/localScoreStoreProvider のインターフェースはそのまま流用できる。
class RankingScreen extends ConsumerWidget {
  const RankingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(scoreHistoryProvider);
    final courses = ref.watch(courseListProvider);
    final courseNameOf = {for (final c in courses) c.courseId: c.name};

    return GradientScaffold(
      appBar: AppBar(title: const Text('ランキング（自己ベスト）'), backgroundColor: Colors.transparent),
      body: historyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('読み込みに失敗しました: $err')),
        data: (records) {
          if (records.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'まだ記録がありません。\nコースをクリアして記録を保存しよう！',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: records.length,
            itemBuilder: (context, index) {
              final record = records[index];
              final courseName = courseNameOf[record.courseId] ?? record.courseId;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: index == 0 ? Colors.amber : null,
                    child: Text('${index + 1}'),
                  ),
                  title: Text(courseName),
                  subtitle: Text(DateFormat('yyyy/MM/dd HH:mm').format(record.timestamp)),
                  trailing: Text(
                    '${record.score}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
