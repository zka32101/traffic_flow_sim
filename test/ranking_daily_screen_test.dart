import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:traffic_flow_sim/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('ranking screen shows empty state, then a saved record after playing', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: TrafficFlowSimApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('ランキング'));
    await tester.pumpAndSettle();
    expect(find.textContaining('まだ記録がありません'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('コースを選ぶ'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('渋谷スクランブル'));
    await tester.pumpAndSettle();
    await tester.dragUntilVisible(
      find.text('シミュレーション実行'),
      find.byType(Scrollable),
      const Offset(0, -300),
    );
    await tester.tap(find.text('シミュレーション実行'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('記録を保存'));
    await tester.tap(find.text('記録を保存'));
    await tester.pumpAndSettle();
    expect(find.text('保存済み'), findsOneWidget);

    // SnackBar（「記録を保存しました」）がボタンと重なるため、消えるまで待つ
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('コース選択に戻る'));
    await tester.tap(find.text('コース選択に戻る'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('ランキング'));
    await tester.pumpAndSettle();

    expect(find.text('渋谷スクランブル'), findsOneWidget);
    expect(find.textContaining('まだ記録がありません'), findsNothing);
  });

  testWidgets("daily challenge screen shows today's course and streak, navigates to editor", (tester) async {
    await tester.pumpWidget(const ProviderScope(child: TrafficFlowSimApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('デイリーチャレンジ'));
    await tester.pumpAndSettle();

    expect(find.text('本日のチャレンジ'), findsOneWidget);
    expect(find.textContaining('連続'), findsOneWidget);

    await tester.tap(find.text('挑戦する'));
    await tester.pumpAndSettle();

    await tester.dragUntilVisible(
      find.text('シミュレーション実行'),
      find.byType(Scrollable),
      const Offset(0, -300),
    );
    expect(find.text('シミュレーション実行'), findsOneWidget);
  });
}
