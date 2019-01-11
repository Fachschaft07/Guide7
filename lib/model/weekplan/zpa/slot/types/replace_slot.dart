import 'package:guide7/model/weekplan/zpa/slot/types/single_slot.dart';
import 'package:meta/meta.dart';

/// A ZPA week plan slot of type replace.
class ReplaceSlot extends SingleSlot {
  /// Groups associated with the slot.
  final List<String> groups;

  /// Create replace slot.
  ReplaceSlot({
    @required String type,
    @required List<String> rooms,
    @required List<String> teachers,
    @required DateTime start,
    @required DateTime end,
    @required String description,
    @required this.groups,
  }) : super(
          type: type,
          rooms: rooms,
          teachers: teachers,
          start: start,
          end: end,
          description: description,
        );
}
