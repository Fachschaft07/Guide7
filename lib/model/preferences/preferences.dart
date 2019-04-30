import 'package:guide7/app-routes.dart';

/// Preferences of the app.
class Preferences {
  /// Whether to show notice board notifications.
  bool showNoticeBoardNotifications;

  /// Whether to show week plan notifications.
  bool showWeekPlanNotifications;

  /// Whether to show appointment notifications.
  bool showAppointmentNotifications;

  /// The starting route after splash screen.
  String startRoute;

  /// Create preferences.
  Preferences({
    this.showNoticeBoardNotifications = true,
    this.showWeekPlanNotifications = true,
    this.showAppointmentNotifications = true,
    this.startRoute = AppRoutes.noticeBoard,
  });
}
