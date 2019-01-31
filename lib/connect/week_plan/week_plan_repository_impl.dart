import 'package:guide7/connect/week_plan/custom/custom_week_plan_event_repository.dart';
import 'package:guide7/connect/week_plan/week_plan_repository.dart';
import 'package:guide7/connect/week_plan/zpa/zpa_week_plan_repository.dart';
import 'package:guide7/model/weekplan/week_plan_event.dart';

/// Repository providing all week plan events available.
class WeekPlanRepositoryImpl implements WeekPlanRepository {
  /// All week plan repositories.
  static const List<WeekPlanRepository> _weekPlanRepositories = [
    ZPAWeekPlanRepository(),
    CustomWeekPlanEventRepository(),
  ];

  @override
  Future<List<WeekPlanEvent>> getEvents({bool fromServer, DateTime date}) async {
    List<WeekPlanEvent> result = List<WeekPlanEvent>();

    for (WeekPlanRepository repository in _weekPlanRepositories) {
      List<WeekPlanEvent> events = await repository.getEvents(
        fromServer: fromServer,
        date: date,
      );

      result.addAll(events);
    }

    return result;
  }

  @override
  Future<void> clearCache() async {
    for (WeekPlanRepository repository in _weekPlanRepositories) {
      await repository.clearCache();
    }
  }
}
