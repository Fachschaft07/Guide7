import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:guide7/app-routes.dart';
import 'package:guide7/localization/app_localizations.dart';
import 'package:guide7/localization/app_localizations_delegate.dart';
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
  @override
  void initState() {
    super.initState();

    _setupRouter();
    _setupScheduler();
    _setupNotificationManager();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        onGenerateTitle: (BuildContext context) => AppLocalizations.of(context).title,
        localizationsDelegates: [
          AppLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: AppLocalizationsDelegate.supportedLocales,
        theme: ThemeData(
          primarySwatch: MaterialColor(
            0xFFEEF0F2,
            <int, Color>{
              50: Color(0xFFEEF0F2),
              100: Color(0xFFD4D9DE),
              200: Color(0xFFB8C0C8),
              300: Color(0xFF9BA6B1),
              400: Color(0xFF8593A1),
              500: Color(0xFF708090),
              600: Color(0xFF687888),
              700: Color(0xFF5D6D7D),
              800: Color(0xFF536373),
              900: Color(0xFF415061),
            },
          ),
          fontFamily: "Roboto",
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
    NotificationManager().initialize();
  }
}
