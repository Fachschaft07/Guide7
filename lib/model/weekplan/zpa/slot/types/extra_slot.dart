import 'package:guide7/model/weekplan/zpa/slot/types/replace_slot.dart';
import 'package:meta/meta.dart';

/// ZPA week plan slot of type extra.
class ExtraSlot extends ReplaceSlot {
  /// Create extra slot.
  ExtraSlot({
    @required String type,
    @required List<String> rooms,
    @required List<String> teachers,
    @required DateTime start,
    @required DateTime end,
    @required String description,
    @required List<String> groups,
  }) : super(
          type: type,
          rooms: rooms,
          teachers: teachers,
          start: start,
          end: end,
          description: description,
          groups: groups,
        );
}
