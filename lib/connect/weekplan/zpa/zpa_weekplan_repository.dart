import 'package:guide7/connect/weekplan/weekplan_repository.dart';
import 'package:guide7/model/weekplan/week_plan_event.dart';

/// Repository providing week plan events from the ZPA services.
class ZPAWeekPlanRepository implements WeekPlanRepository {
  /// Constant constructor.
  const ZPAWeekPlanRepository();

  @override
  Future<List<WeekPlanEvent>> getEvents({
    bool fromServer,
    DateTime date,
  }) async {
    // TODO: implement getEvents
    return null;
  }
}
