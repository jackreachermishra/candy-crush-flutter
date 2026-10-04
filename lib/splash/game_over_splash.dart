import 'package:flutter/material.dart';

import '../ads/ads_service.dart';
import '../brand/brand_theme.dart';
import '../model/level.dart';

class GameOverSplash extends StatelessWidget {
  const GameOverSplash({
    super.key,
    required this.success,
    required this.level,
    required this.onExit,
    required this.onRetry,
    this.onNext,
    this.onContinue,
    this.score = 0,
    this.glowEarned = 0,
  });
  final Level level;
  final bool success;
  final VoidCallback onExit;
  final VoidCallback onRetry;
  final VoidCallback? onNext;
  final VoidCallback? onContinue;
  final int score;
  final int glowEarned;

  @override
  Widget build(BuildContext context) => Positioned.fill(
    child: Material(
      color: Brand.ink.withValues(alpha: 0.9),
      child: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 370),
              child: ValeCard(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      success ? Icons.auto_awesome_rounded : Icons.spa_rounded,
                      color: success ? Brand.gold : Brand.warning,
                      size: 52,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      success ? 'Glade restored!' : 'Almost there',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      success
                          ? 'Your matches lit Glade ${level.index}.'
                          : 'Try another route through Glade ${level.index}.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text('Score: $score'),
                    if (success) Text('+$glowEarned glow'),
                    const SizedBox(height: 24),
                    if (!success && onContinue != null) ...[
                      AnimatedBuilder(
                        animation: AdsService.instance,
                        builder: (context, _) => Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                onPressed: AdsService.instance.rewardedReady
                                    ? onContinue
                                    : null,
                                icon: const Icon(Icons.play_circle_outline),
                                label: Text(
                                  AdsService.instance.rewardedReady
                                      ? 'Watch an ad for 3 moves'
                                      : 'Ad unavailable',
                                ),
                              ),
                            ),
                            if (AdsService.instance.ready &&
                                !AdsService.instance.rewardedReady &&
                                !AdsService.instance.rewardedLoading)
                              TextButton(
                                onPressed: AdsService.instance.loadRewarded,
                                child: const Text('Retry ad'),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (success && onNext != null) ...[
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: onNext,
                          child: const Text('Next glade'),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: onRetry,
                        child: const Text('Play again'),
                      ),
                    ),
                    TextButton(
                      onPressed: onExit,
                      child: const Text('Trail map'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
