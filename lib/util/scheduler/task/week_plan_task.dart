import 'package:connectivity/connectivity.dart';
import 'package:guide7/connect/repository.dart';
import 'package:guide7/connect/week_plan/week_plan_repository.dart';
import 'package:guide7/model/weekplan/week_plan_event.dart';
import 'package:guide7/model/weekplan/zpa/slot/types/regular_slot.dart';
import 'package:guide7/model/weekplan/zpa/zpa_week_plan_event.dart';
import 'package:guide7/util/notification/notification_manager.dart';
import 'package:guide7/util/notification/payload_handler/week_plan_payload_handler.dart';
import 'package:guide7/util/scheduler/task/background_task.dart';

/// Background task to refresh the week plan and fire notifications in case of new or changed week plan events.
class WeekPlanTask implements BackgroundTask {
  /// Constant constructor.
  const WeekPlanTask();

  @override
  Future<void> execute() async {
    /// Check that internet connection is available first.
    var connectivityResult = await (new Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      return null;
    }

    Repository repository = Repository();
    WeekPlanRepository weekPlanRepository = repository.getWeekPlanRepository();

    DateTime now = DateTime.now();

    // Fetch old events.
    List<WeekPlanEvent> oldEvents = List<WeekPlanEvent>();
    oldEvents.addAll(await weekPlanRepository.getEvents(fromServer: false, date: now));
    oldEvents.addAll(await weekPlanRepository.getEvents(fromServer: false, date: now.add(Duration(days: 7))));

    // Fetch new events, will update cache as well.
    List<WeekPlanEvent> newEvents = List<WeekPlanEvent>();
    newEvents.addAll(await weekPlanRepository.getEvents(fromServer: true, date: now));
    newEvents.addAll(await weekPlanRepository.getEvents(fromServer: true, date: now.add(Duration(days: 7))));

    // Find changes.
    _WeekPlanChange _weekPlanChange = _getChange(oldEvents, newEvents);

    if (_weekPlanChange.hasNew && _weekPlanChange.hasChanged) {
      NotificationManager().showNotification(
        title: "Der Wochenplan hat sich geändert",
        content: "Es gibt neue und veränderte Ereignisse auf dem Wochenplan.",
        payload: WeekPlanPayloadHandler.payload,
      );
    } else if (_weekPlanChange.hasChanged) {
      NotificationManager().showNotification(
        title: "Der Wochenplan hat sich geändert",
        content: "Es gibt ${_weekPlanChange.changedEvents.length} veränderte Ereignisse auf dem Wochenplan.",
        payload: WeekPlanPayloadHandler.payload,
      );
    } else if (_weekPlanChange.hasNew) {
      NotificationManager().showNotification(
        title: "Der Wochenplan hat sich geändert",
        content: "Es gibt ${_weekPlanChange.newEvents.length} neue Ereignisse auf dem Wochenplan.",
        payload: WeekPlanPayloadHandler.payload,
      );
    }
  }

  /// Get all changed events.
  _WeekPlanChange _getChange(List<WeekPlanEvent> oldEvents, List<WeekPlanEvent> newEvents) {
    _WeekPlanChange zpaChange = _getZPAEventChange(oldEvents, newEvents);

    return zpaChange;
  }

  /// Get all changed ZPA week plan events.
  _WeekPlanChange _getZPAEventChange(List<WeekPlanEvent> oldEvents, List<WeekPlanEvent> newEvents) {
    List<ZPAWeekPlanEvent> oldZPAEvents = oldEvents.where((event) => event is ZPAWeekPlanEvent).map((event) => event as ZPAWeekPlanEvent).toList();
    List<ZPAWeekPlanEvent> newZPAEvents = newEvents.where((event) => event is ZPAWeekPlanEvent).map((event) => event as ZPAWeekPlanEvent).toList();

    Map<int, ZPAWeekPlanEvent> oldEventLookup = Map<int, ZPAWeekPlanEvent>();
    for (ZPAWeekPlanEvent oldEvent in oldEvents) {
      int key = oldEvent.start.millisecondsSinceEpoch + oldEvent.end.millisecondsSinceEpoch;
      oldEventLookup[key] = oldEvent;
    }

    List<ZPAWeekPlanEvent> changedEvents = List<ZPAWeekPlanEvent>();
    List<ZPAWeekPlanEvent> newlyFoundEvents = List<ZPAWeekPlanEvent>();

    for (ZPAWeekPlanEvent event in newZPAEvents) {
      if (event.slot is RegularSlot) {
        // Only regular slots have a plan change.

        ZPAWeekPlanEvent oldEvent = oldEventLookup[event.start.millisecondsSinceEpoch + event.end.millisecondsSinceEpoch];
        if (oldEvent != null && oldEvent.slot is RegularSlot) {
          RegularSlot slot = event.slot;
          RegularSlot oldSlot = oldEvent.slot;

          if (slot.hasPlanChange && !oldSlot.hasPlanChange) {
            changedEvents.add(event);
          }
        } else {
          /// Seems to be a new event.
          newlyFoundEvents.add(event);
        }
      }
    }

    return _WeekPlanChange(changedEvents, newlyFoundEvents);
  }
}

/// Change of the week plan.
class _WeekPlanChange {
  /// All changed events.
  final List<WeekPlanEvent> changedEvents;

  /// All new events.
  final List<WeekPlanEvent> newEvents;

  /// Create new change.
  _WeekPlanChange(this.changedEvents, this.newEvents);

  bool get hasChanged => changedEvents != null && changedEvents.isNotEmpty;

  bool get hasNew => newEvents != null && newEvents.isNotEmpty;
}
