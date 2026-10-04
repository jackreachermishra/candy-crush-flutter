import 'package:prismleaf_vale/model/tile.dart';

/// Identifies a possible swap between 2 tiles
/// 识别两个糖果之间是否能交换
class Swap extends Object {
  Tile from;
  Tile to;

  Swap({required this.from, required this.to});

  @override
  int get hashCode => Object.hash(from.row, from.col, to.row, to.col);

  @override
  bool operator ==(Object other) {
    return identical(other, this) ||
        other is Swap &&
            other.from.row == from.row &&
            other.from.col == from.col &&
            other.to.row == to.row &&
            other.to.col == to.col;
  }

  @override
  String toString() => '[${from.row}][${from.col}] => [${to.row}][${to.col}]';
}
