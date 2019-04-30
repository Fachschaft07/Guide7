import 'dart:async';

import 'package:guide7/model/weekplan/week_plan_event.dart';

/// Interface for all week plan repositories delivering week plan events.
abstract class WeekPlanRepository {
  /// Get events from the repository.
  Future<List<WeekPlanEvent>> getEvents({
    bool fromServer,
    DateTime date,
  });

  /// Clear cached week plan events.
  Future<void> clearCache();
}
