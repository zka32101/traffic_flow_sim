import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/score.dart';
import '../models/user_profile.dart';
import '../services/local_profile_store.dart';
import '../services/local_score_store.dart';

final localScoreStoreProvider = Provider<LocalScoreStore>((ref) => LocalScoreStore());
final localProfileStoreProvider = Provider<LocalProfileStore>((ref) => LocalProfileStore());

final scoreHistoryProvider = FutureProvider<List<ScoreRecord>>((ref) {
  return ref.watch(localScoreStoreProvider).bestPerCourse();
});

final userProfileProvider = FutureProvider<UserProfile>((ref) {
  return ref.watch(localProfileStoreProvider).load();
});
