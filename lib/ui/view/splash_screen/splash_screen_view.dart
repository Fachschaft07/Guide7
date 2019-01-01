import 'dart:async';

import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:guide7/app-routes.dart';
import 'package:guide7/app.dart';
import 'package:guide7/connect/login/zpa/response/zpa_login_response.dart';
import 'package:guide7/connect/repository.dart';
import 'package:guide7/model/credentials/username_password_credentials.dart';
import 'package:guide7/ui/common/headline.dart';

/// Splash screen of the application.
/// It redirects to the correct starting view (Login if user already logged in).
class SplashScreenView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SplashScreenState();
}

/// State of the splash screen redirecting to the correct starting view.
class _SplashScreenState extends State<SplashScreenView> {
  /// Duration the splash screen is shown.
  static const Duration _duration = Duration(seconds: 2);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    double imageWidth;
    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      imageWidth = size.width / 2;
    } else {
      imageWidth = size.width / 4;
    }

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "res/images/guide7_logo.png",
              width: imageWidth,
            ),
            Container(
              child: Headline("Guide7"),
              padding: EdgeInsets.only(top: 20.0),
            ),
            Text("Eine App der Fachschaft 07")
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    _startTimer();
  }

  /// Start the splash screen timer.
  Future<Timer> _startTimer() async {
    return Timer(_SplashScreenState._duration, _navigateToStartView);
  }

  /// Navigate to the starting view of the application.
  void _navigateToStartView() async {
    if (await isLoggedIn()) {
      _gotoNoticeBoard();
    } else {
      _gotoLoginView();
    }
  }

  /// Check if a user is currently logged in.
  Future<bool> isLoggedIn() async {
    Repository repo = Repository();

    UsernamePasswordCredentials credentials = await repo.getLocalCredentialsRepository().loadLocalCredentials();
    ZPALoginResponse response = await repo.getZPALoginRepository().tryLogin(credentials);

    return response != null;
  }

  /// Navigate to login view.
  void _gotoLoginView() {
    App.router.navigateTo(context, AppRoutes.login, transition: TransitionType.inFromBottom, replace: true);
  }

  /// Navigate to notice board.
  void _gotoNoticeBoard() {
    App.router.navigateTo(context, AppRoutes.main, transition: TransitionType.inFromBottom, replace: true);
  }
}
