import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/course_providers.dart';
import '../widgets/gradient_scaffold.dart';
import 'editor_screen.dart';

class CourseSelectScreen extends ConsumerWidget {
  final bool sillyMode;

  const CourseSelectScreen({super.key, this.sillyMode = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courses = ref.watch(courseListProvider);

    return GradientScaffold(
      appBar: AppBar(
        title: Text(sillyMode ? 'コース選択（わざと渋滞モード）' : 'コース選択'),
        backgroundColor: Colors.transparent,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: courses.length,
        itemBuilder: (context, index) {
          final course = courses[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: CircleAvatar(child: Text('${course.difficulty}')),
              title: Text(course.name),
              subtitle: Text(
                  '${course.city} ・ 車線${course.baseLayout.lanes} ・ 交差点${course.baseLayout.intersections.length}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => EditorScreen(course: course, sillyMode: sillyMode),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
