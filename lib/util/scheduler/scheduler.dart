import 'package:guide7/util/scheduler/impl/background_fetch_scheduler.dart';
import 'package:guide7/util/scheduler/scheduler_interface.dart';

/// Scheduler scheduling background tasks which will execute every few minutes.
class Scheduler implements SchedulerI {
  /// Singleton instance of the scheduler.
  static final Scheduler _instance = Scheduler._internal();

  /// Delegated scheduler implementation to use.
  static SchedulerI _delegate;

  /// Singleton instance factory constructor.
  factory Scheduler() {
    if (_delegate == null) {
      _delegate = BackgroundFetchScheduler();
    }

    return _instance;
  }

  /// Internal constructor.
  Scheduler._internal();

  /// Set the scheduler implementation to use for further calls.
  static setImplementation(SchedulerI implementation) => Scheduler._delegate = implementation;

  @override
  Future<void> onAppTermination() async => _delegate.onAppTermination();

  @override
  Future<void> onInit() async => _delegate.onInit();
}
