import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/score_providers.dart';
import '../widgets/bouncy_button.dart';
import '../widgets/gradient_scaffold.dart';
import 'course_select_screen.dart';
import 'daily_challenge_screen.dart';
import 'paywall_screen.dart';
import 'ranking_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    final isPremium = profileAsync.valueOrNull?.isPremium ?? false;

    return GradientScaffold(
      appBar: AppBar(
        title: const Text('渋滞シミュレーター'),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: '設定',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '信号・車線を設計して渋滞をゼロに',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 24),
            BouncyButton(
              label: 'コースを選ぶ',
              icon: Icons.directions_car,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CourseSelectScreen()),
                );
              },
            ),
            const SizedBox(height: 12),
            BouncyButton(
              label: isPremium ? 'わざと渋滞モード' : 'わざと渋滞モード 🔒',
              icon: Icons.traffic,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => isPremium
                        ? const CourseSelectScreen(sillyMode: true)
                        : const PaywallScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            BouncyButton(
              label: 'デイリーチャレンジ',
              icon: Icons.today,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const DailyChallengeScreen()),
                );
              },
            ),
            const SizedBox(height: 12),
            BouncyButton(
              label: 'ランキング',
              icon: Icons.leaderboard,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const RankingScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
