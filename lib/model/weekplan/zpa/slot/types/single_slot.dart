import 'package:guide7/model/weekplan/zpa/slot/zpa_week_plan_slot.dart';
import 'package:meta/meta.dart';

/// Single slot of the ZPA week plan.
class SingleSlot extends ZPAWeekPlanSlot {
  /// Description of the slot.
  final String description;

  /// Create single slot.
  SingleSlot({
    @required String type,
    @required List<String> rooms,
    @required List<String> teachers,
    @required DateTime start,
    @required DateTime end,
    @required this.description,
  }) : super(
          type: type,
          rooms: rooms,
          teachers: teachers,
          start: start,
          end: end,
        );
}
