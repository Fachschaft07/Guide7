import 'dart:math';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:guide7/app-routes.dart';
import 'package:guide7/app.dart';
import 'package:guide7/connect/repository.dart';
import 'package:guide7/localization/app_localizations.dart';
import 'package:guide7/ui/util/ui_util.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

/// View loading preparing the app at the first start.
class FirstStartView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _FirstStartViewState();

  /// Check whether the app does not have initial data loaded and this view is needed.
  static Future<bool> hasInitialDataLoaded() async {
    Repository repository = Repository();

    return (await repository.getHMPeopleRepository().hasCachedPeople());
  }
}

/// State of the first start view.
class _FirstStartViewState extends State<FirstStartView> {
  /// Size of the progress indicator.
  static const double _progressIndicatorSize = 100.0;

  /// Count of lines to show in between the first and the last line.
  static const int _numberOfLinesToShow = 3;

  /// Duration for each letter.
  static const Duration _durationPerLetter = Duration(milliseconds: 120);

  /// Lines to show.
  List<String> _lines;

  /// Total duration of the animation.
  Duration _animDuration;

  /// Future loading initial data.
  Future<void> _initialLoadingFuture;

  /// Load all initial app data.
  Future<void> _loadInitialAppData() async {
    Repository repository = Repository();

    // Load HM people
    await repository.getHMPeopleRepository().loadPeople(); // Will cache automatically after load.

    // Load notice board so the user does not have to wait when he is navigated to the start page.
    await repository.getNoticeBoardRepository().loadEntries(); // Will cache entries automatically after load.
  }

  @override
  void initState() {
    super.initState();

    _initialLoadingFuture = _loadInitialAppData();
  }

  @override
  Widget build(BuildContext context) {
    if (_lines == null) {
      AppLocalizations localizations = AppLocalizations.of(context);

      _lines = [localizations.firstStartFirstLine];
      _lines.addAll(_getRandomLines(_numberOfLinesToShow, localizations.firstStartLines));
      _lines.add(localizations.firstStartLastLine);

      int letterCount = _lines.map((line) => line.length).reduce((value, length) => value + length);
      _animDuration = Duration(milliseconds: letterCount * _durationPerLetter.inMilliseconds);

      Future<void> minDurationFuture = Future.delayed(_animDuration);

      print("Letter count: $letterCount with Duration $_animDuration");

      /// Wait for both futures, then navigate to start view.
      Future.wait([
        minDurationFuture,
        _initialLoadingFuture,
      ]).then((values) {
        App.router.navigateTo(context, AppRoutes.noticeBoard, transition: TransitionType.native, replace: true);
      });
    }

    return UIUtil.getScaffold(
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Center(
              child: SizedBox(
                height: _progressIndicatorSize,
                width: _progressIndicatorSize,
                child: CircularProgressIndicator(
                  strokeWidth: 3.0,
                ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                  child: Row(), // Empty row
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: _progressIndicatorSize / 2 + 30.0,
                      left: 40.0,
                      right: 40.0,
                    ),
                    child: FadeAnimatedTextKit(
                      text: _lines,
                      textStyle: TextStyle(
                        fontSize: 30.0,
                        color: Colors.black87,
                      ),
                      alignment: Alignment.topCenter,
                      textAlign: TextAlign.center,
                      isRepeatingAnimation: false,
                      duration: _animDuration,
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

  /// Get [lineCount] random lines from the passed [sourceLines].
  List<String> _getRandomLines(int lineCount, List<String> sourceLines) {
    Random rng = Random();

    assert(sourceLines.length >= lineCount);

    List<String> lineSet = sourceLines.sublist(0);
    List<String> lines = List<String>();
    int counter = 0;
    while (counter < lineCount) {
      lines.add(lineSet.removeAt(rng.nextInt(sourceLines.length - counter)));

      counter++;
    }

    return lines;
  }
}
