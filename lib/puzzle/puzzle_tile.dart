import 'package:flutter/material.dart';
import 'package:flutter_puzzle_hack/puzzle/model/tile.dart';

class PuzzleTile extends StatelessWidget {
  final VoidCallback? onPressed;
  final Tile tile;
  final bool highlight;
  final bool puzzleSolved;
  final bool tileMovable;

  const PuzzleTile({
    Key? key,
    this.onPressed,
    required this.tile,
    this.highlight = false,
    this.puzzleSolved = false,
    this.tileMovable = false,
  }) : super(key: key);

  static double width = 60;
  static double height = 60;

  @override
  Widget build(BuildContext context) {
    const animDuration = Duration(milliseconds: 500);
    return AnimatedPositioned(
        duration: animDuration,
        left: tile.position.dx + 2,
        top: tile.position.dy + 2,
        child: AnimatedOpacity(
          opacity: puzzleSolved ? 0 : 1,
          duration: animDuration,
          child: tile.correctNum == 16
              ? Container(
                  height: PuzzleTile.height - 4,
                  width: PuzzleTile.width - 4,
                  decoration: _appropriateDeco(),
                )
              : AnimatedContainer(
                  duration: const Duration(seconds: 1),
                  decoration: _appropriateDeco(),
                  height: PuzzleTile.height - 4,
                  width: PuzzleTile.width - 4,
                  child: TextButton(
                    onPressed: tileMovable ? onPressed : null,
                    child: Center(
                      child: Text("${tile.correctNum}"),
                    ),
                  ),
                ),
        ));
  }

  BoxDecoration _appropriateDeco() {
    bool isCorrect = tile.currentNum == tile.correctNum;
    BoxDecoration boxDecoration = const BoxDecoration(color: Colors.white);

    if (tile.correctNum == 16) {
      boxDecoration = boxDecoration.copyWith(
        color: Colors.white,
        border: Border.all(color: Colors.blueAccent),
      );
    }
    if (isCorrect) {
      boxDecoration = boxDecoration.copyWith(
        color: Colors.white.withOpacity(0.3),
      );
    }

    if (tileMovable) {
      boxDecoration = boxDecoration.copyWith(
        color: Colors.white,
        border: Border.all(color: Colors.greenAccent),
      );
    }

    if (highlight) {
      boxDecoration = boxDecoration.copyWith(
        color: Colors.greenAccent,
        border: Border.all(color: Colors.blueAccent),
      );
    }

    return boxDecoration;
  }
}
