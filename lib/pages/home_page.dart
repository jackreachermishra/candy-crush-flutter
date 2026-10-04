import 'package:flutter/material.dart';

import '../ads/ads_service.dart';
import '../ads/banner_slot.dart';
import '../bloc/bloc_provider.dart';
import '../bloc/game_bloc.dart';
import '../brand/brand_theme.dart';
import '../brand/progress.dart';
import '../model/level.dart';
import 'game_page.dart';
import 'progress_page.dart';
import 'privacy_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  bool _loadingLevel = false;
  late GameBloc _gameBloc;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      GameProgress.instance.refreshForNewDay();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _gameBloc = BlocProvider.of<GameBloc>(context)!.bloc;
  }

  Future<void> _openLevel(int number) async {
    if (_loadingLevel) return;
    setState(() => _loadingLevel = true);
    try {
      final Level level = await _gameBloc.setLevel(number);
      if (!mounted) return;
      await Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: (_) => GamePage(level: level)));
    } finally {
      if (mounted) setState(() => _loadingLevel = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    bottomNavigationBar: const BannerSlot(),
    body: ValeBackdrop(
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: FutureBuilder<void>(
              future: _gameBloc.levelsReady,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      'Levels could not be loaded. Please restart the game.',
                    ),
                  );
                }
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                return AnimatedBuilder(
                  animation: GameProgress.instance,
                  builder: (context, _) => ListView(
                    padding: const EdgeInsets.fromLTRB(22, 22, 22, 32),
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: IconButton.filledTonal(
                          tooltip: 'Settings',
                          onPressed: () => showModalBottomSheet<void>(
                            context: context,
                            builder: (_) => const SettingsSheet(),
                          ),
                          icon: const Icon(Icons.settings_rounded),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: Image.asset(
                          'assets/brand/vale_icon.png',
                          width: 112,
                          height: 112,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        Brand.name,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      const SizedBox(height: 7),
                      const Text(
                        'A little light in every match',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Brand.mint, fontSize: 16),
                      ),
                      const SizedBox(height: 28),
                      FilledButton.icon(
                        onPressed: _loadingLevel
                            ? null
                            : () => _openLevel(
                                GameProgress.instance.unlockedLevel.clamp(
                                  1,
                                  _gameBloc.numberOfLevels,
                                ),
                              ),
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: Text(
                          _loadingLevel ? 'Opening…' : 'Continue journey',
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const ProgressPage(),
                          ),
                        ),
                        icon: const Icon(Icons.auto_graph_rounded),
                        label: const Text('Progress & daily light'),
                      ),
                      const SizedBox(height: 28),
                      ValeCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'The valley trail',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Clear each glade to light the next.',
                              style: TextStyle(color: Brand.mint),
                            ),
                            const SizedBox(height: 18),
                            for (
                              var i = 1;
                              i <= _gameBloc.numberOfLevels;
                              i++
                            ) ...[
                              _levelRow(i),
                              if (i < _gameBloc.numberOfLevels)
                                const SizedBox(height: 10),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    ),
  );

  Widget _levelRow(int number) {
    const titles = [
      'First light',
      'Fern crossing',
      'Moonlit bend',
      'Crystal canopy',
      'Heart of the vale',
    ];
    final unlocked = number <= GameProgress.instance.unlockedLevel;
    final completed = number <= GameProgress.instance.highestCompletedLevel;
    return Semantics(
      label:
          'Level $number, ${titles[number - 1]}, ${completed
              ? 'completed'
              : unlocked
              ? 'unlocked'
              : 'locked'}',
      child: Material(
        color: unlocked ? Brand.forest : Brand.ink.withValues(alpha: 0.56),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: unlocked && !_loadingLevel ? () => _openLevel(number) : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: unlocked ? Brand.mint : Brand.surface,
                  foregroundColor: Brand.ink,
                  child: Text('$number'),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    titles[number - 1],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Icon(
                  completed
                      ? Icons.check_circle_rounded
                      : unlocked
                      ? Icons.arrow_forward_ios_rounded
                      : Icons.lock_rounded,
                  color: unlocked
                      ? Brand.gold
                      : Brand.cream.withValues(alpha: 0.45),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SettingsSheet extends StatelessWidget {
  const SettingsSheet({super.key});

  @override
  Widget build(BuildContext context) => SafeArea(
    child: AnimatedBuilder(
      animation: Listenable.merge([GameProgress.instance, AdsService.instance]),
      builder: (context, _) => SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Settings',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              SwitchListTile.adaptive(
                title: const Text('Sound effects'),
                subtitle: const Text('Match, spark and result sounds'),
                value: GameProgress.instance.soundEnabled,
                onChanged: GameProgress.instance.setSoundEnabled,
              ),
              SwitchListTile.adaptive(
                title: const Text('Vibration'),
                subtitle: const Text('Feedback for moves and results'),
                value: GameProgress.instance.hapticsEnabled,
                onChanged: GameProgress.instance.setHapticsEnabled,
              ),
              if (AdsService.instance.privacyOptionsRequired)
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: const Text('Privacy options'),
                  onTap: AdsService.instance.showPrivacyOptions,
                ),
              ListTile(
                leading: const Icon(Icons.info_outline_rounded),
                title: const Text('Privacy & data'),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const PrivacyPage()),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  'Gameplay works offline. Ads are optional; no account is required.',
                  style: TextStyle(color: Brand.mint),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
