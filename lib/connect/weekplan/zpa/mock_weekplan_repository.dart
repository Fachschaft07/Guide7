import 'package:guide7/connect/weekplan/weekplan_repository.dart';
import 'package:guide7/model/weekplan/week_plan_event.dart';

/// Mock repository for week plan events.
class MockWeekPlanRepository implements WeekPlanRepository {
  @override
  Future<List<WeekPlanEvent>> getEvents({bool fromServer, DateTime date}) async {
    return [];
  }
}
