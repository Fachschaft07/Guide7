import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:guide7/app-routes.dart';
import 'package:guide7/ui/view/splash_screen/splash_screen_view.dart';
import 'package:guide7/util/scheduler/scheduler.dart';

/// Entry point for the application.
void main() {
  runApp(App());

  onAppTermination();
}

/// What to do when the app terminates.
Future<void> onAppTermination() async {
  Scheduler().onAppTermination();
}

class App extends StatelessWidget {
  /// Router used to navigate within the application.
  static Router router;

  /// Create the application.
  App() {
    _setupRouter();
    _setupScheduler();
  }

  /// Setup the router used to navigate in the app.
  void _setupRouter() {
    App.router = Router();
    AppRoutes.configureRoutes(App.router);
  }

  /// Setup the applications scheduler scheduling background tasks.
  void _setupScheduler() {
    Scheduler().onInit();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Guide7",
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'NotoSerifTC',
      ),
      onGenerateRoute: App.router.generator,
      home: SplashScreenView(),
    );
  }
}
