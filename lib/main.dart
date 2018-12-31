import 'package:flutter/material.dart';
import 'package:guide7/app.dart';
import 'package:guide7/util/scheduler/scheduler.dart';

/// Entry point for the application.
void main() {
  runApp(App());

  onAppTermination();
}

/// What to do when the app terminates.
Future<void> onAppTermination() async {
  Scheduler().onAppTermination();
}
