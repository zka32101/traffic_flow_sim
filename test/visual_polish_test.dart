import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traffic_flow_sim/main.dart';
import 'package:traffic_flow_sim/widgets/bouncy_button.dart';

void main() {
  testWidgets('BouncyButton ignores rapid repeated taps within cooldown', (tester) async {
    var tapCount = 0;
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: BouncyButton(label: 'テスト', onPressed: () => tapCount++),
          ),
        ),
      ),
    );

    await tester.tap(find.text('テスト'));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(find.text('テスト'));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(find.text('テスト'));

    expect(tapCount, 1);

    // クールダウン経過後は再度反応する
    await tester.pump(const Duration(milliseconds: 600));
    await tester.tap(find.text('テスト'));
    await tester.pump(const Duration(milliseconds: 50));

    expect(tapCount, 2);
  });

  testWidgets('app renders without error in dark mode', (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 800));
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

    await tester.pumpWidget(const ProviderScope(child: TrafficFlowSimApp()));
    await tester.pumpAndSettle();

    final BuildContext context = tester.element(find.byType(Scaffold).first);
    expect(Theme.of(context).brightness, Brightness.dark);
    expect(find.text('コースを選ぶ'), findsOneWidget);
  });
}
