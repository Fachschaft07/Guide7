import 'package:guide7/connect/weekplan/zpa/parser/change/plan_change_parser.dart';
import 'package:guide7/connect/weekplan/zpa/parser/slot/week_plan_slot_parser.dart';
import 'package:guide7/model/weekplan/zpa/slot/change/plan_change.dart';
import 'package:guide7/model/weekplan/zpa/slot/types/regular_slot.dart';
import 'package:guide7/model/weekplan/zpa/slot/zpa_week_plan_slot.dart';
import 'package:guide7/util/parser/parser.dart';

/// Parser parsing a regular ZPA week plan slot.
class RegularSlotParser implements Parser<Map<String, dynamic>, RegularSlot> {
  /// Parser used to parse the base slot.
  static const WeekPlanSlotParser _weekPlanSlotParser = WeekPlanSlotParser();

  /// Parser used to parse the plan change of the slot (if any).
  static const PlanChangeParser _planChangeParser = PlanChangeParser();

  /// Constant constructor.
  const RegularSlotParser();

  @override
  RegularSlot parse(Map<String, dynamic> json) {
    ZPAWeekPlanSlot slot = _weekPlanSlotParser.parse(json);

    List<String> descriptions = List<String>();
    for (final description in json["descriptions"]) {
      descriptions.add(description);
    }

    List<String> modules = List<String>();
    for (final module in json["modules"]) {
      modules.add(module);
    }

    List<String> groups = List<String>();
    for (final group in json["groups"]) {
      groups.add(group);
    }

    bool hasPlanChange = json["plan_change"] != null ? json["plan_change"] : false;
    PlanChange planChange;
    if (hasPlanChange) {
      planChange = _planChangeParser.parse(json);
    }

    return RegularSlot(
      type: slot.type,
      rooms: slot.rooms,
      teachers: slot.teachers,
      start: slot.start,
      end: slot.end,
      descriptions: descriptions,
      modules: modules,
      groups: groups,
      planChange: planChange,
    );
  }
}
