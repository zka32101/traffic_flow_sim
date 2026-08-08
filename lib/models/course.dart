enum IntersectionType { signal, roundabout, stopSign }

class IntersectionConfig {
  final int position; // meters from corridor start
  final IntersectionType type;
  final int greenSeconds; // 0-120
  final int redSeconds; // 0-120

  const IntersectionConfig({
    required this.position,
    required this.type,
    required this.greenSeconds,
    required this.redSeconds,
  });

  int get cycleSeconds => greenSeconds + redSeconds;

  factory IntersectionConfig.fromMap(Map<String, dynamic> map) {
    return IntersectionConfig(
      position: map['position'] as int,
      type: IntersectionType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => IntersectionType.signal,
      ),
      greenSeconds: map['greenSeconds'] as int? ?? 30,
      redSeconds: map['redSeconds'] as int? ?? 30,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'position': position,
      'type': type.name,
      'greenSeconds': greenSeconds,
      'redSeconds': redSeconds,
    };
  }
}

class BaseLayout {
  final int lanes; // 1-6
  final List<IntersectionConfig> intersections;
  final int speedLimit; // km/h

  const BaseLayout({
    required this.lanes,
    required this.intersections,
    required this.speedLimit,
  });

  factory BaseLayout.fromMap(Map<String, dynamic> map) {
    return BaseLayout(
      lanes: map['lanes'] as int,
      intersections: (map['intersections'] as List<dynamic>)
          .map((e) => IntersectionConfig.fromMap(e as Map<String, dynamic>))
          .toList(),
      speedLimit: map['speedLimit'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'lanes': lanes,
      'intersections': intersections.map((e) => e.toMap()).toList(),
      'speedLimit': speedLimit,
    };
  }

  BaseLayout copyWith({
    int? lanes,
    List<IntersectionConfig>? intersections,
    int? speedLimit,
  }) {
    return BaseLayout(
      lanes: lanes ?? this.lanes,
      intersections: intersections ?? this.intersections,
      speedLimit: speedLimit ?? this.speedLimit,
    );
  }
}

class Course {
  final String courseId;
  final String name;
  final int difficulty; // 1-10
  final String city;
  final BaseLayout baseLayout;
  final int contentVersion;

  const Course({
    required this.courseId,
    required this.name,
    required this.difficulty,
    required this.city,
    required this.baseLayout,
    required this.contentVersion,
  });

  factory Course.fromMap(String id, Map<String, dynamic> map) {
    return Course(
      courseId: id,
      name: map['name'] as String,
      difficulty: map['difficulty'] as int,
      city: map['city'] as String,
      baseLayout: BaseLayout.fromMap(map['baseLayout'] as Map<String, dynamic>),
      contentVersion: map['contentVersion'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'difficulty': difficulty,
      'city': city,
      'baseLayout': baseLayout.toMap(),
      'contentVersion': contentVersion,
    };
  }
}
