// TileType names are used in level data; keep their existing spellings.
// ignore_for_file: constant_identifier_names

import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'level.dart';
import '../brand/vale_piece.dart';

/// Tile
class Tile extends Object {
  TileType? type;
  int row;
  int col;
  Level? level;
  int depth;
  Widget? _widget;
  double? x;
  double? y;
  bool visible;

  Tile({
    this.type,
    this.row = 0,
    this.col = 0,
    this.level,
    this.depth = 0,
    this.visible = true,
  });

  factory Tile.clone(Tile otherTile) {
    Tile newTile = Tile(
      type: otherTile.type,
      row: otherTile.row,
      col: otherTile.col,
      level: otherTile.level,
      depth: otherTile.depth,
      visible: otherTile.visible,
    );
    newTile._widget = otherTile._widget;
    newTile.x = otherTile.x;
    newTile.y = otherTile.y;

    return newTile;
  }

  @override
  int get hashCode => row * 1000 + col;

  @override
  bool operator ==(Object other) {
    return identical(this, other) || other.hashCode == hashCode;
  }

  @override
  String toString() {
    return '[$row][$col] => ${type!.name}';
  }

  //
  // Builds the tile in terms of "decoration" ( = image )
  //
  void build({bool computePosition = true}) {
    if (type == TileType.empty || type == TileType.forbidden) {
      _widget = Container();
    } else {
      _widget = ValePiece(
        type: type!,
        frozen: depth > 0 && type != TileType.wall,
      );
    }

    if (computePosition) {
      setPosition();
    }
  }

  //
  // Returns the position of this tile in the checkerboard
  // based on its position in the grid (row, col) and
  // the dimensions of the board and a tile
  //
  void setPosition() {
    double bottom =
        level!.boardTop + (level!.numberOfRows - 1) * level!.tileHeight;
    x = level!.boardLeft + col * level!.tileWidth;
    y = bottom - row * level!.tileHeight;
  }

  //
  // Generate a tile to be used during the swap animations
  //
  Tile cloneForAnimation() {
    Tile tile = Tile(level: level, type: type, row: row, col: col);
    tile.build();

    return tile;
  }

  /// Swaps this tile (row, col) with the ones of another Tile
  void swapRowColWith(Tile destTile) {
    ///交换双方的坐标信息和位置信息
    int tft = destTile.row;
    destTile.row = row;
    row = tft;

    tft = destTile.col;
    destTile.col = col;
    col = tft;

    double? txt = destTile.x;
    destTile.x = x;
    x = txt;

    double? tyt = destTile.y;
    destTile.y = y;
    y = tyt;
  }

  //
  // Returns the Widget to be used to render the Tile
  //
  Widget get widget => getWidgetSized(level!.tileWidth, level!.tileHeight);

  Widget getWidgetSized(double width, double height) =>
      SizedBox(width: width, height: height, child: _widget);

  //
  // Can the Tile move?
  //
  bool get canMove => (depth == 0) && (canBePlayed(type!));

  //
  // Can a Tile fall?
  //
  bool get canFall =>
      type != TileType.wall &&
      type != TileType.forbidden &&
      type != TileType.empty;

  // ################  HELPERS  ######################
  //
  // Generate a random tile
  //
  static TileType random(math.Random rnd) {
    int minValue = _firstNormalTile;
    int maxValue = _lastNormalTile;
    int value = rnd.nextInt(maxValue - minValue) + minValue;
    return TileType.values[value];
  }

  static int get _firstNormalTile => TileType.red.index;
  static int get _lastNormalTile => TileType.yellow.index;
  static int get _firstBombTile => TileType.bomb.index;
  static int get _lastBombTile => TileType.fireball.index;

  static bool isNormal(TileType type) {
    int index = type.index;
    return (index >= _firstNormalTile && index <= _lastNormalTile);
  }

  static bool isBomb(TileType type) {
    int index = type.index;
    return (index >= _firstBombTile && index <= _lastBombTile);
  }

  static bool canBePlayed(TileType type) =>
      (type != TileType.wall && type != TileType.forbidden);

  static TileType normalizeBombType(TileType bombType) {
    switch (bombType) {
      case TileType.blue_v:
      case TileType.red_v:
      case TileType.green_v:
      case TileType.orange_v:
      case TileType.purple_v:
      case TileType.yellow_v:
        return TileType.bomb_v;

      case TileType.blue_h:
      case TileType.red_h:
      case TileType.green_h:
      case TileType.orange_h:
      case TileType.purple_h:
      case TileType.yellow_h:
        return TileType.bomb_h;

      default:
        return bombType;
    }
  }
}

/// Types of tiles
enum TileType {
  forbidden,
  empty,
  red,
  green,
  blue,
  orange,
  purple,
  yellow,
  wall,
  bomb,
  flare,
  blue_v,
  blue_h,
  red_v,
  red_h,
  green_v,
  green_h,
  orange_v,
  orange_h,
  purple_v,
  purple_h,
  yellow_v,
  yellow_h,
  wrapped,
  fireball,
  bomb_v,
  bomb_h,
  last,
}
