import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/course.dart';
import '../services/simulation_engine.dart';

class EditorNotifier extends StateNotifier<BaseLayout> {
  EditorNotifier(super.initial);

  void setLanes(int lanes) {
    state = state.copyWith(lanes: lanes.clamp(1, 6));
  }

  void updateIntersection(int index, {int? greenSeconds, int? redSeconds}) {
    final list = [...state.intersections];
    final old = list[index];
    list[index] = IntersectionConfig(
      position: old.position,
      type: old.type,
      greenSeconds: (greenSeconds ?? old.greenSeconds).clamp(0, 120),
      redSeconds: (redSeconds ?? old.redSeconds).clamp(0, 120),
    );
    state = state.copyWith(intersections: list);
  }

  void reset(BaseLayout original) {
    state = original;
  }
}

/// コースごとの編集中レイアウト。Course インスタンスをキーにする
/// （sampleCourses は起動時に一度だけ生成され同一インスタンスが使い回されるため
/// family のデフォルト等価性（identity）で安全にキャッシュできる）。
final editorProvider = StateNotifierProvider.family<EditorNotifier, BaseLayout, Course>(
  (ref, course) => EditorNotifier(course.baseLayout),
);

final simulationResultProvider = Provider.family<SimulationResult, Course>((ref, course) {
  final layout = ref.watch(editorProvider(course));
  final settings = SimulationSettings.fromDifficulty(course.difficulty);
  return SimulationEngine.run(layout, settings);
});
