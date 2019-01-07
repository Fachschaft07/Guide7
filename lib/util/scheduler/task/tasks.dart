import 'package:guide7/util/scheduler/task/appointment_task.dart';
import 'package:guide7/util/scheduler/task/background_task.dart';
import 'package:guide7/util/scheduler/task/notice_board_task.dart';

/// Class holds all available background tasks for the application.
class Tasks {
  /// All available background tasks for the application.
  static const List<BackgroundTask> tasks = [
    NoticeBoardTask(),
    AppointmentTask(),
  ];
}
