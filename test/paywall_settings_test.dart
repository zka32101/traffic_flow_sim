import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:traffic_flow_sim/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('non-premium user is routed to paywall when tapping silly mode', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: TrafficFlowSimApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('わざと渋滞モード 🔒'));
    await tester.pumpAndSettle();

    expect(find.text('プレミアムにアップグレード'), findsOneWidget);
    expect(find.text('¥600（買い切り）'), findsOneWidget);
  });

  testWidgets('dev unlock button sets premium and unlocks silly mode from home', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: TrafficFlowSimApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('わざと渋滞モード 🔒'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('購入する（開発用）'));
    await tester.pumpAndSettle();

    // ペイウォールから戻り、ボタンのラベルから鍵アイコンが消える
    expect(find.text('わざと渋滞モード'), findsOneWidget);
    expect(find.text('わざと渋滞モード 🔒'), findsNothing);
  });

  testWidgets('settings screen changes theme mode', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: TrafficFlowSimApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();

    expect(find.text('外観'), findsOneWidget);
    await tester.tap(find.text('ダーク'));
    await tester.pumpAndSettle();

    final BuildContext context = tester.element(find.byType(Scaffold).first);
    expect(Theme.of(context).brightness, Brightness.dark);
  });

  testWidgets('settings screen toggles haptics', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: TrafficFlowSimApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();

    final switchFinder = find.byType(Switch);
    expect(switchFinder, findsOneWidget);

    final before = tester.widget<Switch>(switchFinder).value;
    await tester.tap(switchFinder);
    await tester.pumpAndSettle();
    final after = tester.widget<Switch>(switchFinder).value;

    expect(after, !before);
  });
}
