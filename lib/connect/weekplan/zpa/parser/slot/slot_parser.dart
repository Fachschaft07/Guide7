import 'package:guide7/connect/weekplan/zpa/parser/slot/types/extra_slot_parser.dart';
import 'package:guide7/connect/weekplan/zpa/parser/slot/types/regular_slot_parser.dart';
import 'package:guide7/connect/weekplan/zpa/parser/slot/types/replace_slot_parser.dart';
import 'package:guide7/connect/weekplan/zpa/parser/slot/types/single_slot_parser.dart';
import 'package:guide7/model/weekplan/zpa/slot/zpa_week_plan_slot.dart';
import 'package:guide7/util/parser/parser.dart';

/// Parser delegating to the correct parser to use for the ZPA week plan slot type.
class SlotParser implements Parser<Map<String, dynamic>, ZPAWeekPlanSlot> {
  /// Parser for regular slots.
  static const RegularSlotParser _regularSlotParser = RegularSlotParser();

  /// Parser for single slots.
  static const SingleSlotParser _singleSlotParser = SingleSlotParser();

  /// Parser for replace slots.
  static const ReplaceSlotParser _replaceSlotParser = ReplaceSlotParser();

  /// Parser for extra slots.
  static const ExtraSlotParser _extraSlotParser = ExtraSlotParser();

  /// Constant constructor.
  const SlotParser();

  @override
  ZPAWeekPlanSlot parse(Map<String, dynamic> json) {
    String slotType = json["type"];

    return _getParserForSlotType(slotType).parse(json);
  }

  /// Get the correct parser for the passed slot [type].
  Parser<Map<String, dynamic>, ZPAWeekPlanSlot> _getParserForSlotType(String type) {
    switch (type) {
      case "regular":
        return _regularSlotParser;
      case "single":
        return _singleSlotParser;
      case "replace":
        return _replaceSlotParser;
      case "extra":
        return _extraSlotParser;
      default:
        throw Exception("Slot type '$type' unkown to the parser");
    }
  }
}
