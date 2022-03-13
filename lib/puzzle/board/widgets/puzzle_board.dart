import 'package:emojis/emojis.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_puzzle_hack/main.dart';
import 'package:flutter_puzzle_hack/puzzle/board/model/puzzle_board_state.dart';
import 'package:flutter_puzzle_hack/puzzle/board/widgets/puzzle_solved_dialog.dart';
import 'package:flutter_puzzle_hack/puzzle/model/puzzle_state.dart';
import 'package:flutter_puzzle_hack/puzzle/model/tile.dart';
import 'package:flutter_puzzle_hack/puzzle/puzzle_tile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class PuzzleBoard extends ConsumerWidget {
  const PuzzleBoard({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    PuzzleBoardState puzzleBoardState = ref.watch(puzzleBoardStateProvider);
    FocusNode textFocusNode = ref.watch(textFieldFocusNodeProvider);
    FocusNode puzzleFocusNode = ref.watch(puzzleFocusNodeProvider);

    return RawKeyboardListener(
      focusNode: puzzleFocusNode,
      autofocus: true,
      onKey: (event) {
        if (event is! RawKeyDownEvent) {
          return;
        }
        if (puzzleBoardState.solved ||
            puzzleBoardState.solving ||
            puzzleBoardState.solvingPlayback) {
          return;
        }
        Tile? movableTile;

        if (event.isKeyPressed(LogicalKeyboardKey.arrowUp)) {
          movableTile = puzzleBoardState.movableTiles[TileDirection.up];
        } else if (event.isKeyPressed(LogicalKeyboardKey.arrowDown)) {
          movableTile = puzzleBoardState.movableTiles[TileDirection.down];
        } else if (event.isKeyPressed(LogicalKeyboardKey.arrowLeft)) {
          movableTile = puzzleBoardState.movableTiles[TileDirection.left];
        } else if (event.isKeyPressed(LogicalKeyboardKey.arrowRight)) {
          movableTile = puzzleBoardState.movableTiles[TileDirection.right];
        }
        if (movableTile != null) {
          puzzleBoardState.moveTile(movableTile.currentNum,
              hintDeviationCallback: () {
            showHintDeviationMessage(context);
          });
        }

        if (event.isKeyPressed(LogicalKeyboardKey.arrowDown)) {
          textFocusNode.skipTraversal = true;
        }

        SchedulerBinding.instance?.addPostFrameCallback((timeStamp) {
          FocusScope.of(context).requestFocus(puzzleFocusNode);
        });
        if (puzzleBoardState.solved) {
          puzzleCompleted(
            context,
            puzzleBoardState.currentGif?.imageUrl.originalUrl,
            puzzleBoardState.currentGif?.bitly_url,
          );
        }
      },
      child: Center(
        child: SizedBox(
          width: Adaptive.w(90),
          height: Adaptive.h(40),
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              PuzzleTile.width = (constraints.maxWidth / 4);
              PuzzleTile.height = (constraints.maxHeight / 4);
              return SizedBox(
                child: Stack(
                  children: [
                    Image.network(
                      puzzleBoardState.currentGif?.imageUrl.originalUrl ??
                          "https://media.giphy.com/media/E89xxATM4iZoPdr6Tb/giphy.gif",
                      fit: BoxFit.fill,
                      errorBuilder: (
                        BuildContext context,
                        Object error,
                        StackTrace? stackTrace,
                      ) {
                        showImageErrorSnackBar(context);
                        SchedulerBinding.instance
                            ?.addPostFrameCallback((timeStamp) {
                          puzzleBoardState.loadingPicture = false;
                        });
                        return Center(
                          child: Text(error.toString()),
                        );
                      },
                      loadingBuilder: (
                        BuildContext context,
                        Widget child,
                        ImageChunkEvent? loadingProgress,
                      ) {
                        if (loadingProgress == null) {
                          if (puzzleBoardState.loadingPicture == true) {
                            SchedulerBinding.instance
                                ?.addPostFrameCallback((timeStamp) {
                              puzzleBoardState.loadingPicture = false;
                            });
                          }
                          return child;
                        } else {
                          SchedulerBinding.instance
                              ?.addPostFrameCallback((timeStamp) {
                            puzzleBoardState.loadingPicture = true;
                          });
                          return const Center(
                            child: CircularProgressIndicator.adaptive(),
                          );
                        }
                      },
                      width: Adaptive.w(90),
                      height: Adaptive.h(40),
                    ),
                    PuzzleTile(
                      tile: puzzleBoardState.emptyTile,
                      puzzleSolved: puzzleBoardState.solved,
                      onPressed: () {},
                    ),
                    ...puzzleBoardState.puzzleState.tiles
                        .map((tile) => PuzzleTile(
                            highlight: puzzleBoardState.highlightTile(tile),
                            puzzleSolved: puzzleBoardState.solved,
                            tileMovable: puzzleBoardState.tileMovable(tile),
                            onPressed: () {
                              if (!puzzleBoardState.solvingPlayback) {
                                puzzleBoardState.moveTile(tile.currentNum,
                                    hintDeviationCallback: () {
                                  showHintDeviationMessage(context);
                                });
                              }
                              if (puzzleBoardState.solved) {
                                puzzleCompleted(
                                    context,
                                    puzzleBoardState
                                        .currentGif?.imageUrl.originalUrl,
                                    puzzleBoardState.currentGif?.bitly_url);
                              }
                            },
                            tile: tile))
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

void showImageErrorSnackBar(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text(
        "Image Loading from Network Failure. ${Emojis.disappointedFace}",
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

void puzzleCompleted(
    BuildContext context, String? imageUrl, String? twitterShareUrl) {
  Future.delayed(const Duration(seconds: 1), () {
    showDialog(
        context: context,
        builder: (context) {
          return PuzzleSolvedDialog(
            shareUrl: twitterShareUrl ?? "https://gph.is/g/E165BLR",
            imageUrl: imageUrl ??
                "https://media.giphy.com/media/E89xxATM4iZoPdr6Tb/giphy.gif",
          );
        });
  });
}

void showHintDeviationMessage(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text(
        "Hint Deviation Detected, Tap Hint to get hints back",
      ),
      duration: Duration(milliseconds: 1500),
      backgroundColor: Colors.greenAccent,
      padding: EdgeInsets.all(
        8.0, // Inner padding for SnackBar content.
      ),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
