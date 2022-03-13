import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:slide_countdown/slide_countdown.dart';

class PuzzleSolvingLoadingDialog extends StatefulWidget {
  final Future<void> puzzleAnswerFuture;
  final bool solved;

  const PuzzleSolvingLoadingDialog({
    Key? key,
    required this.puzzleAnswerFuture,
    this.solved = false,
  }) : super(key: key);

  @override
  State<PuzzleSolvingLoadingDialog> createState() =>
      _PuzzleSolvingLoadingDialogState();
}

class _PuzzleSolvingLoadingDialogState
    extends State<PuzzleSolvingLoadingDialog> {
  final String loadingMsg = "Solving Puzzle...";
  final String doneMsg = "Done!";
  bool isDone = false;
  bool isFinishedWithError = false;

  @override
  void initState() {
    super.initState();
    isDone = false;
    widget.puzzleAnswerFuture.then((value) {
      setState(() {
        isDone = true;
        Future.delayed(const Duration(seconds: 1), () {
          SchedulerBinding.instance?.addPostFrameCallback((timeStamp) {
            if (mounted) {
              Navigator.of(context, rootNavigator: true).pop();
            }
          });
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator.adaptive(),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(isDone ? doneMsg : loadingMsg),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Visibility(
                    visible: !isDone,
                    child: const SlideCountdownSeparated(
                      duration: Duration(minutes: 1),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Future showPuzzleSolvingDialog(
    BuildContext context, Future<void> solvePuzzleFuture,
    {bool solved = false}) {
  return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return PuzzleSolvingLoadingDialog(
          puzzleAnswerFuture: solvePuzzleFuture,
          solved: solved,
        );
      });
}
