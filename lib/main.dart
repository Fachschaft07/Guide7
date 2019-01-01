import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/material.dart';
import 'package:guide7/app.dart';
import 'package:guide7/util/scheduler/scheduler.dart';
import 'package:guide7/util/scheduler/task/background_task.dart';
import 'package:guide7/util/scheduler/task/tasks.dart';

/// Entry point for the application.
void main() {
  runApp(App());

  _setupHeadlessTasks();
}

/// Setup background tasks running headless in the background (for android) even when the app is terminated.
void _setupHeadlessTasks() {
  BackgroundFetch.registerHeadlessTask(executeBackgroundTasks);
}

/// Execute all background tasks.
void executeBackgroundTasks() async {
  try {
    // Execute all background tasks.
    for (BackgroundTask task in Tasks.tasks) {
      task.execute();
    }
  } catch (e) {
    // Do nothing.
  }

  // IMPORTANT: You must signal completion of your fetch task or the OS can punish your app
  // for taking too long in the background.
  BackgroundFetch.finish();
}
