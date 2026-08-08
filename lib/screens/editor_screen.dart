import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/course.dart';
import '../providers/editor_providers.dart';
import '../widgets/bouncy_button.dart';
import '../widgets/gradient_scaffold.dart';
import '../widgets/road_scene.dart';
import '../widgets/signal_preview.dart';
import 'result_screen.dart';

class EditorScreen extends ConsumerWidget {
  final Course course;
  final bool sillyMode;

  const EditorScreen({super.key, required this.course, this.sillyMode = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final layout = ref.watch(editorProvider(course));
    final notifier = ref.read(editorProvider(course).notifier);

    return GradientScaffold(
      appBar: AppBar(title: Text(course.name), backgroundColor: Colors.transparent),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (sillyMode)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Card(
                color: Colors.deepOrange.withValues(alpha: 0.1),
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    '🚧 わざと渋滞モード: できるだけ早く渋滞を起こそう！',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 180,
              child: RoadScene(layout: layout),
            ),
          ),
          const SizedBox(height: 16),
          Text('車線数: ${layout.lanes}', style: const TextStyle(fontSize: 16)),
          Slider(
            value: layout.lanes.toDouble(),
            min: 1,
            max: 6,
            divisions: 5,
            label: '${layout.lanes}',
            onChanged: (v) => notifier.setLanes(v.round()),
          ),
          const Divider(height: 32),
          for (var i = 0; i < layout.intersections.length; i++)
            _IntersectionEditor(
              index: i,
              intersection: layout.intersections[i],
              onChanged: (green, red) =>
                  notifier.updateIntersection(i, greenSeconds: green, redSeconds: red),
            ),
          const SizedBox(height: 24),
          Center(
            child: BouncyButton(
              label: 'シミュレーション実行',
              icon: Icons.play_arrow,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ResultScreen(course: course, sillyMode: sillyMode),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _IntersectionEditor extends StatelessWidget {
  final int index;
  final IntersectionConfig intersection;
  final void Function(int green, int red) onChanged;

  const _IntersectionEditor({
    required this.index,
    required this.intersection,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final typeLabel = switch (intersection.type) {
      IntersectionType.signal => '信号',
      IntersectionType.roundabout => 'ラウンドアバウト',
      IntersectionType.stopSign => '一時停止',
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('交差点${index + 1} ($typeLabel)', style: const TextStyle(fontWeight: FontWeight.bold)),
            if (intersection.type == IntersectionType.signal) ...[
              const SizedBox(height: 8),
              SignalPreview(greenSeconds: intersection.greenSeconds, redSeconds: intersection.redSeconds),
              const SizedBox(height: 8),
              Text('青信号: ${intersection.greenSeconds}秒'),
              Slider(
                value: intersection.greenSeconds.toDouble(),
                min: 0,
                max: 120,
                divisions: 24,
                onChanged: (v) => onChanged(v.round(), intersection.redSeconds),
              ),
              Text('赤信号: ${intersection.redSeconds}秒'),
              Slider(
                value: intersection.redSeconds.toDouble(),
                min: 0,
                max: 120,
                divisions: 24,
                onChanged: (v) => onChanged(intersection.greenSeconds, v.round()),
              ),
            ] else
              const Text('信号タイミングの設定はありません'),
          ],
        ),
      ),
    );
  }
}
