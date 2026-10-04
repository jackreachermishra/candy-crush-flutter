import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../model/tile.dart';

/// Vector pieces stay sharp on small and high density Android screens.
class ValePiece extends StatelessWidget {
  const ValePiece({super.key, required this.type, this.frozen = false});
  final TileType type;
  final bool frozen;

  @override
  Widget build(BuildContext context) => Semantics(
    label: '${type.name.replaceAll('_', ' ')} leaf${frozen ? ', frozen' : ''}',
    image: true,
    child: CustomPaint(
      painter: _PiecePainter(type, frozen),
      child: const SizedBox.expand(),
    ),
  );
}

class _PiecePainter extends CustomPainter {
  _PiecePainter(this.type, this.frozen);
  final TileType type;
  final bool frozen;

  @override
  void paint(Canvas canvas, Size size) {
    final s = math.min(size.width, size.height);
    if (s <= 0) return;
    final center = Offset(size.width / 2, size.height / 2);
    final name = type.name.split('_').first;
    final color = switch (name) {
      'red' => const Color(0xFFFA817A),
      'green' => const Color(0xFF7EDDB0),
      'blue' => const Color(0xFF6DCBE8),
      'orange' => const Color(0xFFFFAE70),
      'purple' => const Color(0xFFC9A1F4),
      'yellow' => const Color(0xFFF7D76D),
      'wall' => const Color(0xFF395C57),
      _ => const Color(0xFFFFD277),
    };
    final special = [
      'bomb',
      'flare',
      'fireball',
      'wrapped',
      'bomb_v',
      'bomb_h',
    ].contains(name);
    final radius = s * 0.43;
    final path = Path();
    final points = switch (name) {
      'orange' => 3,
      'green' => 5,
      'blue' => 6,
      'purple' => 8,
      _ => 4,
    };
    final rotation = name == 'red' || name == 'orange'
        ? math.pi / 4
        : -math.pi / 2;
    for (var i = 0; i < points; i++) {
      final angle = rotation + i * 2 * math.pi / points;
      final p = center + Offset(math.cos(angle), math.sin(angle)) * radius;
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    final shadow = Paint()
      ..color = const Color(0x99051E23)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawPath(path.shift(const Offset(0, 2)), shadow);
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(color, Colors.white, 0.4)!,
            color,
            Color.lerp(color, Colors.black, 0.3)!,
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.72)
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1, s * 0.035),
    );
    final facet = Path()
      ..moveTo(center.dx, center.dy - radius * 0.62)
      ..lineTo(center.dx + radius * 0.54, center.dy)
      ..lineTo(center.dx, center.dy + radius * 0.36)
      ..close();
    canvas.drawPath(
      facet,
      Paint()..color = Colors.white.withValues(alpha: 0.25),
    );
    if (special || type.name.endsWith('_v') || type.name.endsWith('_h')) {
      final star = Paint()
        ..color = const Color(0xFFFFF8E8)
        ..strokeWidth = math.max(1.5, s * 0.08)
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        center + Offset(0, -radius * 0.45),
        center + Offset(0, radius * 0.45),
        star,
      );
      canvas.drawLine(
        center + Offset(-radius * 0.45, 0),
        center + Offset(radius * 0.45, 0),
        star,
      );
    }
    if (frozen) {
      canvas.drawCircle(
        center,
        radius,
        Paint()..color = const Color(0x886ACFE8),
      );
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.7)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  @override
  bool shouldRepaint(_PiecePainter oldDelegate) =>
      oldDelegate.type != type || oldDelegate.frozen != frozen;
}
