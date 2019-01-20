import 'package:guide7/connect/weekplan/weekplan_repository.dart';
import 'package:guide7/model/weekplan/week_plan_event.dart';
import 'package:guide7/model/weekplan/zpa/slot/change/plan_change.dart';
import 'package:guide7/model/weekplan/zpa/slot/types/extra_slot.dart';
import 'package:guide7/model/weekplan/zpa/slot/types/regular_slot.dart';
import 'package:guide7/model/weekplan/zpa/slot/types/replace_slot.dart';
import 'package:guide7/model/weekplan/zpa/slot/types/single_slot.dart';
import 'package:guide7/model/weekplan/zpa/zpa_week_plan_event.dart';

/// Mock repository for week plan events.
class MockWeekPlanRepository implements WeekPlanRepository {
  @override
  Future<List<WeekPlanEvent>> getEvents({bool fromServer, DateTime date}) async {
    DateTime now = DateTime.now();

    List<WeekPlanEvent> events = [
      ZPAWeekPlanEvent(
        slot: RegularSlot(
          type: "regular",
          start: now.add(Duration(days: 2)),
          end: now.add(Duration(days: 2, hours: 2)),
          groups: ["IF1Z"],
          modules: ["Module name"],
          descriptions: ["I am a description"],
          rooms: ["R1.006"],
          teachers: ["Max Mustermann"],
        ),
      ),
      ZPAWeekPlanEvent(
        slot: RegularSlot(
          type: "regular",
          start: now.add(Duration(days: 1)),
          end: now.add(Duration(days: 1, hours: 2)),
          groups: ["IF1Z", "IC3Q"],
          modules: ["Module name"],
          descriptions: ["I am a description", "And another one!"],
          rooms: ["R1.006", "R1.008", "A lot of rooms..."],
          teachers: ["Max Mustermann", "Another teacher"],
        ),
      ),
      ZPAWeekPlanEvent(
        slot: RegularSlot(
          type: "regular",
          start: now.add(Duration(days: 1, hours: 3)),
          end: now.add(Duration(days: 1, hours: 4)),
          groups: ["IF1Z"],
          modules: ["Module name"],
          descriptions: ["I am a description"],
          rooms: ["R1.006"],
          teachers: ["Max Mustermann"],
          planChange: PlanChange(
            changeDescription: "The event has been cancelled",
            cancelled: true,
            moved: false,
            roomChanged: false,
          ),
        ),
      ),
      ZPAWeekPlanEvent(
        slot: RegularSlot(
          type: "regular",
          start: now.add(Duration(days: 1, hours: 3)),
          end: now.add(Duration(days: 1, hours: 4)),
          groups: ["IF1Z"],
          modules: ["Module name"],
          descriptions: ["I am a description"],
          rooms: ["R1.006"],
          teachers: ["Max Mustermann"],
          planChange: PlanChange(
            changeDescription: "The event has been moved to another date and room",
            cancelled: false,
            moved: true,
            roomChanged: false,
            alternateStartDate: now.add(Duration(days: 7, hours: 3)),
            alternateRooms: ["R3.004"],
          ),
        ),
      ),
      ZPAWeekPlanEvent(
        slot: RegularSlot(
          type: "regular",
          start: now.add(Duration(days: 1, hours: 3)),
          end: now.add(Duration(days: 1, hours: 4)),
          groups: ["IF1Z"],
          modules: ["Module name"],
          descriptions: ["I am a description"],
          rooms: ["R1.006"],
          teachers: ["Max Mustermann"],
          planChange: PlanChange(
            changeDescription: "The event has been moved to another date",
            cancelled: false,
            moved: true,
            roomChanged: false,
            alternateStartDate: now.add(Duration(days: 14, hours: 3)),
          ),
        ),
      ),
      ZPAWeekPlanEvent(
        slot: RegularSlot(
          type: "regular",
          start: now.add(Duration(days: 1, hours: 3)),
          end: now.add(Duration(days: 1, hours: 4)),
          groups: ["IF1Z"],
          modules: ["Module name"],
          descriptions: ["I am a description"],
          rooms: ["R1.006"],
          teachers: ["Max Mustermann"],
          planChange: PlanChange(
            changeDescription: "The events room has been changed",
            cancelled: false,
            moved: false,
            roomChanged: true,
            alternateRooms: ["R2.009"],
          ),
        ),
      ),
      ZPAWeekPlanEvent(
        slot: SingleSlot(
          type: "single",
          teachers: ["Single slot teacher"],
          rooms: ["Z3.002"],
          start: now.add(Duration(days: 4)),
          end: now.add(Duration(days: 4, hours: 1)),
          description: "I am a single slot!",
        ),
      ),
      ZPAWeekPlanEvent(
        slot: ReplaceSlot(
          type: "replace",
          teachers: ["Replace slot teacher"],
          rooms: ["Q2.005"],
          start: now.add(Duration(days: 1)),
          end: now.add(Duration(days: 1, hours: 6)),
          description: "I am a replace slot!",
          groups: ["IF4F"],
        ),
      ),
      ZPAWeekPlanEvent(
        slot: ExtraSlot(
          type: "extra",
          teachers: ["Extra slot teacher"],
          rooms: ["E2.002"],
          start: now.add(Duration(days: 6)),
          end: now.add(Duration(days: 6, hours: 2)),
          description: "I am a extra slot!",
          groups: ["Group"],
        ),
      ),
    ];

    int startDay = date.day;
    int endDay = date.day + 6;

    events.removeWhere((event) => event.start.year != date.year || event.start.month != date.month || event.start.day < startDay || event.end.day > endDay);

    return events;
  }

  @override
  Future<void> clearCache() async {
    // Do nothing.
  }
}
