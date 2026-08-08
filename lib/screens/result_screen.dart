import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/course.dart';
import '../models/score.dart';
import '../providers/editor_providers.dart';
import '../providers/score_providers.dart';
import '../services/simulation_engine.dart';
import '../widgets/bouncy_button.dart';
import '../widgets/confetti_burst.dart';
import '../widgets/gradient_scaffold.dart';
import '../widgets/road_scene.dart';

class ResultScreen extends ConsumerStatefulWidget {
  final Course course;
  final bool sillyMode;

  const ResultScreen({super.key, required this.course, this.sillyMode = false});

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> {
  bool _saved = false;
  bool _saving = false;

  Color _scoreColor(BuildContext context, int score) {
    if (score >= 800) return Colors.green.shade600;
    if (score >= 500) return Colors.amber.shade700;
    return Colors.red.shade600;
  }

  Future<void> _saveRecord(int score, SimulationResult result) async {
    setState(() => _saving = true);
    final record = ScoreRecord(
      scoreId: const Uuid().v4(),
      courseId: widget.course.courseId,
      score: score,
      timestamp: DateTime.now(),
      simulationData: SimulationData(
        congestionTimeMs: result.congestionTimeMs,
        avgSpeed: result.avgSpeed,
        completedVehicles: result.completedVehicles,
      ),
    );
    await ref.read(localScoreStoreProvider).add(record);
    await ref.read(localProfileStoreProvider).recordPlay(DateTime.now());
    ref.invalidate(scoreHistoryProvider);
    ref.invalidate(userProfileProvider);

    if (!mounted) return;
    setState(() {
      _saved = true;
      _saving = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('記録を保存しました')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final course = widget.course;
    final sillyMode = widget.sillyMode;
    final layout = ref.watch(editorProvider(course));
    final result = ref.watch(simulationResultProvider(course));
    final congestionSeconds = (result.congestionTimeMs / 1000).toStringAsFixed(0);
    final timeToCongestionSeconds =
        result.timeToCongestionMs != null ? (result.timeToCongestionMs! / 1000).toStringAsFixed(0) : null;
    final displayScore = sillyMode ? result.sillyScore : result.score;
    final scoreColor = _scoreColor(context, displayScore);

    return GradientScaffold(
      appBar: AppBar(
        title: Text('${course.name} - ${sillyMode ? 'わざと渋滞 結果' : '結果'}'),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: 180,
                child: RoadScene(
                  layout: layout,
                  animate: true,
                  isCongested: result.isCongested,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                Center(
                  child: Column(
                    children: [
                      TweenAnimationBuilder<int>(
                        tween: IntTween(begin: 0, end: displayScore),
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, child) {
                          return Text(
                            '$value',
                            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: scoreColor,
                                ),
                          );
                        },
                      ),
                      Text(sillyMode ? '渋滞達成スコア (1000点満点)' : 'スコア (1000点満点)'),
                    ],
                  ),
                ).animate().fadeIn(duration: 300.ms).scale(begin: const Offset(0.9, 0.9)),
                if (displayScore >= 800)
                  SizedBox(
                    height: 110,
                    width: double.infinity,
                    child: const ConfettiBurst(),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            Card(
              color: scoreColor.withValues(alpha: 0.08),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: scoreColor.withValues(alpha: 0.4)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    if (sillyMode)
                      _ResultRow(
                        label: result.isCongested ? '渋滞達成' : '渋滞できず',
                        value: result.isCongested ? '🎉 $timeToCongestionSeconds秒' : '😅 未達成',
                      )
                    else
                      _ResultRow(
                        label: result.isCongested ? '渋滞発生' : '渋滞なし',
                        value: result.isCongested ? '⚠️ $congestionSeconds秒' : '✅ 0秒',
                      ),
                    _ResultRow(
                      label: '平均流速',
                      value: '${result.avgSpeed.toStringAsFixed(1)} km/h',
                    ),
                    _ResultRow(
                      label: '通過台数',
                      value: '${result.completedVehicles} 台',
                    ),
                  ],
                ),
              ),
            ).animate(delay: 150.ms).fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0),
            const SizedBox(height: 24),
            if (!sillyMode) ...[
              Center(
                child: _saved
                    ? const Chip(
                        avatar: Icon(Icons.check, size: 18),
                        label: Text('保存済み'),
                      )
                    : BouncyButton(
                        label: _saving ? '保存中...' : '記録を保存',
                        icon: Icons.save,
                        onPressed: _saving ? () {} : () => _saveRecord(result.score, result),
                      ),
              ),
              const SizedBox(height: 12),
            ],
            Center(
              child: BouncyButton(
                label: '設定を見直してみる',
                icon: Icons.tune,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
              child: const Text('コース選択に戻る'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final String label;
  final String value;

  const _ResultRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
