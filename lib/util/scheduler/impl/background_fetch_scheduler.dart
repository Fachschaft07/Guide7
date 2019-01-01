import 'package:background_fetch/background_fetch.dart';
import 'package:guide7/util/scheduler/scheduler_interface.dart';
import 'package:guide7/main.dart' show executeBackgroundTasks;

/// Scheduler using the "background_fetch" flutter plugin.
class BackgroundFetchScheduler implements SchedulerI {
  @override
  Future<void> onInit() async {
    BackgroundFetch.configure(
      BackgroundFetchConfig(
        minimumFetchInterval: 15,
        stopOnTerminate: false,
        enableHeadless: true,
        startOnBoot: true,
      ),
      executeBackgroundTasks,
    );
  }
}
