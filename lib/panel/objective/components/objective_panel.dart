import 'package:prismleaf_vale/panel/objective/components/stream_objective_item.dart';
import 'package:flutter/material.dart';

import '../../../bloc/bloc_provider.dart';
import '../../../bloc/game_bloc.dart';
import '../../../model/level.dart';
import '../model/objective.dart';
import '../../../brand/brand_theme.dart';

class ObjectivePanel extends StatelessWidget {
  const ObjectivePanel({super.key});

  @override
  Widget build(BuildContext context) {
    final GameBloc gameBloc = BlocProvider.of<GameBloc>(context)!.bloc;
    final Level level = gameBloc.gameController.level;
    //
    // Build the objectives
    //
    List<Widget> objectiveWidgets = level.objectives.map((Objective obj) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: StreamObjectiveItem(objective: obj),
      );
    }).toList();

    return Container(
      decoration: BoxDecoration(
        color: Brand.surface.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Brand.mint.withValues(alpha: 0.3)),
      ),
      height: 76.0,
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 5),
            child: Text(
              'COLLECT',
              style: TextStyle(
                color: Brand.mint,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
          ),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: objectiveWidgets,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
