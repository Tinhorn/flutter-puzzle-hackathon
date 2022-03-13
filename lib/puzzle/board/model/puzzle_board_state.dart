import 'package:flutter/foundation.dart';
import 'package:flutter_puzzle_hack/giphy/models/giphy.dart';
import 'package:flutter_puzzle_hack/puzzle/model/puzzle_state.dart';
import 'package:flutter_puzzle_hack/puzzle/model/puzzle_state_solver.dart';
import 'package:flutter_puzzle_hack/puzzle/model/tile.dart';

class PuzzleBoardState extends ChangeNotifier {
  final GiphyApi _giphyApi = GiphyApi();
  PuzzleAnswer? currentAnswer;
  PuzzleDifficulty _difficulty = PuzzleDifficulty.easy;
  PuzzleState _puzzleState = PuzzleState.fromSolved(
    stepsAway: 0,
  );
  GiphyGifResponse? currentGif;

  bool _hintMode = false;
  bool _solving = false;
  bool _solvingPlayback = false;
  bool _loadingPicture = false;
  Map<TileDirection, Tile> movableTiles = {};

  set difficulty(PuzzleDifficulty puzzleDifficulty) {
    _difficulty = puzzleDifficulty;
    notifyListeners();
  }

  PuzzleDifficulty get difficulty => _difficulty;

  set hintMode(bool hintMode) {
    _hintMode = hintMode;
    notifyListeners();
  }

  set solving(bool solving) {
    _solving = solving;
    notifyListeners();
  }

  bool get solving => _solving;

  bool get hintMode => _hintMode;

  bool get solved => puzzleState.solved;

  set solvingPlayback(bool solvingPlayBack) {
    _solvingPlayback = solvingPlayBack;
    notifyListeners();
  }

  bool get solvingPlayback => _solvingPlayback;

  set loadingPicture(bool loadingPicture) {
    _loadingPicture = loadingPicture;
    notifyListeners();
  }

  bool get loadingPicture => _loadingPicture;

  Future<void> shufflePuzzle({String gifSearchTerm = ""}) async {
    try {
      currentGif = await _giphyApi.random(tag: gifSearchTerm);
      hintMode = false;
      currentAnswer = null;
      _setPuzzleState(PuzzleState.difficulty(difficulty));
      notifyListeners();
    } catch (e) {
      hintMode = false;
      currentAnswer = null;
      currentGif = null;
      _setPuzzleState(PuzzleState.difficulty(difficulty));
      notifyListeners();
    }
  }

  void moveTile(int currentNum, {VoidCallback? hintDeviationCallback}) {
    _setPuzzleState(_puzzleState.swapEmptyTile(currentNum));
    //if answer has been found, move
    if (currentAnswer != null) {
      if (currentAnswer!.sequence.isEmpty) {
        hintMode = false;
        return;
      }
      PuzzleState hintState = currentAnswer!.sequence.removeFirst();
      if (hintState != _puzzleState) {
        hintMode = false;
        currentAnswer = null;
        hintDeviationCallback?.call();
      }
    }
    notifyListeners();
  }

  void _setPuzzleState(PuzzleState puzzleState) {
    _puzzleState = puzzleState;
    movableTiles = _puzzleState.movableTiles;
  }

  bool tileMovable(Tile tile) =>
      movableTiles.values.contains(tile) && !_puzzleState.solved;

  bool highlightTile(Tile tile) {
    if (!hintMode || (currentAnswer?.sequence.isEmpty ?? true)) {
      return false;
    }
    PuzzleState nextState = currentAnswer!.sequence.first;
    return nextState.emptyTile.currentNum == tile.currentNum;
  }

  Future<void> solvePuzzle() async {
    hintMode = true;
    solving = true;
    if (currentAnswer != null) {
      solving = false;
      notifyListeners();
      return;
    }
    PuzzleAnswer? value = await compute(_solve, puzzleState).timeout(
        const Duration(
          minutes: 1,
        ), onTimeout: () {
      return PuzzleAnswer(PuzzleStateSolvingStep(
        puzzleState: puzzleState,
        moves: -1,
      ));
    });

    if (value?.moves != -1) {
      currentAnswer = value;
      PuzzleAnswer.printSequence(currentAnswer);
      //Removing the initial state
      currentAnswer?.sequence.removeFirst();
      solving = false;
    } else {
      //
      currentAnswer = null;
      hintMode = false;
      solving = false;
    }
    notifyListeners();
  }

  PuzzleState get puzzleState => _puzzleState;

  Tile get emptyTile => _puzzleState.emptyTile;

  Future<void> startPlayback() async {
    solvingPlayback = true;
    while (currentAnswer?.sequence.isNotEmpty ?? false) {
      await Future.delayed(const Duration(milliseconds: 500));
      PuzzleState nextState = currentAnswer!.sequence.removeFirst();
      _setPuzzleState(nextState);
      notifyListeners();
    }
    solvingPlayback = false;
    currentAnswer = null;
    notifyListeners();
  }
}

Future<PuzzleAnswer?> _solve(PuzzleState puzzleState) async {
  PuzzleStateSolver puzzleStateSolver = PuzzleStateSolver();
  PuzzleAnswer? solvedPuzzled =
      await puzzleStateSolver.solvePuzzle(puzzleState);
  return solvedPuzzled;
}
