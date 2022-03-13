import 'package:emojis/emojis.dart';
import 'package:flutter/material.dart';
import 'package:flutter_puzzle_hack/main.dart';
import 'package:flutter_puzzle_hack/puzzle/board/model/puzzle_board_state.dart';
import 'package:flutter_puzzle_hack/puzzle/board/widgets/puzzle_solving_loading_dialog.dart';
import 'package:flutter_puzzle_hack/puzzle/model/puzzle_state.dart';
import 'package:flutter_puzzle_hack/util/StringExtension.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PuzzleStateControls extends ConsumerStatefulWidget {
  const PuzzleStateControls({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _PuzzleStateControlsState();
}

class _PuzzleStateControlsState extends ConsumerState<PuzzleStateControls> {
  TextEditingController gifSearchTermTEC = TextEditingController();

  @override
  Widget build(BuildContext context) {
    PuzzleBoardState puzzleBoardState = ref.watch(puzzleBoardStateProvider);
    FocusNode textFocusNode = ref.watch(textFieldFocusNodeProvider);
    FocusNode puzzleFocusNode = ref.watch(puzzleFocusNodeProvider);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                focusNode: textFocusNode,
                controller: gifSearchTermTEC,
                textAlign: TextAlign.center,
                onTap: () {
                  textFocusNode.requestFocus();
                  puzzleFocusNode.unfocus();
                },
                onEditingComplete: () {
                  textFocusNode.unfocus();
                  puzzleFocusNode.requestFocus();
                },
                decoration: const InputDecoration(
                  alignLabelWithHint: true,
                  label: Text("Gif Search Term"),
                  hintText: "Meme, Dog, e.t.c",
                ),
              )),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    "Difficulty: ",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                DropdownButton<PuzzleDifficulty>(
                    hint: const Text("Difficulty"),
                    value: puzzleBoardState.difficulty,
                    items: PuzzleDifficulty.values
                        .map((e) => DropdownMenuItem<PuzzleDifficulty>(
                              child: Text(
                                e.name.capitalize(),
                              ),
                              value: e,
                            ))
                        .toList(),
                    onChanged: puzzleBoardState.solving ||
                            puzzleBoardState.solvingPlayback
                        ? null
                        : (PuzzleDifficulty? difficulty) {
                            if (difficulty == null) {
                              return;
                            }
                            puzzleBoardState.difficulty = difficulty;
                          }),
              ],
            ),
          ),
          Focus(
            onFocusChange: (focusChange) {
              if (focusChange) {
                FocusScope.of(context).requestFocus(puzzleFocusNode);
              }
            },
            child: TextButton(
              onPressed:
                  puzzleBoardState.solving || puzzleBoardState.solvingPlayback
                      ? null
                      : () async {
                          await puzzleBoardState.shufflePuzzle(
                              gifSearchTerm: gifSearchTermTEC.text);
                          if (puzzleBoardState.currentGif == null) {
                            if (mounted) {
                              showGifErrorMessage(context);
                            }
                          }
                        },
              child: const Text("Shuffle"),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Focus(
                  onFocusChange: (focusChange) {
                    if (focusChange) {
                      FocusScope.of(context).requestFocus(puzzleFocusNode);
                    }
                  },
                  child: TextButton(
                    onPressed: puzzleBoardState.solving ||
                            puzzleBoardState.solvingPlayback ||
                            puzzleBoardState.hintMode ||
                            puzzleBoardState.solved
                        ? null
                        : () {
                            Future<void> solvePuzzleFuture =
                                puzzleBoardState.solvePuzzle();
                            showPuzzleSolvingDialog(context, solvePuzzleFuture)
                                .then((value) {
                              if (puzzleBoardState.currentAnswer == null) {
                                showPuzzleTimeoutSnackBar(context);
                              }
                            });
                          },
                    child: const Text("Hint"),
                  ),
                ),
                Focus(
                  onFocusChange: (focusChange) {
                    if (focusChange) {
                      FocusScope.of(context).requestFocus(puzzleFocusNode);
                    }
                  },
                  child: TextButton(
                    onPressed: puzzleBoardState.solving ||
                            puzzleBoardState.solvingPlayback ||
                            puzzleBoardState.solving ||
                            puzzleBoardState.solved
                        ? null
                        : () {
                            Future<void> solvePuzzleFuture =
                                puzzleBoardState.solvePuzzle();
                            showPuzzleSolvingDialog(context, solvePuzzleFuture,
                                    solved: true)
                                .then((value) {
                              if (puzzleBoardState.currentAnswer != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Playing Solution...',
                                    ),
                                    duration: Duration(milliseconds: 1500),
                                    backgroundColor: Colors.green,
                                    padding: EdgeInsets.all(
                                      8.0, // Inner padding for SnackBar content.
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                                puzzleBoardState.startPlayback().then((value) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Puzzle Solved ${Emojis.smilingFace}',
                                      ),
                                      duration: Duration(milliseconds: 1500),
                                      backgroundColor: Colors.green,
                                      padding: EdgeInsets.all(
                                        8.0, // Inner padding for SnackBar content.
                                      ),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                });
                              } else {
                                showPuzzleTimeoutSnackBar(context);
                              }
                            });
                          },
                    child: const Text("Solve"),
                  ),
                ),
              ],
            ),
          ),
          Visibility(
            visible: puzzleBoardState.solvingPlayback ||
                puzzleBoardState.loadingPicture,
            child: const LinearProgressIndicator(),
          ),
        ],
      ),
    );
  }
}

void showPuzzleTimeoutSnackBar(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text(
        'Puzzle Solving Timeout ${Emojis.grimacingFace}',
      ),
      duration: Duration(milliseconds: 1500),
      backgroundColor: Colors.red,
      padding: EdgeInsets.all(
        8.0, // Inner padding for SnackBar content.
      ),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

void showGifErrorMessage(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text(
        "Couldn't find a random GIF with your terms, Falling back to Dash. ${Emojis.disappointedFace}",
      ),
      duration: Duration(milliseconds: 1500),
      backgroundColor: Colors.red,
      padding: EdgeInsets.all(
        8.0, // Inner padding for SnackBar content.
      ),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
