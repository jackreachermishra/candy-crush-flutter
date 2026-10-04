import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local progress and small cosmetic rewards. Device clock and preferences are
/// user controlled, so these rewards are intentionally not tamper resistant.
class GameProgress extends ChangeNotifier {
  GameProgress._({DateTime Function()? clock}) : _clock = clock ?? DateTime.now;
  static final instance = GameProgress._();

  @visibleForTesting
  GameProgress.forTesting({DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  static const _unlockedKey = 'prismleaf_unlocked_level';
  static const _completedKey = 'prismleaf_completed_level';
  static const _soundKey = 'prismleaf_sound_enabled';
  static const _hapticsKey = 'prismleaf_haptics_enabled';
  static const _lastClaimKey = 'prismleaf_last_daily_claim';
  static const _streakKey = 'prismleaf_daily_streak';
  static const _glowKey = 'prismleaf_glow';
  static const _winsKey = 'prismleaf_total_wins';
  static const _bestKey = 'prismleaf_best_scores';
  static const _twilightKey = 'prismleaf_twilight_unlocked';
  static const _themeKey = 'prismleaf_selected_theme';

  final DateTime Function() _clock;
  SharedPreferences? _preferences;
  int unlockedLevel = 1;
  int highestCompletedLevel = 0;
  int glow = 0;
  int dailyStreak = 0;
  int totalWins = 0;
  bool soundEnabled = true;
  bool hapticsEnabled = true;
  bool twilightUnlocked = false;
  String selectedTheme = 'forest';
  String? _lastClaimDay;
  final Map<int, int> bestScores = {};

  String _dayKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  int? _dayNumber(String? key) {
    if (key == null) return null;
    final date = DateTime.tryParse(key);
    if (date == null) return null;
    return DateTime.utc(
      date.year,
      date.month,
      date.day,
    ).difference(DateTime.utc(1970)).inDays;
  }

  bool get canClaimDaily {
    final previous = _dayNumber(_lastClaimDay);
    final today = _dayNumber(_dayKey(_clock()))!;
    return previous == null || today > previous;
  }

  int get currentStreak {
    final previous = _dayNumber(_lastClaimDay);
    if (previous == null) return 0;
    final gap = _dayNumber(_dayKey(_clock()))! - previous;
    return gap >= 0 && gap <= 1 ? dailyStreak : 0;
  }

  int get bestTotalScore =>
      bestScores.values.fold(0, (sum, score) => sum + score);

  Future<void> load() async {
    _preferences = await SharedPreferences.getInstance();
    unlockedLevel = (_preferences?.getInt(_unlockedKey) ?? 1).clamp(1, 999);
    highestCompletedLevel =
        (_preferences?.getInt(_completedKey) ?? unlockedLevel - 1).clamp(
          0,
          999,
        );
    soundEnabled = _preferences?.getBool(_soundKey) ?? true;
    hapticsEnabled = _preferences?.getBool(_hapticsKey) ?? true;
    glow = (_preferences?.getInt(_glowKey) ?? 0).clamp(0, 1000000000);
    dailyStreak = (_preferences?.getInt(_streakKey) ?? 0).clamp(0, 1000000);
    totalWins = (_preferences?.getInt(_winsKey) ?? 0).clamp(0, 1000000000);
    _lastClaimDay = _preferences?.getString(_lastClaimKey);
    twilightUnlocked = _preferences?.getBool(_twilightKey) ?? false;
    selectedTheme =
        _preferences?.getString(_themeKey) == 'twilight' && twilightUnlocked
        ? 'twilight'
        : 'forest';
    bestScores.clear();
    try {
      final saved = jsonDecode(
        _preferences?.getString(_bestKey) ?? '{}',
      ) as Map<String, dynamic>;
      for (final entry in saved.entries) {
        final level = int.tryParse(entry.key);
        if (level != null && entry.value is int && entry.value >= 0) {
          bestScores[level] = entry.value as int;
        }
      }
    } catch (_) {
      // Corrupt optional stats do not prevent loading the game.
    }
    notifyListeners();
  }

  Future<int> claimDaily() async {
    if (!canClaimDaily) return 0;
    final today = _dayKey(_clock());
    final previous = _dayNumber(_lastClaimDay);
    final gap = previous == null ? null : _dayNumber(today)! - previous;
    dailyStreak = gap == 1 ? dailyStreak + 1 : 1;
    final reward = 20 + (dailyStreak.clamp(1, 7) - 1) * 5;
    glow += reward;
    _lastClaimDay = today;
    notifyListeners();
    await Future.wait([
      _preferences!.setString(_lastClaimKey, today),
      _preferences!.setInt(_streakKey, dailyStreak),
      _preferences!.setInt(_glowKey, glow),
    ]);
    return reward;
  }

  /// Completing a glade grants glow. Unique milestones grant an extra bonus.
  Future<int> complete(
    int level,
    int totalLevels, {
    int score = 0,
    int movesLeft = 0,
  }) async {
    final firstClear = level > highestCompletedLevel;
    final next = (level + 1).clamp(1, totalLevels);
    if (firstClear) highestCompletedLevel = level;
    if (next > unlockedLevel) unlockedLevel = next;
    totalWins++;
    if (score > (bestScores[level] ?? 0)) bestScores[level] = score;
    final bonus =
        20 +
        movesLeft.clamp(0, 20) * 2 +
        (firstClear ? 30 : 0) +
        (firstClear && level % 3 == 0 ? 50 : 0);
    glow += bonus;
    notifyListeners();
    await Future.wait([
      _preferences!.setInt(_unlockedKey, unlockedLevel),
      _preferences!.setInt(_completedKey, highestCompletedLevel),
      _preferences!.setInt(_winsKey, totalWins),
      _preferences!.setInt(_glowKey, glow),
      _preferences!.setString(
        _bestKey,
        jsonEncode(bestScores.map((key, value) => MapEntry('$key', value))),
      ),
    ]);
    return bonus;
  }

  Future<bool> unlockTwilight() async {
    if (twilightUnlocked || glow < 100) return false;
    glow -= 100;
    twilightUnlocked = true;
    selectedTheme = 'twilight';
    notifyListeners();
    await Future.wait([
      _preferences!.setInt(_glowKey, glow),
      _preferences!.setBool(_twilightKey, true),
      _preferences!.setString(_themeKey, selectedTheme),
    ]);
    return true;
  }

  Future<void> selectTheme(String theme) async {
    if (theme != 'forest' && (theme != 'twilight' || !twilightUnlocked)) {
      return;
    }
    selectedTheme = theme;
    notifyListeners();
    await _preferences?.setString(_themeKey, theme);
  }

  Future<void> setSoundEnabled(bool value) async {
    soundEnabled = value;
    notifyListeners();
    await _preferences?.setBool(_soundKey, value);
  }

  Future<void> setHapticsEnabled(bool value) async {
    hapticsEnabled = value;
    notifyListeners();
    await _preferences?.setBool(_hapticsKey, value);
  }

  void refreshForNewDay() => notifyListeners();
}
