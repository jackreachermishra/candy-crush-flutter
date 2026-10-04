import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:prismleaf_vale/animations/model/animations_resolver.dart';
import 'package:prismleaf_vale/bloc/game_bloc.dart';
import 'package:prismleaf_vale/model/array_2d.dart';
import 'package:prismleaf_vale/model/chain.dart';
import 'package:prismleaf_vale/model/combo.dart';
import 'package:prismleaf_vale/model/swap.dart';
import 'package:prismleaf_vale/model/tile.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('all six normal pieces can be generated', () {
    final random = Random(42);
    final colors = List.generate(1000, (_) => Tile.random(random)).toSet();
    expect(colors, {
      TileType.red,
      TileType.green,
      TileType.blue,
      TileType.orange,
      TileType.purple,
      TileType.yellow,
    });
  });

  test('matches at the board edge and long matches are recognized', () {
    final grid = Array2d<Tile>(10, 10);
    for (var row = 0; row < 10; row++) {
      for (var col = 0; col < 10; col++) {
        grid[row][col] = Tile(row: row, col: col, type: TileType.red);
      }
    }
    for (var col = 2; col < 10; col++) {
      grid[4][col].type = TileType.blue;
    }
    final horizontal = ChainHelper().checkHorizontalChain(4, 9, grid);
    expect(horizontal?.length, 8);
    final combo = Combo(horizontal, null, 4, 9);
    expect(combo.type, ComboType.seven);
    expect(combo.resultingTileType, TileType.fireball);
    for (var row = 1; row < 9; row++) {
      grid[row][1].type = TileType.green;
    }
    expect(ChainHelper().checkVerticalChain(8, 1, grid)?.length, 8);
  });

  test('different moves cannot share a swap identity', () {
    final first = Swap(from: Tile(row: 0, col: 1), to: Tile(row: 1, col: 1));
    final second = Swap(from: Tile(row: 0, col: 2), to: Tile(row: 0, col: 1));
    expect(first, isNot(second));
    expect({first}.contains(second), isFalse);
  });

  test('starting boards have valid swaps and reject distant swaps', () async {
    final bloc = GameBloc();
    addTearDown(bloc.dispose);
    for (var levelNumber = 1; levelNumber <= 5; levelNumber++) {
      final level = await bloc.setLevel(levelNumber);
      expect(
        level.objectives.every((objective) => objective.count > 0),
        isTrue,
      );
      expect(bloc.gameController.swaps, isNotEmpty);
      final swap = bloc.gameController.swaps.first;
      expect(bloc.gameController.swapContains(swap.from, swap.to), isTrue);
      expect(
        bloc.gameController.swapContains(
          bloc.gameController.grid[0][0],
          bloc.gameController.grid[level.numberOfRows - 1][level.numberOfCols -
              1],
        ),
        isFalse,
      );
    }
  });

  test('a bomb chains to another bomb in the same row', () async {
    final bloc = GameBloc();
    addTearDown(bloc.dispose);
    await bloc.setLevel(1);
    final grid = bloc.gameController.grid;
    for (var col = 0; col < 10; col++) {
      grid[2][col].type = TileType.empty;
    }
    grid[1][4].type = TileType.empty;
    grid[2][2].type = TileType.bomb_h;
    grid[2][4].type = TileType.flare;
    grid[3][4].type = TileType.red;
    bloc.gameController.proceedWithExplosion(grid[2][2], bloc);
    expect(grid[3][4].type, TileType.empty);
    expect(bloc.score, 30);
  });

  test('frozen pieces cannot be swapped and thaw on an explosion', () async {
    final bloc = GameBloc();
    addTearDown(bloc.dispose);
    final level = await bloc.setLevel(3);
    final grid = bloc.gameController.grid;
    expect(Tile(type: TileType.empty).canMove, isFalse);
    for (var row = 0; row < level.numberOfRows; row++) {
      for (var col = 0; col < level.numberOfCols; col++) {
        if (level.grid[row][col] != '2') continue;
        expect(grid[row][col].canMove, isFalse);
        final originalType = grid[row][col].type;
        grid[row][col - 1].type = TileType.flare;
        bloc.gameController.proceedWithExplosion(grid[row][col - 1], bloc);
        expect(grid[row][col].depth, 0);
        expect(grid[row][col].type, originalType);
        return;
      }
    }
    fail('Level 3 should contain a frozen piece');
  });

  test('gravity resolves a new match and refills the cleared cells', () async {
    final bloc = GameBloc();
    addTearDown(bloc.dispose);
    final level = await bloc.setLevel(1);
    final grid = bloc.gameController.grid;
    const colors = [
      TileType.red,
      TileType.green,
      TileType.blue,
      TileType.orange,
      TileType.purple,
      TileType.yellow,
    ];
    for (var row = 0; row < level.numberOfRows; row++) {
      for (var col = 0; col < level.numberOfCols; col++) {
        grid[row][col].type = colors[(row * 2 + col) % colors.length];
      }
    }
    grid[0][0].type = TileType.empty;
    grid[0][1].type = TileType.blue;
    grid[0][2].type = TileType.blue;
    grid[1][0].type = TileType.blue;
    final resolver = AnimationsResolver(gameBloc: bloc, level: level);
    resolver.resolve();
    expect(bloc.score, greaterThanOrEqualTo(30));
    expect(level.objectives.first.count, lessThanOrEqualTo(1));
    expect(resolver.involvedCells, isNotEmpty);
    expect(
      resolver.resultingGridInTermsOfTileTypes[0][0],
      isNot(TileType.empty),
    );
  });

  test('the final move emits one win after objectives resolve', () async {
    final bloc = GameBloc();
    addTearDown(bloc.dispose);
    final level = await bloc.setLevel(1);
    final results = <bool>[];
    final subscription = bloc.gameIsOver.listen(results.add);
    addTearDown(subscription.cancel);
    for (var move = 1; move < level.maxMoves; move++) {
      bloc.playMove();
    }
    for (final objective in level.objectives) {
      bloc.pushTileEvent(objective.type, objective.count);
    }
    await Future<void>.delayed(Duration.zero);
    expect(results, isEmpty);
    bloc.playMove();
    bloc.playMove();
    await Future<void>.delayed(Duration.zero);
    expect(results, [true]);
    expect(level.movesLeft, 0);
  });

  test('exhausting moves without objectives emits one loss', () async {
    final bloc = GameBloc();
    addTearDown(bloc.dispose);
    final level = await bloc.setLevel(1);
    final results = <bool>[];
    final subscription = bloc.gameIsOver.listen(results.add);
    addTearDown(subscription.cancel);
    for (var move = 0; move < level.maxMoves + 1; move++) {
      bloc.playMove();
    }
    await Future<void>.delayed(Duration.zero);
    expect(results, [false]);
    expect(level.movesLeft, 0);
  });
}
