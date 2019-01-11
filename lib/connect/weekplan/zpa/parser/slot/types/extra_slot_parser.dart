import 'package:guide7/connect/weekplan/zpa/parser/slot/types/replace_slot_parser.dart';
import 'package:guide7/model/weekplan/zpa/slot/types/extra_slot.dart';
import 'package:guide7/model/weekplan/zpa/slot/types/replace_slot.dart';
import 'package:guide7/util/parser/parser.dart';

/// Parser parsing ZPA week plan slots of type extra.
class ExtraSlotParser implements Parser<Map<String, dynamic>, ExtraSlot> {
  /// Parser parsing replace slots.
  static const ReplaceSlotParser _replaceSlotParser = ReplaceSlotParser();

  /// Constant constructor.
  const ExtraSlotParser();

  @override
  ExtraSlot parse(Map<String, dynamic> json) {
    ReplaceSlot slot = _replaceSlotParser.parse(json);

    return ExtraSlot(
      type: slot.type,
      rooms: slot.rooms,
      teachers: slot.teachers,
      start: slot.start,
      end: slot.end,
      description: slot.description,
      groups: slot.groups,
    );
  }
}
