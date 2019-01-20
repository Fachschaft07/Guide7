import 'package:fluro/fluro.dart';
import 'package:flutter/widgets.dart';
import 'package:guide7/ui/view/appointment/appointment_view.dart';
import 'package:guide7/ui/view/login/login_view.dart';
import 'package:guide7/ui/view/privacy_policy_statement/privacy_policy_statement_view.dart';
import 'package:guide7/ui/view/room_search/room_search_view.dart';
import 'package:guide7/ui/view/settings_view/settings_view.dart';
import 'package:guide7/ui/view/settings_view/test_bench/test_bench_view.dart';
import 'package:guide7/ui/view/splash_screen/splash_screen_view.dart';
import 'package:guide7/ui/view/view_holder.dart';

/// Routes (for navigation) are defined here.
class AppRoutes {
  /// Root view of the application.
  static const String root = "/";

  /// Route to the login view.
  static const String login = "/login";

  /// Route to the main view holder handling further navigation.
  static const String main = "/main";

  /// Route to the notice board view.
  static const String noticeBoard = "$main/notice-board";

  /// Route to the week plan view.
  static const String weekPlan = "$main/week-plan";

  /// Route to the settings view.
  static const String settings = "/settings";

  /// Route to the appointment view.
  static const String appointments = "/appointments";

  /// Route to the privacy policy statement.
  static const String privacyPolicyStatement = "/privacy-policy-statement";

  /// Route to the room search view.
  static const String roomSearch = "/room-search";

  /// Route to the test bench view.
  static const String testBench = "/test-bench";

  /// Configure all application routes.
  static void configureRoutes(Router router) {
    router.notFoundHandler = new Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      print("Requested route could not be found.");
    });

    router.define(AppRoutes.root, handler: Handler(handlerFunc: (BuildContext context, Map<String, dynamic> params) => SplashScreenView()));
    router.define(AppRoutes.login, handler: Handler(handlerFunc: (BuildContext context, Map<String, dynamic> params) => LoginView()));
    router.define(AppRoutes.main, handler: Handler(handlerFunc: (BuildContext context, Map<String, dynamic> params) => ViewHolder(viewIndex: 0)));
    router.define(AppRoutes.noticeBoard, handler: Handler(handlerFunc: (BuildContext context, Map<String, dynamic> params) => ViewHolder(viewIndex: 0)));
    router.define(AppRoutes.weekPlan, handler: Handler(handlerFunc: (BuildContext context, Map<String, dynamic> params) => ViewHolder(viewIndex: 1)));
    router.define(AppRoutes.settings, handler: Handler(handlerFunc: (BuildContext context, Map<String, dynamic> params) => SettingsView()));
    router.define(AppRoutes.appointments, handler: Handler(handlerFunc: (BuildContext context, Map<String, dynamic> params) => AppointmentView()));
    router.define(AppRoutes.privacyPolicyStatement,
        handler: Handler(handlerFunc: (BuildContext context, Map<String, dynamic> params) => PrivacyPolicyStatementView()));
    router.define(AppRoutes.roomSearch, handler: Handler(handlerFunc: (BuildContext context, Map<String, dynamic> params) => RoomSearchView()));
    router.define(AppRoutes.testBench, handler: Handler(handlerFunc: (BuildContext context, Map<String, dynamic> params) => TestBenchView()));
  }
}
