import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traffic_flow_sim/main.dart';

void main() {
  testWidgets('home -> course select -> editor -> simulate -> result flow', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: TrafficFlowSimApp()));
    await tester.pumpAndSettle();

    expect(find.text('渋滞シミュレーター'), findsWidgets);
    expect(find.text('コースを選ぶ'), findsOneWidget);

    await tester.tap(find.text('コースを選ぶ'));
    await tester.pumpAndSettle();

    expect(find.text('コース選択'), findsOneWidget);
    expect(find.text('渋谷スクランブル'), findsOneWidget);
    expect(find.text('池袋東口'), findsOneWidget);
    expect(find.text('新宿南口'), findsOneWidget);

    await tester.tap(find.text('渋谷スクランブル'));
    await tester.pumpAndSettle();

    expect(find.text('車線数: 2'), findsOneWidget);
    expect(find.textContaining('交差点1'), findsOneWidget);

    // Drag the lane slider to change lane count.
    final laneSlider = find.byType(Slider).first;
    await tester.drag(laneSlider, const Offset(200, 0));
    await tester.pumpAndSettle();
    expect(find.text('車線数: 2'), findsNothing);

    // シミュレーション実行ボタンは画面下部にあるためスクロールしてから操作する
    await tester.dragUntilVisible(
      find.text('シミュレーション実行'),
      find.byType(Scrollable),
      const Offset(0, -300),
    );
    await tester.tap(find.text('シミュレーション実行'));
    await tester.pumpAndSettle();

    expect(find.text('スコア (1000点満点)'), findsOneWidget);
    expect(find.text('平均流速'), findsOneWidget);
    expect(find.text('通過台数'), findsOneWidget);

    await tester.ensureVisible(find.text('コース選択に戻る'));
    await tester.tap(find.text('コース選択に戻る'));
    await tester.pumpAndSettle();

    expect(find.text('渋滞シミュレーター'), findsWidgets);
  });
}
