import 'package:guide7/connect/weekplan/zpa/parser/slot/week_plan_slot_parser.dart';
import 'package:guide7/model/weekplan/zpa/slot/types/single_slot.dart';
import 'package:guide7/model/weekplan/zpa/slot/zpa_week_plan_slot.dart';
import 'package:guide7/util/parser/parser.dart';

/// Parser parsing a slot of type single.
class SingleSlotParser implements Parser<Map<String, dynamic>, SingleSlot> {
  /// Parser used to parse the base slot.
  static const WeekPlanSlotParser _weekPlanSlotParser = WeekPlanSlotParser();

  /// Constant constructor.
  const SingleSlotParser();

  @override
  SingleSlot parse(Map<String, dynamic> json) {
    ZPAWeekPlanSlot slot = _weekPlanSlotParser.parse(json);

    String description = json["description"];

    return SingleSlot(
      type: slot.type,
      rooms: slot.rooms,
      teachers: slot.teachers,
      start: slot.start,
      end: slot.end,
      description: description,
    );
  }
}
