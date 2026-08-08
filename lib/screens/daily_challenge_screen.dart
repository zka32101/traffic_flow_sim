import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/course_providers.dart';
import '../providers/score_providers.dart';
import '../widgets/bouncy_button.dart';
import '../widgets/gradient_scaffold.dart';
import 'editor_screen.dart';

class DailyChallengeScreen extends ConsumerWidget {
  const DailyChallengeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final course = ref.watch(dailyChallengeCourseProvider);
    final profileAsync = ref.watch(userProfileProvider);

    return GradientScaffold(
      appBar: AppBar(title: const Text('デイリーチャレンジ'), backgroundColor: Colors.transparent),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.today, size: 48),
              const SizedBox(height: 12),
              const Text('本日のチャレンジ', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              Text(
                course.name,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text('${course.city} ・ 難易度 ${course.difficulty}'),
              const SizedBox(height: 24),
              profileAsync.when(
                loading: () => const CircularProgressIndicator(),
                error: (err, stack) => const SizedBox.shrink(),
                data: (profile) => Chip(
                  avatar: const Icon(Icons.local_fire_department, color: Colors.orange),
                  label: Text('連続 ${profile.dailyStreak} 日'),
                ),
              ),
              const SizedBox(height: 24),
              BouncyButton(
                label: '挑戦する',
                icon: Icons.play_arrow,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => EditorScreen(course: course)),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
