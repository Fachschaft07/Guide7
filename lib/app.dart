import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:guide7/app-routes.dart';
import 'package:guide7/ui/view/splash_screen/splash_screen_view.dart';
import 'package:guide7/util/notification/notification_manager.dart';
import 'package:guide7/util/scheduler/scheduler.dart';

/// The applications main widget.
class App extends StatefulWidget {
  /// Router used to navigate within the application.
  static Router router;

  @override
  State<StatefulWidget> createState() => _AppState();
}

/// State of the applications main widget.
class _AppState extends State<App> {
  /// Title of the application.
  static const String _appTitle = "Guide7";

  @override
  void initState() {
    super.initState();

    _setupRouter();
    _setupScheduler();
    _setupNotificationManager();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: _appTitle,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: 'NotoSerifTC',
        ),
        onGenerateRoute: App.router.generator,
        home: SplashScreenView(),
      );

  /// Setup the router used to navigate in the app.
  void _setupRouter() {
    App.router = Router();
    AppRoutes.configureRoutes(App.router);
  }

  /// Setup the applications scheduler scheduling background tasks.
  void _setupScheduler() {
    Scheduler().onInit();
  }

  /// Setup the applications notification manager to fire local notifications.
  void _setupNotificationManager() {
    NotificationManager().initialize(context);
  }
}
