import 'package:guide7/util/notification/impl/local_flutter_notification_manager.dart';
import 'package:guide7/util/notification/notification_manager_interface.dart';

/// Singleton notification manager factory providing easy access to the applications default notification manager implementation.
class NotificationManager implements NotificationManagerI {
  /// Singleton instance of the notification manager.
  static final NotificationManager _instance = NotificationManager._internal();

  /// Notification manager implementation to delegate calls to.
  static NotificationManagerI _delegate;

  /// Factory constructor to retrieve singleton instance.
  factory NotificationManager() {
    if (_delegate == null) {
      _delegate = LocalFlutterNotificationManager();
    }

    return _instance;
  }

  /// Internal singleton constructor.
  NotificationManager._internal();

  /// Set the notification manager implementation to use for further calls.
  static setImplementation(NotificationManagerI implementation) => NotificationManager._delegate = implementation;

  @override
  Future<void> initialize() async {
    _delegate.initialize();
  }

  @override
  Future<int> showNotification({
    String title,
    String content,
    String payload,
  }) async {
    return _delegate.showNotification(
      title: title,
      content: content,
      payload: payload,
    );
  }
}
