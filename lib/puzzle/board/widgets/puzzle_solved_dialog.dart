import 'package:emojis/emojis.dart';
import 'package:flutter/material.dart';
import 'package:flutter_social_button/flutter_social_button.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:url_launcher/url_launcher.dart';

class PuzzleSolvedDialog extends StatelessWidget {
  final String shareUrl;
  final String imageUrl;

  String _twitterShareUrl(BuildContext context) {
    const shareText =
        "Here's my hard-earned gif from Fawaz's #FlutterPuzzleHack entry";
    final encodedShareText = Uri.encodeComponent(shareText);
    return 'https://twitter.com/intent/tweet?url=$shareUrl&text=$encodedShareText';
  }

  const PuzzleSolvedDialog({
    Key? key,
    required this.shareUrl,
    required this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "${Emojis.partyPopper} Congratulations ${Emojis.partyPopper}",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "Here is the final uncovered gif:",
              ),
            ),
            GestureDetector(
              onTap: () {
                openLink(imageUrl);
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blueAccent),
                ),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.fill,
                  errorBuilder: (
                    BuildContext context,
                    Object error,
                    StackTrace? stackTrace,
                  ) {
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
                      return child;
                    } else {
                      return const Center(
                        child: CircularProgressIndicator.adaptive(),
                      );
                    }
                  },
                  width: Adaptive.w(90),
                  height: Adaptive.h(40),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FlutterSocialButton(
                    onTap: () async {
                      await openLink(_twitterShareUrl(context));
                    },
                    mini: true,
                    buttonType: ButtonType.twitter,
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Share your GIF on Twitter'),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text("DISMISS"),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

/// Opens the given [url] in a new tab of the host browser
Future<void> openLink(String url, {VoidCallback? onError}) async {
  if (await canLaunch(url)) {
    await launch(url, enableJavaScript: true);
  } else if (onError != null) {
    onError();
  }
}
