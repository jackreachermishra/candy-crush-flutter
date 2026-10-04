/// Captures the only event that can authorize an in-game ad reward.
class RewardAttempt {
  bool _earned = false;
  bool _finished = false;

  void markEarned() {
    if (!_finished) _earned = true;
  }

  bool finish() {
    if (_finished) return false;
    _finished = true;
    return _earned;
  }
}
