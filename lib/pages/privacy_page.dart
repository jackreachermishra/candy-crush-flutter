import 'package:flutter/material.dart';

import '../brand/brand_theme.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Privacy & data')),
    body: ValeBackdrop(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            ValeCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'On your device',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Prismleaf Vale stores unlocked glades, scores, glow, '
                    'daily rewards, streaks, recent reward history, and '
                    'sound and color preferences on this '
                    'device. No account or game server is used. Clearing app '
                    'storage removes this local progress.',
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
                    'Optional ads',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'The game may show a banner on the trail map and offers '
                    'an optional rewarded ad for three extra moves. Ads are '
                    'never needed to play. When ads are enabled, Google Mobile '
                    'Ads and its consent tool may process IP address, app '
                    'interactions, diagnostics, and device identifiers for ad '
                    'delivery, measurement, and fraud prevention. Available '
                    'privacy choices appear in Settings where required.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
