import 'package:flutter/material.dart';

import '../brand/brand_theme.dart';
import '../model/audio.dart';
import '../model/level.dart';
import '../panel/objective/components/objective_item.dart';

class GameSplash extends StatelessWidget {
  const GameSplash({super.key, required this.level, this.onComplete});
  final Level level;
  final VoidCallback? onComplete;

  @override
  Widget build(BuildContext context) => Positioned.fill(
    child: Material(
      color: Brand.ink.withValues(alpha: 0.86),
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
                    const Icon(
                      Icons.auto_awesome_rounded,
                      color: Brand.gold,
                      size: 42,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Glade ${level.index}',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Gather the light',
                      style: TextStyle(color: Brand.mint),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Swipe neighboring leaves to match three. Tap a special piece to use it.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 18),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 20,
                      runSpacing: 12,
                      children: level.objectives
                          .map((o) => ObjectiveItem(objective: o, level: level))
                          .toList(),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      '${level.maxMoves} moves to clear this glade',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          Audio.playAsset(AudioType.game_start);
                          onComplete?.call();
                        },
                        child: const Text('Begin level'),
                      ),
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
