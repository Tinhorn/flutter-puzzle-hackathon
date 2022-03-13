import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_puzzle_hack/puzzle/puzzle_tile.dart';

class Tile extends Equatable {
  //correct number of the tile
  final int correctNum;

  //current number of the tile
  int currentNum;

  List<int> rowConflicts = [];
  List<int> colConflicts = [];
  Tile({
    required this.correctNum,
    required this.currentNum,
  });

  /// Find the position of the tile based on the currentNumber
  Offset get position {
    final double _dx = currentColNum * PuzzleTile.width;
    final double _dy = currentRowNum * PuzzleTile.height;

    return Offset(_dx, _dy);
  }

  //0 based
  int get currentRowNum => ((currentNum - 1) / 4).floor();

  //0 based
  int get currentColNum => ((currentNum - 1) % 4);

  //0 based
  int get correctRowNum => ((correctNum - 1) / 4).floor();

  //0 based
  int get correctColNum => ((correctNum - 1) % 4);

  int get manhattanDistance =>
      (currentColNum - correctColNum).abs() +
      (currentRowNum - correctRowNum).abs();

  @override
  List<Object?> get props => [correctNum, currentNum];

  @override
  String toString() {
    return 'Tile{correctNum: $correctNum, currentNum: $currentNum}';
  }

//movable
// current distance to empty
// + /- 1
// +/- 4
}
