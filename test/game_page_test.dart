import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prismleaf_vale/bloc/bloc_provider.dart';
import 'package:prismleaf_vale/bloc/game_bloc.dart';
import 'package:prismleaf_vale/pages/game_page.dart';

void main() {
  testWidgets('A loaded level shows its playable intro and board', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final bloc = GameBloc();
    addTearDown(bloc.dispose);
    final level = await tester.runAsync(() => bloc.setLevel(1));
    await tester.pumpWidget(
      BlocProvider<GameBloc>(
        bloc: bloc,
        child: MaterialApp(home: GamePage(level: level!)),
      ),
    );
    await tester.pump();
    expect(find.text('Begin level'), findsOneWidget);
    expect(find.text('Glade 1'), findsWidgets);
    final largeTileWidth = level.tileWidth;
    expect(largeTileWidth, greaterThan(0));
    tester.view.physicalSize = const Size(960, 1704);
    await tester.pump();
    await tester.pump();
    expect(level.tileWidth, lessThan(largeTileWidth));
    expect(level.boardLeft, greaterThanOrEqualTo(0));
  });
}
