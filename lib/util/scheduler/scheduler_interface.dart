/// Interface for each scheduler implementation.
abstract class SchedulerI {
  /// Initialize the scheduler.
  Future<void> onInit();
}
