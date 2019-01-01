import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

/// Interface for all applications notification managers.
abstract class NotificationManagerI {
  /// Initialize the notification manager.
  Future<void> initialize();

  /// Show a notification.
  /// [title] of the notification
  /// [content] of the notification
  /// [clickCallback] to execute in case the notification is clicked
  /// Returns the notification id.
  Future<int> showNotification({
    @required String title,
    @required String content,
    String payload,
  });
}
