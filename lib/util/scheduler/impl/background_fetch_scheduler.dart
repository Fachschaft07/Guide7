import 'package:background_fetch/background_fetch.dart';
import 'package:guide7/util/scheduler/scheduler_interface.dart';

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
        minimumFetchInterval: 30,
        stopOnTerminate: false,
        enableHeadless: true,
      ),
      _getBackgroundTask(),
    );
  }

  /// Get the background task.
  Function _getBackgroundTask() => () async {
        // TODO Execute background tasks.

        // IMPORTANT: You must signal completion of your fetch task or the OS can punish your app
        // for taking too long in the background.
        BackgroundFetch.finish();
      };
}
