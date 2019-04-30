import 'dart:async';

import 'package:guide7/connect/week_plan/week_plan_repository.dart';
import 'package:guide7/model/weekplan/custom/custom_event.dart';
import 'package:guide7/model/weekplan/custom/custom_event_cycle.dart';
import 'package:guide7/model/weekplan/week_plan_event.dart';
import 'package:guide7/storage/week_plan/custom/custom_week_plan_event_storage.dart';
import 'package:guide7/util/date_util.dart';

/// Repository for custom week plan events.
class CustomWeekPlanEventRepository implements WeekPlanRepository {
  /// Constant constructor.
  const CustomWeekPlanEventRepository();

  @override
  Future<void> clearCache() async {
    // Does not cache anything.
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
    DateTime beforeWeekSunday = DateTime(date.year, date.month, date.day - date.weekday, 23, 59, 59);
    DateTime afterWeekMonday = beforeWeekSunday.add(Duration(days: 8));
    afterWeekMonday = DateTime(afterWeekMonday.year, afterWeekMonday.month, afterWeekMonday.day);

    List<CustomEvent> result = List<CustomEvent>();
    for (CustomEvent event in events) {
      List<CustomEvent> eventInWeek = _getEventInWeek(event, date, beforeWeekSunday, afterWeekMonday);

      if (eventInWeek != null) {
        result.addAll(eventInWeek);
      }
    }

    return result;
  }

  /// Get event in the passed week between [beforeWeek] and [afterWeek].
  List<CustomEvent> _getEventInWeek(CustomEvent event, DateTime date, DateTime beforeWeek, DateTime afterWeek) {
    if (!event.isRecurring) {
      return event.start.isAfter(beforeWeek) && event.end.isBefore(afterWeek) ? [event] : null;
    } else {
      DateTime nextEventStart = _getNextEventStart(event, beforeWeek);

      List<CustomEvent> result;

      while (nextEventStart.isBefore(afterWeek)) {
        DateTime nextEventEnd = nextEventStart.add(event.duration);

        if (result == null) {
          result = List<CustomEvent>();
        }

        result.add(CustomEvent(
          uuid: event.uuid,
          title: event.title,
          description: event.description,
          location: event.location,
          cycle: event.cycle,
          start: nextEventStart,
          end: nextEventEnd,
        ));

        nextEventStart = _getNextEventStart(event, nextEventEnd);
      }

      return result;
    }
  }

  /// Get the next event start for the passed [event] after the passed [after] date.
  DateTime _getNextEventStart(CustomEvent event, DateTime after) {
    DateTime start = event.start;
    CustomEventCycle cycle = event.cycle;

    assert(!cycle.isOnlyOnce);

    if (start.isAfter(after)) {
      return start;
    } else {
      while (start.isBefore(after)) {
        start =
            DateTime(start.year + cycle.years, start.month + cycle.months, start.day, start.hour, start.minute, start.second).add(Duration(days: cycle.days));
      }

      return start;
    }
  }
}
