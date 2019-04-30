import 'dart:async';

import 'package:guide7/model/preferences/preferences.dart';
import 'package:guide7/storage/storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Storage storing the apps preferences.
class PreferencesStorage implements Storage<Preferences> {
  /// Base key in the shared preferences.
  static const String _baseKey = "preferences";

  /// Key of the "show notice board notifications" preference.
  static const String _showNoticeBoardNotificationsKey = "show_notice_board_notifications";

  /// Key of the "show week plan notifications" preference.
  static const String _showWeekPlanNotificationsKey = "show_week_plan_notifications";

  /// Key of the "show appointment notifications" preference.
  static const String _showAppointmentNotificationsKey = "show_appointment_notifications";

  /// Instance of the singleton.
  static const PreferencesStorage _instance = PreferencesStorage._internal();

  /// Factory constructor for the singleton.
  factory PreferencesStorage() => _instance;

  /// Internal constructor.
  const PreferencesStorage._internal();

  @override
  Future<void> clear() async {
    SharedPreferences prefs = await _getPrefs();

    for (final key in prefs.getKeys().where((key) => key.startsWith(_baseKey)).toList(growable: false)) {
      await prefs.remove(key);
    }
  }

  @override
  Future<bool> isEmpty() async {
    SharedPreferences prefs = await _getPrefs();

    return prefs.getKeys().where((key) => key.contains(_baseKey)).isEmpty;
  }

  @override
  Future<Preferences> read() async {
    SharedPreferences prefs = await _getPrefs();

    bool showNoticeBoardNotifications = prefs.getBool("$_baseKey.$_showNoticeBoardNotificationsKey") ?? true;
    bool showWeekPlanNotifications = prefs.getBool("$_baseKey.$_showWeekPlanNotificationsKey") ?? true;
    bool showAppointmentNotifications = prefs.getBool("$_baseKey.$_showAppointmentNotificationsKey") ?? true;

    return Preferences(
      showNoticeBoardNotifications: showNoticeBoardNotifications,
      showWeekPlanNotifications: showWeekPlanNotifications,
      showAppointmentNotifications: showAppointmentNotifications,
    );
  }

  @override
  Future<void> write(Preferences data) async {
    SharedPreferences prefs = await _getPrefs();

    await prefs.setBool("$_baseKey.$_showNoticeBoardNotificationsKey", data.showNoticeBoardNotifications);
    await prefs.setBool("$_baseKey.$_showWeekPlanNotificationsKey", data.showWeekPlanNotifications);
    await prefs.setBool("$_baseKey.$_showAppointmentNotificationsKey", data.showAppointmentNotifications);
  }

  /// Get shared preferences.
  Future<SharedPreferences> _getPrefs() async => await SharedPreferences.getInstance();
}
