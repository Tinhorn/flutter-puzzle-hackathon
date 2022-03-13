import 'dart:collection';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter_puzzle_hack/puzzle/model/puzzle_state.dart';

class PuzzleStateSolver {
  static int heapMinPriority(
      PuzzleStateSolvingStep ps1, PuzzleStateSolvingStep ps2) {
    if (ps1.puzzleState.solved && !ps2.puzzleState.solved) {
      return -1;
    } else if (!ps1.puzzleState.solved && ps2.puzzleState.solved) {
      return 1;
    }
    //Less than priority should be first
    else if (ps1.priority < ps2.priority) {
      return -1;
    } else if (ps1.priority > ps2.priority) {
      return 1;
    } else {
      return 0;
    }
  }

  Future<PuzzleAnswer?> solvePuzzle(PuzzleState puzzleState) async {
    PuzzleStateSolvingStep initialStep = PuzzleStateSolvingStep(
      puzzleState: puzzleState,
      moves: 0,
    );
    if (!puzzleState.solvable) {
      return Future.value(null);
    }

    return await idAStar(initialStep);
  }

  Future<PuzzleAnswer> aStar(PuzzleStateSolvingStep currentStep) async {
    PriorityQueue<PuzzleStateSolvingStep> _priorityQueue =
        PriorityQueue(heapMinPriority);
    while (!currentStep.solved) {
      _priorityQueue.addAll(currentStep.populateNextGameState());
      currentStep = _priorityQueue.removeFirst();
    }
    return PuzzleAnswer(currentStep);
  }

  //procedure ida_star(root)
  //     bound := h(root)
  //     path := [root]
  //     loop
  //         t := search(path, 0, bound)
  //         if t = FOUND then return (path, bound)
  //         if t = ∞ then return NOT_FOUND
  //         bound := t
  //     end loop
  // end procedure
  Future<PuzzleAnswer> idAStar(PuzzleStateSolvingStep initialStep) async {
    final ListQueue<PuzzleStateSolvingStep> stack = ListQueue();
    PuzzleStateSolvingStep currentStep = initialStep;
    int bound = initialStep.priority;
    stack.addFirst(currentStep);

    while (true) {
      BoundedDepthSearchResult depthSearchResult = search(bound, stack);
      if (depthSearchResult.gameState.solved) {
        return PuzzleAnswer(depthSearchResult.gameState);
      } else {
        bound = depthSearchResult.priority;
      }
    }
  }

  //function search(path, g, bound)
  //     node := path.last
  //     f := g + h(node)
  //     if f > bound then return f
  //     if is_goal(node) then return FOUND
  //     min := ∞
  //     for succ in successors(node) do
  //         if succ not in path then
  //             path.push(succ)
  //             t := search(path, g + cost(node, succ), bound)
  //             if t = FOUND then return FOUND
  //             if t < min then min := t
  //             path.pop()
  //         end if
  //     end for
  //     return min
  // end function
  BoundedDepthSearchResult search(
      int bound, ListQueue<PuzzleStateSolvingStep> stack) {
    PuzzleStateSolvingStep currentStep = stack.first;
    int newThreshold = 90000000;

    if (currentStep.puzzleState.solved) {
      return BoundedDepthSearchResult(currentStep, currentStep.priority);
    }

    if (currentStep.priority > bound) {
      return BoundedDepthSearchResult(currentStep, currentStep.priority);
    }

    List<PuzzleStateSolvingStep> nextGameStates =
        currentStep.populateNextGameState();
    for (PuzzleStateSolvingStep step in nextGameStates) {
      stack.addFirst(step);
      BoundedDepthSearchResult searchResult = search(bound, stack);
      if (searchResult.gameState.puzzleState.solved) {
        return searchResult;
      } else {
        newThreshold = min(newThreshold, searchResult.priority);
      }
      stack.removeFirst();
    }

    return BoundedDepthSearchResult(currentStep, newThreshold);
  }
}

class PuzzleStateSolvingStep {
  final PuzzleStateSolvingStep? parent;
  final List<PuzzleStateSolvingStep> nextGamesStates = [];
  final PuzzleState puzzleState;
  final int moves;
  late final int priority;

  PuzzleStateSolvingStep({
    required this.puzzleState,
    required this.moves,
    this.parent,
  }) {
    priority = moves +
        puzzleState.manhattanDistance +
        (2 * puzzleState.linearConflict);
  }

  bool get solved => puzzleState.solved;

  List<PuzzleStateSolvingStep> populateNextGameState() {
    if (nextGamesStates.isNotEmpty) {
      return nextGamesStates;
    }
    addSteps(puzzleState.nextStates(parent?.puzzleState));
    nextGamesStates.sort(PuzzleStateSolver.heapMinPriority);
    return nextGamesStates;
  }

  void addSteps(List<PuzzleState> puzzleStates) {
    for (PuzzleState puzzleState in puzzleStates) {
      //Make sure its not the parent
      if (parent?.puzzleState == puzzleState) {
        return;
      } else {
        //Add Queue with this step as the parent
        var puzzleStateSolvingStep = PuzzleStateSolvingStep(
          puzzleState: puzzleState,
          moves: moves + 1,
          parent: this,
        );
        nextGamesStates.add(puzzleStateSolvingStep);
      }
    }
  }

  @override
  String toString() {
    return 'PuzzleStateSolvingStep{moves: $moves, priority: $priority}';
  }
}

class PuzzleAnswer {
  final ListQueue<PuzzleState> sequence = ListQueue(80);
  late final int moves;

  PuzzleAnswer(
    PuzzleStateSolvingStep solvedGameState,
  ) {
    PuzzleStateSolvingStep currentGameState = solvedGameState;
    moves = solvedGameState.moves;
    sequence.addFirst(currentGameState.puzzleState);
    while (currentGameState.parent != null) {
      currentGameState = currentGameState.parent!;
      sequence.addFirst(currentGameState.puzzleState);
    }
  }

  static void printSequence(PuzzleAnswer? puzzleAnswer) {
    List<PuzzleState> sequence = puzzleAnswer?.sequence.toList() ?? [];
    print("Moves: ${sequence.length - 1}");
    for (PuzzleState puzzleState in sequence) {
      print(puzzleState);
      print(
          "MD: ${puzzleState.manhattanDistance} + ${puzzleState.linearConflict}");
      print("-------------------");
    }
  }
}

class BoundedDepthSearchResult {
  final int priority;
  final PuzzleStateSolvingStep gameState;

  BoundedDepthSearchResult(this.gameState, this.priority);
}

// class PuzzleAnswer {
//   final ListQueue<PuzzleState> sequence = ListQueue(80);
//   late final int moves;
//   late final int priority;
//   late final bool solved;
//
//   PuzzleAnswer(PuzzleStateSolvingStep solvedGameState, this.priority) {
//     PuzzleStateSolvingStep currentGameState = solvedGameState;
//     moves = solvedGameState.moves;
//     solved = solvedGameState.puzzleState.solved;
//     sequence.addFirst(currentGameState.puzzleState);
//     while (currentGameState.parent != null) {
//       currentGameState = currentGameState.parent!;
//       sequence.addFirst(currentGameState.puzzleState);
//     }
//   }
// }
