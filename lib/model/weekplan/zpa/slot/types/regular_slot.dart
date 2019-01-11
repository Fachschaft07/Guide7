import 'package:guide7/model/weekplan/zpa/slot/change/plan_change.dart';
import 'package:guide7/model/weekplan/zpa/slot/zpa_week_plan_slot.dart';
import 'package:meta/meta.dart';

/// Regular week plan slot from ZPA.
class RegularSlot extends ZPAWeekPlanSlot {
  /// Descriptions for the slot.
  final List<String> descriptions;

  /// Modules associated with the slot.
  final List<String> modules;

  /// Groups associated with the slot.
  final List<String> groups;

  /// Change of the slot.
  final PlanChange planChange;

  /// Create regular slot.
  RegularSlot({
    @required String type,
    @required List<String> rooms,
    @required List<String> teachers,
    @required DateTime start,
    @required DateTime end,
    @required this.descriptions,
    @required this.modules,
    @required this.groups,
    this.planChange,
  }) : super(
          type: type,
          rooms: rooms,
          teachers: teachers,
          start: start,
          end: end,
        );

  /// Whether the slot has a plan change.
  bool get hasPlanChange => planChange != null;
}
