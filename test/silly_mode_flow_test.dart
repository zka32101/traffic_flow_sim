import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traffic_flow_sim/main.dart';
import 'package:traffic_flow_sim/models/user_profile.dart';
import 'package:traffic_flow_sim/providers/score_providers.dart';

void main() {
  testWidgets('home -> silly mode course select -> editor -> result shows silly score (premium)',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userProfileProvider.overrideWith(
            (ref) async => const UserProfile(userId: 'test', displayName: 'テスト', isPremium: true),
          ),
        ],
        child: const TrafficFlowSimApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('わざと渋滞モード'));
    await tester.pumpAndSettle();

    expect(find.text('コース選択（わざと渋滞モード）'), findsOneWidget);

    await tester.tap(find.text('渋谷スクランブル'));
    await tester.pumpAndSettle();

    expect(find.textContaining('できるだけ早く渋滞を起こそう'), findsOneWidget);

    await tester.dragUntilVisible(
      find.text('シミュレーション実行'),
      find.byType(Scrollable),
      const Offset(0, -300),
    );
    await tester.tap(find.text('シミュレーション実行'));
    await tester.pumpAndSettle();

    expect(find.text('渋谷スクランブル - わざと渋滞 結果'), findsOneWidget);
    expect(find.text('渋滞達成スコア (1000点満点)'), findsOneWidget);
  });
}
