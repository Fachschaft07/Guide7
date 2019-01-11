import 'package:guide7/model/weekplan/week_plan_event.dart';
import 'package:guide7/model/weekplan/zpa/slot/zpa_week_plan_slot.dart';
import 'package:meta/meta.dart';

/// Week plan event from the ZPA services.
class ZPAWeekPlanEvent extends WeekPlanEvent {
  /// Slot to display in the event.
  final ZPAWeekPlanSlot slot;

  /// Create ZPA week plan event.
  ZPAWeekPlanEvent({
    @required this.slot,
  }) : super(
          start: slot.start,
          end: slot.end,
        );

  @override
  String get description => "Description";

  @override
  String get title => "Title";
}
