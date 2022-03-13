import 'package:flutter_puzzle_hack/puzzle/model/puzzle_state.dart';
import 'package:flutter_puzzle_hack/puzzle/model/puzzle_state_solver.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Simple Puzzle should be solved in 1 step', () async {
    PuzzleState puzzleState = PuzzleState.exactState(const [
      1,
      2,
      3,
      4,
      5,
      6,
      7,
      8,
      9,
      10,
      11,
      12,
      13,
      14,
      16,
      15,
    ]);
    PuzzleStateSolver puzzleStateSolver = PuzzleStateSolver();
    PuzzleAnswer? solvingStep =
        await puzzleStateSolver.solvePuzzle(puzzleState);
    expect(solvingStep?.moves, 1);
  });

  test('Simple Puzzle should be solved in 2 steps', () async {
    PuzzleState puzzleState = PuzzleState.exactState(const [
      1,
      2,
      3,
      4,
      5,
      6,
      7,
      8,
      9,
      10,
      15,
      12,
      13,
      14,
      16,
      11,
    ]);
    PuzzleStateSolver puzzleStateSolver = PuzzleStateSolver();
    PuzzleAnswer? solvingStep =
        await puzzleStateSolver.solvePuzzle(puzzleState);
    expect(solvingStep?.moves, 2);
  });

  test('Complex Puzzle should be solved in 46 steps', () async {
    //https://en.wikipedia.org/wiki/15_puzzle
    PuzzleState puzzleState = PuzzleState.exactState(const [
      3, //1
      15, //2
      14, //3
      6, //4
      1, //5
      4, // 6
      7, //7
      16, //8
      9, //9
      2, //10
      13, //11
      10, //12
      5, //13
      12, //14
      8, //15
      11, //16
    ]);
    // print(
    //     "MD: ${puzzleState.manhattanDistance} + ${puzzleState.linearConflict}");
    PuzzleStateSolver puzzleStateSolver = PuzzleStateSolver();
    PuzzleAnswer? answer = await puzzleStateSolver.solvePuzzle(puzzleState);
    expect(answer?.moves, 46);

    // while (answer?.sequence.isNotEmpty ?? false) {
    //   var removeFirst = answer?.sequence.removeFirst();
    //   print(removeFirst);
    //   print(
    //       "MD: ${removeFirst?.manhattanDistance} + ${removeFirst?.linearConflict}");
    //   print("-------------------");
    // }
  });

  test('Easy Puzzle should be solved in 15 steps or less', () async {
    PuzzleState puzzleState = PuzzleState.difficulty(PuzzleDifficulty.easy);

    PuzzleStateSolver puzzleStateSolver = PuzzleStateSolver();
    // print(
    //     "MD: ${puzzleState.manhattanDistance} + ${puzzleState.linearConflict}");

    PuzzleAnswer? solvingStep =
        await puzzleStateSolver.solvePuzzle(puzzleState);
    expect(solvingStep != null, true);
    expect((solvingStep?.moves ?? 11) <= 15, true);

    // print("Moves: ${solvingStep?.moves}");
    // while (solvingStep?.sequence.isNotEmpty ?? false) {
    //   var removeFirst = solvingStep?.sequence.removeFirst();
    //   print(removeFirst);
    //   print(
    //       "MD: ${removeFirst?.manhattanDistance} + ${removeFirst?.linearConflict}");
    //   print("-------------------");
    // }
  });

  test('Medium Puzzle should be solved in 30 steps or less', () async {
    PuzzleState puzzleState = PuzzleState.difficulty(PuzzleDifficulty.medium);

    PuzzleStateSolver puzzleStateSolver = PuzzleStateSolver();
    // print(
    //     "MD: ${puzzleState.manhattanDistance} + ${puzzleState.linearConflict}");

    PuzzleAnswer? solvingStep =
        await puzzleStateSolver.solvePuzzle(puzzleState);
    expect(solvingStep != null, true);
    print("Moves: ${solvingStep?.moves}");
    expect((solvingStep?.moves ?? 11) <= 32, true);

    // while (solvingStep?.sequence.isNotEmpty ?? false) {
    //   var removeFirst = solvingStep?.sequence.removeFirst();
    //   print(removeFirst);
    //   print(
    //       "MD: ${removeFirst?.manhattanDistance} + ${removeFirst?.linearConflict}");
    //   print("-------------------");
    // }
  });

  test('Hard Puzzle should be solved in 60 steps or less', () async {
    PuzzleState puzzleState = PuzzleState.difficulty(PuzzleDifficulty.hard);

    PuzzleStateSolver puzzleStateSolver = PuzzleStateSolver();
    // print(
    //     "MD: ${puzzleState.manhattanDistance} + ${puzzleState.linearConflict}");

    PuzzleAnswer? solvingStep =
        await puzzleStateSolver.solvePuzzle(puzzleState);
    expect(solvingStep != null, true);
    print("Moves: ${solvingStep?.moves}");
    expect((solvingStep?.moves ?? 11) <= 60, true);

    // while (solvingStep?.sequence.isNotEmpty ?? false) {
    //   var removeFirst = solvingStep?.sequence.removeFirst();
    //   print(removeFirst);
    //   print(
    //       "MD: ${removeFirst?.manhattanDistance} + ${removeFirst?.linearConflict}");
    //   print("-------------------");
    // }
  });

  test('Unsolvable puzzle should return null', () async {
    PuzzleState puzzleState = PuzzleState.exactState(const [
      1,
      2,
      3,
      4,
      5,
      6,
      7,
      8,
      9,
      10,
      11,
      15,
      13,
      14,
      12,
      16,
    ]);
    PuzzleStateSolver puzzleStateSolver = PuzzleStateSolver();
    PuzzleAnswer? solvingStep =
        await puzzleStateSolver.solvePuzzle(puzzleState);
    expect(solvingStep, null);
  });
}
