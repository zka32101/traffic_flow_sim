import '../models/course.dart';

/// Firestore未接続時のローカルサンプルコース（実在地名シリーズ Lv1-10）
final List<Course> sampleCourses = [
  Course(
    courseId: 'shibuya_01',
    name: '渋谷スクランブル',
    difficulty: 1,
    city: '渋谷',
    contentVersion: 1,
    baseLayout: const BaseLayout(
      lanes: 2,
      speedLimit: 40,
      intersections: [
        IntersectionConfig(
          position: 150,
          type: IntersectionType.signal,
          greenSeconds: 45,
          redSeconds: 30,
        ),
      ],
    ),
  ),
  Course(
    courseId: 'ikebukuro_01',
    name: '池袋東口',
    difficulty: 2,
    city: '池袋',
    contentVersion: 1,
    baseLayout: const BaseLayout(
      lanes: 3,
      speedLimit: 50,
      intersections: [
        IntersectionConfig(
          position: 120,
          type: IntersectionType.signal,
          greenSeconds: 35,
          redSeconds: 40,
        ),
        IntersectionConfig(
          position: 380,
          type: IntersectionType.signal,
          greenSeconds: 40,
          redSeconds: 35,
        ),
      ],
    ),
  ),
  Course(
    courseId: 'shinjuku_01',
    name: '新宿南口',
    difficulty: 3,
    city: '新宿',
    contentVersion: 1,
    baseLayout: const BaseLayout(
      lanes: 3,
      speedLimit: 50,
      intersections: [
        IntersectionConfig(
          position: 100,
          type: IntersectionType.signal,
          greenSeconds: 30,
          redSeconds: 45,
        ),
        IntersectionConfig(
          position: 350,
          type: IntersectionType.roundabout,
          greenSeconds: 0,
          redSeconds: 0,
        ),
        IntersectionConfig(
          position: 600,
          type: IntersectionType.signal,
          greenSeconds: 25,
          redSeconds: 50,
        ),
      ],
    ),
  ),
  Course(
    courseId: 'roppongi_01',
    name: '六本木交差点',
    difficulty: 4,
    city: '六本木',
    contentVersion: 1,
    baseLayout: const BaseLayout(
      lanes: 3,
      speedLimit: 40,
      intersections: [
        IntersectionConfig(
          position: 100,
          type: IntersectionType.signal,
          greenSeconds: 30,
          redSeconds: 40,
        ),
        IntersectionConfig(
          position: 320,
          type: IntersectionType.stopSign,
          greenSeconds: 0,
          redSeconds: 0,
        ),
      ],
    ),
  ),
  Course(
    courseId: 'shinagawa_01',
    name: '品川駅前',
    difficulty: 5,
    city: '品川',
    contentVersion: 1,
    baseLayout: const BaseLayout(
      lanes: 4,
      speedLimit: 50,
      intersections: [
        IntersectionConfig(
          position: 120,
          type: IntersectionType.signal,
          greenSeconds: 30,
          redSeconds: 45,
        ),
        IntersectionConfig(
          position: 400,
          type: IntersectionType.signal,
          greenSeconds: 35,
          redSeconds: 40,
        ),
      ],
    ),
  ),
  Course(
    courseId: 'shibuya_hachiko_01',
    name: '渋谷ハチ公前',
    difficulty: 6,
    city: '渋谷',
    contentVersion: 1,
    baseLayout: const BaseLayout(
      lanes: 4,
      speedLimit: 40,
      intersections: [
        IntersectionConfig(
          position: 100,
          type: IntersectionType.signal,
          greenSeconds: 25,
          redSeconds: 45,
        ),
        IntersectionConfig(
          position: 320,
          type: IntersectionType.stopSign,
          greenSeconds: 0,
          redSeconds: 0,
        ),
        IntersectionConfig(
          position: 560,
          type: IntersectionType.signal,
          greenSeconds: 25,
          redSeconds: 50,
        ),
      ],
    ),
  ),
  Course(
    courseId: 'tokyo_yaesu_01',
    name: '東京駅八重洲口',
    difficulty: 7,
    city: '東京',
    contentVersion: 1,
    baseLayout: const BaseLayout(
      lanes: 4,
      speedLimit: 50,
      intersections: [
        IntersectionConfig(
          position: 100,
          type: IntersectionType.signal,
          greenSeconds: 25,
          redSeconds: 45,
        ),
        IntersectionConfig(
          position: 350,
          type: IntersectionType.roundabout,
          greenSeconds: 0,
          redSeconds: 0,
        ),
        IntersectionConfig(
          position: 600,
          type: IntersectionType.signal,
          greenSeconds: 20,
          redSeconds: 50,
        ),
      ],
    ),
  ),
  Course(
    courseId: 'akihabara_01',
    name: '秋葉原電気街口',
    difficulty: 8,
    city: '秋葉原',
    contentVersion: 1,
    baseLayout: const BaseLayout(
      lanes: 3,
      speedLimit: 40,
      intersections: [
        IntersectionConfig(
          position: 100,
          type: IntersectionType.signal,
          greenSeconds: 20,
          redSeconds: 50,
        ),
        IntersectionConfig(
          position: 300,
          type: IntersectionType.stopSign,
          greenSeconds: 0,
          redSeconds: 0,
        ),
        IntersectionConfig(
          position: 520,
          type: IntersectionType.signal,
          greenSeconds: 20,
          redSeconds: 55,
        ),
      ],
    ),
  ),
  Course(
    courseId: 'roppongi_hills_01',
    name: '六本木ヒルズ交差点',
    difficulty: 9,
    city: '六本木',
    contentVersion: 1,
    baseLayout: const BaseLayout(
      lanes: 5,
      speedLimit: 50,
      intersections: [
        IntersectionConfig(
          position: 100,
          type: IntersectionType.signal,
          greenSeconds: 20,
          redSeconds: 55,
        ),
        IntersectionConfig(
          position: 320,
          type: IntersectionType.signal,
          greenSeconds: 25,
          redSeconds: 50,
        ),
        IntersectionConfig(
          position: 540,
          type: IntersectionType.roundabout,
          greenSeconds: 0,
          redSeconds: 0,
        ),
        IntersectionConfig(
          position: 760,
          type: IntersectionType.signal,
          greenSeconds: 20,
          redSeconds: 55,
        ),
      ],
    ),
  ),
  Course(
    courseId: 'ginza_4chome_01',
    name: '銀座4丁目交差点',
    difficulty: 10,
    city: '銀座',
    contentVersion: 1,
    baseLayout: const BaseLayout(
      lanes: 5,
      speedLimit: 40,
      intersections: [
        IntersectionConfig(
          position: 100,
          type: IntersectionType.signal,
          greenSeconds: 15,
          redSeconds: 60,
        ),
        IntersectionConfig(
          position: 300,
          type: IntersectionType.stopSign,
          greenSeconds: 0,
          redSeconds: 0,
        ),
        IntersectionConfig(
          position: 520,
          type: IntersectionType.signal,
          greenSeconds: 20,
          redSeconds: 55,
        ),
        IntersectionConfig(
          position: 740,
          type: IntersectionType.signal,
          greenSeconds: 15,
          redSeconds: 60,
        ),
      ],
    ),
  ),
];
