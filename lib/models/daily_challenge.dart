class DailyChallenge {
  final String dateString; // YYYY-MM-DD
  final String courseId;
  final String? theme;

  const DailyChallenge({
    required this.dateString,
    required this.courseId,
    this.theme,
  });

  factory DailyChallenge.fromMap(String id, Map<String, dynamic> map) {
    return DailyChallenge(
      dateString: id,
      courseId: map['courseId'] as String,
      theme: map['theme'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'courseId': courseId,
      if (theme != null) 'theme': theme,
    };
  }
}
