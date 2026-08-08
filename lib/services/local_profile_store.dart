import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_profile.dart';

/// プロフィール（ストリーク等）のローカル永続化。
/// Firestore接続後は同じインターフェースでリモートストアに差し替える想定。
class LocalProfileStore {
  static const _key = 'traffic_flow_sim.profile.v1';
  static const localUserId = 'local_user';

  Future<UserProfile> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) {
      return const UserProfile(userId: localUserId, displayName: 'プレイヤー');
    }
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return UserProfile.fromMap(localUserId, map);
  }

  Future<UserProfile> recordPlay(DateTime playedAt) async {
    final current = await load();
    final updated = current.withStreakUpdate(playedAt);
    await _save(updated);
    return updated;
  }

  /// 購入状態を更新する。RevenueCat接続後はWebhook/エンタイトルメント同期に置き換える想定。
  Future<UserProfile> setPremium(bool isPremium) async {
    final current = await load();
    final updated = current.copyWith(isPremium: isPremium);
    await _save(updated);
    return updated;
  }

  Future<void> _save(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(profile.toMap()));
  }
}
