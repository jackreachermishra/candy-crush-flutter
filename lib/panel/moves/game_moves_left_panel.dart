import 'package:prismleaf_vale/panel/moves/stream_moves_left_counter.dart';
import 'package:flutter/material.dart';

import '../../brand/brand_theme.dart';

class GameMovesLeftPanel extends StatelessWidget {
  const GameMovesLeftPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Brand.surface.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Brand.mint.withValues(alpha: 0.3)),
      ),
      width: 106.0,
      height: 76.0,
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'MOVES',
              style: TextStyle(
                fontSize: 11.0,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w800,
                color: Brand.mint,
              ),
            ),
          ),
          StreamMovesLeftCounter(),
        ],
      ),
    );
  }
}
