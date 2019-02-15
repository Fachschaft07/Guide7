import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:guide7/util/notification/notification_manager_interface.dart';
import 'package:guide7/util/notification/payload_handler/payload_handler.dart';
import 'package:guide7/util/notification/payload_handler/payload_handlers.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Notification Manager abstraction for the local flutter notifications plugin.
class LocalFlutterNotificationManager implements NotificationManagerI {
  /// Key of the last notification id in shared preferences.
  static const String _idKey = "last_notification_id";

  /// Notification channel id for the apps notifications on Android.
  static const String _androidNotificationChannelId = "guide7";

  /// Notification channel name for the apps notifications on Android.
  static const String _androidNotificationChannelName = "Guide7";

  /// Notification channel description for the apps notifications on Android.
  static const String _androidNotificationChannelDescription = "guide7";

  /// Instance of the local flutter notifications plugin.
  FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  /// Get a notifications plugin instance.
  Future<FlutterLocalNotificationsPlugin> getNotificationsPlugin() async {
    if (_flutterLocalNotificationsPlugin == null) {
      await initialize();
    }

    return _flutterLocalNotificationsPlugin;
  }

  @override
  Future<void> initialize() async {
    var initializationSettingsAndroid = AndroidInitializationSettings("@drawable/plain_icon");
    var initializationSettingsIOS = IOSInitializationSettings();
    var initializationSettings = InitializationSettings(initializationSettingsAndroid, initializationSettingsIOS);

    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onSelectNotification: onSelectNotification,
    );
  }

  /// What to do in case the notification has been clicked.
  Future onSelectNotification(String payload) async {
    for (PayloadHandler handler in PayloadHandlers.payloadHandlers) {
      try {
        if (await handler.handle(payload)) {
          break;
        }
      } catch (e) {
        // Do nothing, just skip handler.
      }
    }
  }

  @override
  Future<int> showNotification({
    String title,
    String content,
    String payload,
  }) async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      _androidNotificationChannelId,
      _androidNotificationChannelName,
      _androidNotificationChannelDescription,
      importance: Importance.Max,
      priority: Priority.High,
    );
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();

    var platformChannelSpecifics = new NotificationDetails(
      androidPlatformChannelSpecifics,
      iOSPlatformChannelSpecifics,
    );

    int notificationId = await _getNextId();

    await (await getNotificationsPlugin()).show(
      notificationId,
      title,
      content,
      platformChannelSpecifics,
      payload: payload,
    );

    return notificationId;
  }

  /// Get next notification id.
  Future<int> _getNextId() async {
    final prefs = await SharedPreferences.getInstance();

    // Get last id or 0 if not yet set.
    final lastId = prefs.getInt(_idKey) ?? 0;
    final nextId = lastId + 1;

    // Store next id.
    await prefs.setInt(_idKey, nextId);

    return nextId;
  }
}
