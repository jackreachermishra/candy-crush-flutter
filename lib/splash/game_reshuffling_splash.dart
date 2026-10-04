import 'package:flutter/material.dart';

import '../brand/brand_theme.dart';

class GameReshufflingSplash extends StatefulWidget {
  const GameReshufflingSplash({super.key, this.onComplete});
  final VoidCallback? onComplete;
  @override
  State<GameReshufflingSplash> createState() => _GameReshufflingSplashState();
}

class _GameReshufflingSplashState extends State<GameReshufflingSplash> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) widget.onComplete?.call();
    });
  }

  @override
  Widget build(BuildContext context) => Positioned.fill(
    child: Material(
      color: Brand.ink.withValues(alpha: 0.82),
      child: Center(
        child: ValeCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.shuffle_rounded, color: Brand.gold, size: 42),
              const SizedBox(height: 12),
              Text(
                'A fresh trail appears',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
