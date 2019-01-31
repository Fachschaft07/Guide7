import 'package:guide7/connect/week_plan/week_plan_repository.dart';
import 'package:guide7/model/weekplan/custom/custom_event.dart';
import 'package:guide7/model/weekplan/week_plan_event.dart';
import 'package:guide7/storage/week_plan/custom/custom_week_plan_event_storage.dart';
import 'package:guide7/util/date_util.dart';

/// Repository for custom week plan events.
class CustomWeekPlanEventRepository implements WeekPlanRepository {
  /// Constant constructor.
  const CustomWeekPlanEventRepository();

  @override
  Future<void> clearCache() async {
    CustomWeekPlanEventStorage storage = CustomWeekPlanEventStorage();
    await storage.clear();
  }

  @override
  Future<List<WeekPlanEvent>> getEvents({bool fromServer, DateTime date}) async {
    CustomWeekPlanEventStorage storage = CustomWeekPlanEventStorage();
    List<CustomEvent> events = await storage.read();

    int calendarWeek = DateUtil.getWeekOfYear(DateTime.utc(date.year, date.month, date.day));

    return _getEventsForWeek(events, date, calendarWeek);
  }

  /// Get events for the passed week.
  List<CustomEvent> _getEventsForWeek(List<CustomEvent> events, DateTime date, int calendarWeek) {
    // TODO Filter by calendarweek and date with event cycles
    return events;
  }
}
