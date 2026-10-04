import 'package:flutter_test/flutter_test.dart';
import 'package:prismleaf_vale/ads/ad_config.dart';
import 'package:prismleaf_vale/ads/reward_attempt.dart';
import 'package:prismleaf_vale/brand/progress.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'daily reward cannot be claimed twice and streak survives restart',
    () async {
      SharedPreferences.setMockInitialValues({});
      var now = DateTime(2026, 10, 4, 10);
      var progress = GameProgress.forTesting(clock: () => now);
      await progress.load();
      expect(await progress.claimDaily(), 20);
      expect(await progress.claimDaily(), 0);
      expect(progress.dailyStreak, 1);
      now = DateTime(2026, 10, 5, 9);
      progress = GameProgress.forTesting(clock: () => now);
      await progress.load();
      expect(await progress.claimDaily(), 25);
      expect(progress.dailyStreak, 2);
      expect(progress.glow, 45);
      now = DateTime(2026, 10, 4, 9);
      expect(await progress.claimDaily(), 0);
      now = DateTime(2026, 10, 8, 9);
      expect(progress.currentStreak, 0);
      expect(await progress.claimDaily(), 20);
      expect(progress.dailyStreak, 1);
    },
  );

  test('completion persists best score and cosmetic unlock', () async {
    SharedPreferences.setMockInitialValues({});
    var progress = GameProgress.forTesting();
    await progress.load();
    expect(await progress.complete(1, 5, score: 230, movesLeft: 4), 58);
    expect(await progress.complete(1, 5, score: 120), 20);
    expect(await progress.complete(2, 5, score: 300), 50);
    expect(progress.totalWins, 3);
    expect(progress.bestScores[1], 230);
    expect(await progress.unlockTwilight(), isTrue);
    progress = GameProgress.forTesting();
    await progress.load();
    expect(progress.unlockedLevel, 3);
    expect(progress.highestCompletedLevel, 2);
    expect(progress.bestScores[1], 230);
    expect(progress.twilightUnlocked, isTrue);
    expect(progress.selectedTheme, 'twilight');
    expect(progress.glow, 28);
    await progress.setHapticsEnabled(false);
    progress = GameProgress.forTesting();
    await progress.load();
    expect(progress.hapticsEnabled, isFalse);
  });

  test('reward gate opens only after earned callback', () {
    expect(RewardAttempt().finish(), isFalse);
    final earned = RewardAttempt()..markEarned();
    expect(earned.finish(), isTrue);
    expect(earned.finish(), isFalse);
    final lateReward = RewardAttempt();
    expect(lateReward.finish(), isFalse);
    lateReward.markEarned();
    expect(lateReward.finish(), isFalse);
  });

  test('development builds use official sample ad units', () {
    expect(AdConfig.bannerUnitId, 'ca-app-pub-3940256099942544/9214589741');
    expect(AdConfig.rewardedUnitId, 'ca-app-pub-3940256099942544/5224354917');
  });
}
