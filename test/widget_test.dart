import 'package:flutter_test/flutter_test.dart';
import 'package:prismleaf_vale/bloc/game_bloc.dart';
import 'package:prismleaf_vale/main.dart';
import 'package:prismleaf_vale/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:prismleaf_vale/brand/progress.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  testWidgets('A level can be selected while assets load', (tester) async {
    final gameBloc = GameBloc();
    final level = await tester.runAsync(() => gameBloc.setLevel(3));
    expect(level?.index, 3);
    gameBloc.dispose();
  });

  testWidgets('App launches into the branded home screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    expect(find.byType(HomePage), findsOneWidget);
    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).title,
      'Prismleaf Vale',
    );
    await tester.pumpWidget(const SizedBox.shrink());
  });

  test('Completing a glade unlocks the next one and saves it', () async {
    await GameProgress.instance.load();
    await GameProgress.instance.complete(1, 5);
    expect(GameProgress.instance.unlockedLevel, 2);
    expect(GameProgress.instance.highestCompletedLevel, 1);
    expect(
      (await SharedPreferences.getInstance()).getInt(
        'prismleaf_unlocked_level',
      ),
      2,
    );
  });
}
