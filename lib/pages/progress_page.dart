import 'package:flutter/material.dart';

import '../brand/brand_theme.dart';
import '../brand/progress.dart';

class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Your journey')),
    body: ValeBackdrop(
      child: SafeArea(
        child: AnimatedBuilder(
          animation: GameProgress.instance,
          builder: (context, _) {
            final progress = GameProgress.instance;
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                ValeCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Trail progress',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Glades restored: ${progress.highestCompletedLevel} / 5',
                      ),
                      Text('Total wins: ${progress.totalWins}'),
                      Text('Best scores combined: ${progress.bestTotalScore}'),
                      Text('Glow: ${progress.glow}'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ValeCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Daily light',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text('Current streak: ${progress.currentStreak} days'),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: progress.canClaimDaily
                            ? () async {
                                final amount = await progress.claimDaily();
                                if (context.mounted && amount > 0) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Collected $amount glow'),
                                    ),
                                  );
                                }
                              }
                            : null,
                        icon: const Icon(Icons.wb_sunny_rounded),
                        label: Text(
                          progress.canClaimDaily
                              ? 'Claim today\'s glow'
                              : 'Come back tomorrow',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ValeCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Valley colors',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Change the valley backdrop. Gameplay stays the same.',
                      ),
                      ListTile(
                        title: const Text('Forest'),
                        trailing: progress.selectedTheme == 'forest'
                            ? const Icon(Icons.check_circle_rounded)
                            : null,
                        onTap: () => progress.selectTheme('forest'),
                      ),
                      if (progress.twilightUnlocked)
                        ListTile(
                          title: const Text('Twilight'),
                          trailing: progress.selectedTheme == 'twilight'
                              ? const Icon(Icons.check_circle_rounded)
                              : null,
                          onTap: () => progress.selectTheme('twilight'),
                        )
                      else
                        OutlinedButton(
                          onPressed: progress.glow >= 100
                              ? progress.unlockTwilight
                              : null,
                          child: const Text('Unlock Twilight for 100 glow'),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ValeCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Best by glade',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      for (var level = 1; level <= 5; level++)
                        Text(
                          'Glade $level: ${progress.bestScores[level] ?? 0}',
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    ),
  );
}
