class UserProfile {
  final String userId;
  final String displayName;
  final int bestScore;
  final int dailyStreak;
  final DateTime? lastPlayedAt;
  final bool isPremium;

  const UserProfile({
    required this.userId,
    required this.displayName,
    this.bestScore = 0,
    this.dailyStreak = 0,
    this.lastPlayedAt,
    this.isPremium = false,
  });

  factory UserProfile.fromMap(String id, Map<String, dynamic> map) {
    return UserProfile(
      userId: id,
      displayName: map['displayName'] as String? ?? 'プレイヤー',
      bestScore: map['bestScore'] as int? ?? 0,
      dailyStreak: map['dailyStreak'] as int? ?? 0,
      lastPlayedAt: map['lastPlayedAtMs'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['lastPlayedAtMs'] as int)
          : null,
      isPremium: map['isPremium'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'displayName': displayName,
      'bestScore': bestScore,
      'dailyStreak': dailyStreak,
      'lastPlayedAtMs': lastPlayedAt?.millisecondsSinceEpoch,
      'isPremium': isPremium,
    };
  }

  UserProfile copyWith({
    String? displayName,
    int? bestScore,
    int? dailyStreak,
    DateTime? lastPlayedAt,
    bool? isPremium,
  }) {
    return UserProfile(
      userId: userId,
      displayName: displayName ?? this.displayName,
      bestScore: bestScore ?? this.bestScore,
      dailyStreak: dailyStreak ?? this.dailyStreak,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
      isPremium: isPremium ?? this.isPremium,
    );
  }

  /// ストリーク更新: 前回プレイが「昨日」なら+1、「今日」なら維持、それ以外はリセット
  UserProfile withStreakUpdate(DateTime playedAt) {
    if (lastPlayedAt == null) {
      return copyWith(dailyStreak: 1, lastPlayedAt: playedAt);
    }
    final lastDay = DateTime(lastPlayedAt!.year, lastPlayedAt!.month, lastPlayedAt!.day);
    final playedDay = DateTime(playedAt.year, playedAt.month, playedAt.day);
    final diff = playedDay.difference(lastDay).inDays;

    if (diff == 0) {
      return copyWith(lastPlayedAt: playedAt);
    } else if (diff == 1) {
      return copyWith(dailyStreak: dailyStreak + 1, lastPlayedAt: playedAt);
    } else {
      return copyWith(dailyStreak: 1, lastPlayedAt: playedAt);
    }
  }
}
