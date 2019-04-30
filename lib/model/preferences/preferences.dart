/// Preferences of the app.
class Preferences {
  /// Whether to show notice board notifications.
  bool showNoticeBoardNotifications;

  /// Whether to show week plan notifications.
  bool showWeekPlanNotifications;

  /// Whether to show appointment notifications.
  bool showAppointmentNotifications;

  /// Create preferences.
  Preferences({
    this.showNoticeBoardNotifications = true,
    this.showWeekPlanNotifications = true,
    this.showAppointmentNotifications = true,
  });
}
