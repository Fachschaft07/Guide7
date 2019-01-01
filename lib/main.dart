import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/material.dart';
import 'package:guide7/app.dart';
import 'package:guide7/util/scheduler/impl/background_fetch_scheduler.dart' show executeBackgroundTasks;

/// Entry point for the application.
void main() {
  runApp(App());

  _setupHeadlessTasks();
}

/// Setup background tasks running headless in the background (for android) even when the app is terminated.
void _setupHeadlessTasks() {
  BackgroundFetch.registerHeadlessTask(executeBackgroundTasks);
}
