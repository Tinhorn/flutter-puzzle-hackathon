import 'package:flutter_puzzle_hack/puzzle/model/puzzle_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Number of Inversion should be 6', () {
    PuzzleState puzzleState = PuzzleState.exactState(const [
      1,
      2,
      3,
      4,
      5,
      6,
      11,
      8,
      9,
      10,
      12,
      16,
      13,
      14,
      15,
      7,
    ]);
    expect(puzzleState.nInversion, 6);
  });

  test('Number of Inversion should be 3', () {
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
      12,
      16,
      13,
      14,
      15,
      11,
    ]);
    expect(puzzleState.nInversion, 3);
  });

  test('Number of Inversion should be 3 - part 2', () {
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
      16,
      13,
      14,
      15,
      12,
    ]);
    expect(puzzleState.nInversion, 3);
  });

  test('Number of Inversion should be 0', () {
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
      15,
      16,
    ]);
    expect(puzzleState.nInversion, 0);
  });

  test('State should be solvable 1', () {
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
      12,
      16,
      13,
      14,
      15,
      11,
    ]);
    expect(puzzleState.solvable, true);
  });

  test('State should be solvable 2', () {
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
      16,
      13,
      14,
      15,
      12,
    ]);
    expect(puzzleState.solvable, true);
  });

  test('State should be solvable 3', () {
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
      15,
      16,
    ]);
    expect(puzzleState.solvable, true);
  });

  //https://puzzling.stackexchange.com/a/46233
  test('State should not be solvable', () {
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
    expect(puzzleState.solvable, false);
  });

  test('State should not be solvable 2', () {
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
      15,
      14,
      16,
    ]);
    expect(puzzleState.solvable, false);
  });

  test('Manhattan distance should be 1', () {
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
    expect(puzzleState.manhattanDistance, 1);
  });

  test('Manhattan distance should be 24', () {
    PuzzleState puzzleState = PuzzleState.exactState(const [
      2, //1
      3, //2
      12, //3
      6, //4
      5, //5
      8, //6
      7, //7
      11, //8
      10, //9
      9, //10
      4, //11
      15, //12
      16, //13
      13, //14
      14, //15
      1, //16
    ]);

    expect(puzzleState.manhattanDistance, 24);
  });

  test(
    'Linear conflict should be 0',
    () {
      PuzzleState state = PuzzleState.exactState(
          const [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16]);
      expect(state.linearConflict, 0);
    },
  );

  test(
    'Linear conflict should be 1',
    () {
      PuzzleState state = PuzzleState.exactState(
          const [1, 2, 3, 4, 5, 7, 6, 8, 9, 10, 11, 12, 13, 14, 15, 16]);
      expect(state.linearConflict, 1);
    },
  );

  test(
    'Linear conflict should be 1 - Col',
    () {
      PuzzleState state = PuzzleState.exactState(
          const [5, 2, 3, 4, 1, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16]);
      expect(state.linearConflict, 1);
    },
  );

  test(
    'Linear conflict should be 6',
    () {
      PuzzleState state = PuzzleState.exactState(
          const [1, 2, 3, 4, 8, 7, 6, 5, 9, 10, 11, 12, 13, 14, 15, 16]);
      expect(state.linearConflict, 3);
    },
  );
}
