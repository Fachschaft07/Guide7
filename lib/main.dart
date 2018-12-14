import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:guide7/app-routes.dart';
import 'package:guide7/ui/view/splash_screen/splash_screen_view.dart';

/// Entry point for the application.
void main() => runApp(App());

class App extends StatelessWidget {
  /// Router used to navigate within the application.
  static Router router;

  /// Create the application.
  App() {
    _setupRouter();
  }

  /// Setup the router used to navigate in the app.
  void _setupRouter() {
    App.router = Router();
    AppRoutes.configureRoutes(App.router);
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
