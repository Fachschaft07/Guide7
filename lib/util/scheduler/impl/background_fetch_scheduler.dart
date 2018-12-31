import 'package:background_fetch/background_fetch.dart';
import 'package:guide7/util/scheduler/scheduler_interface.dart';
import 'package:guide7/util/scheduler/task/background_task.dart';
import 'package:guide7/util/scheduler/task/tasks.dart';

/// Scheduler using the "background_fetch" flutter plugin.
class BackgroundFetchScheduler implements SchedulerI {
  @override
  Future<void> onAppTermination() async {
    // Register to receive BackgroundFetch events after app is terminated.
    // Requires the background fetch to be configured with {stopOnTerminate: false, enableHeadless: true}.
    BackgroundFetch.registerHeadlessTask(_getBackgroundTask());
  }

  @override
  Future<void> onInit() async {
    BackgroundFetch.configure(
      BackgroundFetchConfig(
        minimumFetchInterval: 15,
        stopOnTerminate: false,
        enableHeadless: true,
      ),
      _getBackgroundTask(),
    );
  }

  /// Get the background task.
  Function _getBackgroundTask() => () async {
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
      };
}
