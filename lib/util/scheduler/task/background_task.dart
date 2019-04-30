import 'dart:async';

/// Task to be done in the background using a scheduler.
abstract class BackgroundTask {
  /// Execute the task.
  Future<void> execute();
}
