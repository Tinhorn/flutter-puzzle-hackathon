import 'package:flutter/material.dart';
import 'package:flutter_puzzle_hack/puzzle/board/model/puzzle_board_state.dart';
import 'package:flutter_puzzle_hack/puzzle/board/widgets/puzzle_board.dart';
import 'package:flutter_puzzle_hack/puzzle/board/widgets/puzzle_state_controls.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

final AutoDisposeChangeNotifierProvider<PuzzleBoardState>
    puzzleBoardStateProvider =
    ChangeNotifierProvider.autoDispose<PuzzleBoardState>((ref) {
  return PuzzleBoardState();
});

final AutoDisposeProvider<FocusNode> textFieldFocusNodeProvider =
    Provider.autoDispose<FocusNode>((ref) {
  return FocusNode();
});
final AutoDisposeProvider<FocusNode> puzzleFocusNodeProvider =
    Provider.autoDispose<FocusNode>((ref) {
  return FocusNode();
});

void main() {
  runApp(const ProviderScope(
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      navigatorObservers: [FlutterSmartDialog.observer],
      builder: FlutterSmartDialog.init(),
      home: ResponsiveSizer(builder: (context, orientation, screenType) {
        return const MyHomePage(
          title: 'Flutter Demo Home Page',
        );
      }),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false, //new line
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Flutter Puzzle Hackathon",
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              PuzzleBoard(),
              PuzzleStateControls()
            ],
          ),
        ),
      ),
    );
  }
}
