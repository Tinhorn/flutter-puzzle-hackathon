import 'dart:math';

import 'package:dartx/dartx.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_puzzle_hack/puzzle/model/tile.dart';

class PuzzleState extends Equatable {
  final List<Tile> tiles = 1
      .rangeTo(16)
      .map(
        (correctNum) => Tile(
          correctNum: correctNum,
          currentNum: correctNum,
        ),
      )
      .toList();
  late Tile emptyTile;
  late bool solved;
  late double percentSolved;

  //when n is even, an n-by-n board is solvable if and only if the
  // number of inversions plus the row of the blank square is odd.
  late bool solvable;
  late int nInversion;
  late int hammingDistance;
  late int manhattanDistance;
  late int linearConflict;

  PuzzleState.exactState(List<int> currentNumOrder)
      : assert(currentNumOrder.length == 16,
            "Current Number Order has to be sixteen") {
    _createTileOrder(currentNumOrder);
  }

  factory PuzzleState.difficulty(PuzzleDifficulty difficulty) {
    switch (difficulty) {
      case PuzzleDifficulty.easy:
        return PuzzleState.fromSolved(stepsAway: 15);
      case PuzzleDifficulty.medium:
        return PuzzleState.fromSolved(stepsAway: 30);
      case PuzzleDifficulty.hard:
        return PuzzleState.fromSolved(stepsAway: 45);
    }
  }

  factory PuzzleState.fromSolved({int stepsAway = 0}) {
    PuzzleState? parent;
    PuzzleState puzzleState = PuzzleState._solved();
    Random random = Random();

    for (int i = 0; i < stepsAway; i++) {
      List<PuzzleState> nextStates = puzzleState.nextStates(parent);
      parent = puzzleState;
      puzzleState = nextStates[random.nextInt(nextStates.length)];
    }

    return puzzleState;
  }

  PuzzleState._solved() {
    _calcStateVariables();
  }

  PuzzleState.clone(PuzzleState other) {
    _createTileOrder(other.tiles.map((e) => e.currentNum).toList());
  }

  void _createTileOrder(List<int> currentNumOrder) {
    List<int> order = List.of(currentNumOrder);
    for (Tile tile in tiles) {
      tile.currentNum = order.removeAt(0);
    }
    _calcStateVariables();
  }

  void _calcStateVariables() {
    //The last tile is the emptyTile
    emptyTile = tiles.last;
    percentSolved =
        tiles.count((tile) => tile.currentNum == tile.correctNum) / 16;
    solved = percentSolved == 1;
    nInversion = _nInversion();
    solvable = (nInversion + emptyTile.currentRowNum) % 2 == 1;
    hammingDistance = 0;
    manhattanDistance = 0;
    for (Tile tile in tiles) {
      if (tile != emptyTile) {
        hammingDistance += tile.currentNum == tile.correctNum ? 0 : 1;
        manhattanDistance += tile.manhattanDistance;
      }
    }
    linearConflict = _linearConflict();
  }

  int _nInversion() {
    int nInversion = 0;
    for (int i = 16; i > 1; i--) {
      Tile tile = getCurrentNumber(i);
      if (tile == emptyTile) {
        continue;
      }
      for (int j = i - 1; j > 0; j--) {
        Tile comparingTile = getCurrentNumber(j);
        if (comparingTile == emptyTile) {
          continue;
        }
        if (tile.correctNum < comparingTile.correctNum) {
          nInversion++;
        }
      }
    }
    return nInversion;
  }

  ///Two tiles ‘a’ and ‘b’ are in a linear conflict if they are in the same row or column
  ///,also their goal positions are in the same row or column and the goal position of one
  /// of the tiles is blocked by the other tile in that row.
  ///
  /// Two tiles tj and tk are in a linear conflict if tj and tk are the same line,
  /// the goal positions of tj and tk are both in that line,tj is to the right of tk ,
  /// and goal position of tj is to the left of the goal position of tk .
  /// Here line indicated both rows and columns.
  /// The linear conflict heuristic is calculated as Manhattan distance + 2*(Linear conflicts).
  int _linearConflict() {
    int linearConflict = 0;

    List<Tile> rowApproposTiles = [];
    List<Tile> colApproposTiles = [];
    for (int col = 0; col < 4; col++) {
      for (int row = 0; row < 4; row++) {
        Tile element = getCurrentNumber((col * 4) + (row + 1));
        if (element == emptyTile) {
          continue;
        }
        if (element.correctRowNum == element.currentRowNum) {
          rowApproposTiles.add(element);
        }
        if (element.correctColNum == element.correctColNum) {
          colApproposTiles.add(element);
        }
      }
    }

    //Row

    Set<Tile> rowConflictsFound = {};
    Set<Tile> rowConflictsFoundTest = {};
    Map<int, Set<Tile>> singleRowConflicts = {};

    while (rowApproposTiles.isNotEmpty) {
      Tile tj = rowApproposTiles.removeAt(0);
      for (int i = 0; i < rowApproposTiles.length; i++) {
        Tile tk = rowApproposTiles[i];
        if (tj.correctRowNum == tk.correctRowNum &&
            tj.currentColNum < tk.currentColNum &&
            tj.correctColNum > tk.correctColNum) {
          tj.rowConflicts.add(tk.correctNum);
          tk.rowConflicts.add(tj.correctNum);
          rowConflictsFoundTest.add(tj);
          rowConflictsFound.add(tk);
          rowConflictsFoundTest.add(tj);
          rowConflictsFound.add(tk);
          singleRowConflicts
              .putIfAbsent(tj.currentRowNum, () => {})
              .addAll([tj, tk]);

          // print("Tj: $tj, Tk: $tk");
        }
      }
    }

    while (rowConflictsFoundTest
        .any((element) => element.rowConflicts.isNotEmpty)) {
      for (Tile tj in rowConflictsFound) {
        Tile tk = tj.rowConflicts.fold<Tile>(tj, (previousValue, element) {
          var elementTile = getCorrectNumber(element);
          if (previousValue.rowConflicts.length <
              elementTile.rowConflicts.length) {
            return elementTile;
          } else {
            return previousValue;
          }
        });
        for (int correctNum in tk.rowConflicts) {
          Tile conflictTile = getCorrectNumber(correctNum);
          conflictTile.rowConflicts.remove(tk.correctNum);
        }
        tk.rowConflicts.clear();
        linearConflict++;
      }
    }

    //Col

    Set<Tile> colConflictsFound = {};
    Set<Tile> colConflictsFoundTest = {};
    Map<int, Set<Tile>> singleColConflicts = {};

    while (colApproposTiles.isNotEmpty) {
      Tile tj = colApproposTiles.removeAt(0);
      for (int i = 0; i < colApproposTiles.length; i++) {
        Tile tk = colApproposTiles[i];
        if (tj.correctColNum == tk.correctColNum &&
            tj.currentRowNum < tk.currentRowNum &&
            tj.correctRowNum > tk.correctRowNum) {
          tj.colConflicts.add(tk.correctNum);
          tk.colConflicts.add(tj.correctNum);
          colConflictsFoundTest.add(tj);
          colConflictsFound.add(tk);
          colConflictsFoundTest.add(tj);
          colConflictsFound.add(tk);
          singleColConflicts
              .putIfAbsent(tj.currentColNum, () => {})
              .addAll([tj, tk]);

          // print("Tj: $tj, Tk: $tk");
        }
      }
    }

    while (colConflictsFoundTest
        .any((element) => element.colConflicts.isNotEmpty)) {
      for (Tile tj in colConflictsFound) {
        Tile tk = tj.colConflicts.fold<Tile>(tj, (previousValue, element) {
          var elmentTile = getCorrectNumber(element);
          if (previousValue.colConflicts.length <
              elmentTile.colConflicts.length) {
            return elmentTile;
          } else {
            return previousValue;
          }
        });
        for (int correctNum in tk.colConflicts) {
          Tile conflictTile = getCorrectNumber(correctNum);
          conflictTile.colConflicts.remove(tk.correctNum);
        }
        tk.colConflicts.clear();
        linearConflict++;
      }
    }

    // print(this);

    // while (colApproposTiles.isNotEmpty) {
    //   Tile tj = colApproposTiles.removeAt(0);
    //   for (int i = 0; i < colApproposTiles.length; i++) {
    //     Tile tk = colApproposTiles[i];
    //     if (tj.correctColNum == tk.correctColNum &&
    //         tj.currentRowNum > tk.currentRowNum &&
    //         tj.correctRowNum < tk.correctRowNum) {
    //       linearConflict++;
    //       // print("Tj: $tj, Tk: $tk");
    //     }
    //   }
    // }

    return linearConflict;
  }

  @override
  List<Object?> get props => [tiles];

  Tile getCurrentNumber(int currentNumber) {
    if (currentNumber < 1 || currentNumber > 16) {
      throw ArgumentError("current number has to be between 1 and 16");
    }
    return tiles.firstWhere((element) => element.currentNum == currentNumber);
  }

  Tile getCorrectNumber(int correctNumber) {
    if (correctNumber < 1 || correctNumber > 16) {
      throw ArgumentError("correctNumber number has to be between 1 and 16");
    }
    return tiles[correctNumber - 1];
  }

  void changeTileNum({required int currentNum, required int newCurrentNum}) {
    getCurrentNumber(currentNum).currentNum = newCurrentNum;
    _calcStateVariables();
  }

  void swapTileNums(
      {required int firstCurrentNum, required int secondCurrentNum}) {
    Tile firstTile = getCurrentNumber(firstCurrentNum);
    Tile secondTile = getCurrentNumber(secondCurrentNum);
    secondTile.currentNum = firstCurrentNum;
    firstTile.currentNum = secondCurrentNum;
    _calcStateVariables();
  }

  List<PuzzleState> nextStates(PuzzleState? parent) {
    List<PuzzleState> puzzleStates = [];
    late int potentialSwap;
    int emptyTileCurrentNum = emptyTile.currentNum;
    //-1
    //Don't move left if emptyTile is the first tile in the row
    if (emptyTile.currentNum % 4 != 1) {
      potentialSwap = emptyTile.currentNum - 1;
      PuzzleState newState = swapEmptyTile(potentialSwap);
      if (newState != parent) {
        puzzleStates.add(newState);
      }
    }
    //+1
    //Don't move right if emptyTile is the last tile in the row
    if (emptyTile.currentNum % 4 != 0) {
      potentialSwap = emptyTile.currentNum + 1;
      PuzzleState newState = swapEmptyTile(potentialSwap);
      if (newState != parent) {
        puzzleStates.add(newState);
      }
    }

    //-4
    //Don't move up if emptyTile is in the first row
    if (emptyTile.currentRowNum != 0) {
      potentialSwap = emptyTile.currentNum - 4;
      PuzzleState newState = swapEmptyTile(potentialSwap);
      if (newState != parent) {
        puzzleStates.add(newState);
      }
    }

    //+4
    //Don't move down if emptyTile is in the last row
    if (emptyTile.currentRowNum != 3) {
      potentialSwap = emptyTile.currentNum + 4;
      PuzzleState newState = swapEmptyTile(potentialSwap);
      if (newState != parent) {
        puzzleStates.add(newState);
      }
    }
    return puzzleStates;
  }

  PuzzleState swapEmptyTile(int currentNum) {
    return swapTiles(currentNum, emptyTile.currentNum);
  }

  PuzzleState swapTiles(int firstNum, int secondNum) {
    PuzzleState newState = PuzzleState.clone(this);
    newState.swapTileNums(
      firstCurrentNum: firstNum,
      secondCurrentNum: secondNum,
    );
    return newState;
  }

  @override
  String toString() {
    String stringRepresentation = "|";
    for (int i = 0; i < 16; i++) {
      Tile tile = getCurrentNumber(i + 1);

      if (tile.correctNum == 16) {
        stringRepresentation += " *${tile.correctNum}* | ";
      } else {
        stringRepresentation += " ${tile.correctNum} | ";
      }
      if (tile.currentNum % 4 == 0 && tile.currentNum != 16) {
        stringRepresentation += "\n|";
      }
    }
    return stringRepresentation;
  }

  Map<TileDirection, Tile> get movableTiles {
    Map<TileDirection, Tile> movableTiles = {};
    //-1
    //Don't move left if emptyTile is the first tile in the row
    if (emptyTile.currentNum % 4 != 1) {
      movableTiles[TileDirection.left] =
          getCurrentNumber(emptyTile.currentNum - 1);
    }
    //+1
    //Don't move right if emptyTile is the last tile in the row
    if (emptyTile.currentNum % 4 != 0) {
      movableTiles[TileDirection.right] =
          getCurrentNumber(emptyTile.currentNum + 1);
    }

    //-4
    //Don't move up if emptyTile is in the first row
    if (emptyTile.currentRowNum != 0) {
      movableTiles[TileDirection.up] =
          getCurrentNumber(emptyTile.currentNum - 4);
    }

    //+4
    //Don't move down if emptyTile is in the last row
    if (emptyTile.currentRowNum != 3) {
      movableTiles[TileDirection.down] =
          getCurrentNumber(emptyTile.currentNum + 4);
    }
    return movableTiles;
  }
}

enum PuzzleDifficulty {
  easy,
  medium,
  hard,
}

enum TileDirection {
  up,
  down,
  left,
  right,
}
