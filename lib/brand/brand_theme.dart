import 'package:flutter/material.dart';

import 'progress.dart';

abstract final class Brand {
  static const name = 'Prismleaf Vale';
  static const ink = Color(0xFF092B2D);
  static const forest = Color(0xFF124C49);
  static const mint = Color(0xFF8BE0B3);
  static const cream = Color(0xFFFFF8E8);
  static const gold = Color(0xFFFFCF72);
  static const coral = Color(0xFFFF8D80);
  static const surface = Color(0xFF194D4C);
  static const success = Color(0xFF6ED5A0);
  static const warning = Color(0xFFFFB77C);
  static const radius = 22.0;

  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: ink,
    colorScheme: const ColorScheme.dark(
      primary: mint,
      secondary: gold,
      surface: surface,
      onSurface: cream,
      error: coral,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 38,
        fontWeight: FontWeight.w900,
        letterSpacing: -1.3,
        color: cream,
      ),
      headlineMedium: TextStyle(
        fontSize: 27,
        fontWeight: FontWeight.w800,
        color: cream,
      ),
      titleLarge: TextStyle(
        fontSize: 21,
        fontWeight: FontWeight.w800,
        color: cream,
      ),
      bodyLarge: TextStyle(fontSize: 16, color: cream),
      bodyMedium: TextStyle(fontSize: 14, color: cream),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: mint,
        foregroundColor: ink,
        minimumSize: const Size(48, 54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
      ),
    ),
  );
}

class ValeBackdrop extends StatelessWidget {
  const ValeBackdrop({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: GameProgress.instance,
    builder: (context, _) => Container(
      decoration: BoxDecoration(
        color: GameProgress.instance.selectedTheme == 'twilight'
            ? const Color(0xFF1D2448)
            : Brand.ink,
        image: DecorationImage(
          image: const AssetImage('assets/brand/vale_background.jpg'),
          fit: BoxFit.cover,
          opacity: 0.54,
          colorFilter: GameProgress.instance.selectedTheme == 'twilight'
              ? const ColorFilter.mode(Color(0xFF9B89D8), BlendMode.modulate)
              : null,
        ),
      ),
      child: child,
    ),
  );
}

class ValeCard extends StatelessWidget {
  const ValeCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
  });
  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: Brand.surface.withValues(alpha: 0.94),
      borderRadius: BorderRadius.circular(Brand.radius),
      border: Border.all(color: Brand.mint.withValues(alpha: 0.23)),
      boxShadow: const [
        BoxShadow(
          color: Color(0x66061820),
          blurRadius: 22,
          offset: Offset(0, 12),
        ),
      ],
    ),
    child: child,
  );
}
