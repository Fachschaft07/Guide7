import 'package:guide7/connect/weekplan/weekplan_repository.dart';
import 'package:guide7/connect/weekplan/zpa/zpa_weekplan_repository.dart';
import 'package:guide7/model/weekplan/week_plan_event.dart';

/// Repository providing all week plan events available.
class WeekPlanRepositoryImpl implements WeekPlanRepository {
  /// All week plan repositories.
  static const List<WeekPlanRepository> _weekPlanRepositories = [
    ZPAWeekPlanRepository(),
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
