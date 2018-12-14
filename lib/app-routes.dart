import 'package:fluro/fluro.dart';
import 'package:flutter/widgets.dart';
import 'package:guide7/ui/view/login/login_view.dart';
import 'package:guide7/ui/view/notice_board/notice_board_view.dart';
import 'package:guide7/ui/view/splash_screen/splash_screen_view.dart';

/// Routes (for navigation) are defined here.
class AppRoutes {
  /// Root view of the application.
  static const String root = "/";

  /// Route to the login view.
  static const String login = "/login";

  /// Route to the notice board view.
  static const String notice_board = "/notice_board";

  /// Configure all application routes.
  static void configureRoutes(Router router) {
    router.notFoundHandler = new Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      print("Requested route could not be found.");
    });

    router.define(AppRoutes.root, handler: Handler(handlerFunc: (BuildContext context, Map<String, dynamic> params) => SplashScreenView()));
    router.define(AppRoutes.login, handler: Handler(handlerFunc: (BuildContext context, Map<String, dynamic> params) => LoginView()));
    router.define(AppRoutes.notice_board, handler: Handler(handlerFunc: (BuildContext context, Map<String, dynamic> params) => NoticeBoardView()));
  }
}
