import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traffic_flow_sim/main.dart';
import 'package:traffic_flow_sim/widgets/confetti_burst.dart';

void main() {
  testWidgets('result screen shows confetti for a high score (no congestion)', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: TrafficFlowSimApp()));
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

    expect(find.text('1000'), findsOneWidget);
    expect(find.byType(ConfettiBurst), findsOneWidget);
  });
}
