/// Interface for each scheduler implementation.
abstract class SchedulerI {
  /// Initialize the scheduler.
  Future<void> onInit();

  /// What to do in case the app is terminated.
  Future<void> onAppTermination();
}
