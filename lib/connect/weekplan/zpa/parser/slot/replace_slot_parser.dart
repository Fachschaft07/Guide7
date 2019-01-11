import 'package:guide7/connect/weekplan/zpa/parser/slot/single_slot_parser.dart';
import 'package:guide7/model/weekplan/zpa/slot/types/replace_slot.dart';
import 'package:guide7/model/weekplan/zpa/slot/types/single_slot.dart';
import 'package:guide7/util/parser/parser.dart';

/// Parser parsing a ZPA week plan slot of type replace.
class ReplaceSlotParser implements Parser<Map<String, dynamic>, ReplaceSlot> {
  /// Parser parsing a single slot.
  static const SingleSlotParser _singleSlotParser = SingleSlotParser();

  /// Constant constructor.
  const ReplaceSlotParser();

  @override
  ReplaceSlot parse(Map<String, dynamic> json) {
    SingleSlot slot = _singleSlotParser.parse(json);

    List<String> groups = List<String>();
    for (final group in json["groups"]) {
      groups.add(group);
    }

    return ReplaceSlot(
      type: slot.type,
      rooms: slot.rooms,
      teachers: slot.teachers,
      start: slot.start,
      end: slot.end,
      description: slot.description,
      groups: groups,
    );
  }
}
