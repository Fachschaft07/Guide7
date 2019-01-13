import 'package:flutter/widgets.dart';
import 'package:guide7/model/weekplan/zpa/slot/types/extra_slot.dart';
import 'package:guide7/model/weekplan/zpa/slot/types/regular_slot.dart';
import 'package:guide7/model/weekplan/zpa/slot/types/replace_slot.dart';
import 'package:guide7/model/weekplan/zpa/slot/types/single_slot.dart';
import 'package:guide7/model/weekplan/zpa/slot/zpa_week_plan_slot.dart';
import 'package:guide7/model/weekplan/zpa/zpa_week_plan_event.dart';
import 'package:guide7/ui/view/week_plan/event/zpa/slot/extra_slot_widget.dart';
import 'package:guide7/ui/view/week_plan/event/zpa/slot/regular_slot_widget.dart';
import 'package:guide7/ui/view/week_plan/event/zpa/slot/replace_slot_widget.dart';
import 'package:guide7/ui/view/week_plan/event/zpa/slot/single_slot_widget.dart';

/// Event display widget for ZPA events.
class ZPAWeekPlanEventWidget extends StatelessWidget {
  /// ZPA event to display.
  final ZPAWeekPlanEvent event;

  /// Create widget-
  ZPAWeekPlanEventWidget({
    @required this.event,
  });

  @override
  Widget build(BuildContext context) {
    return _buildSlotWidget(context, event.slot);
  }

  /// Build display widget for the passed slot.
  Widget _buildSlotWidget(BuildContext context, ZPAWeekPlanSlot slot) {
    if (slot is RegularSlot) {
      return RegularSlotWidget(slot: slot);
    } else if (slot is SingleSlot) {
      return SingleSlotWidget(slot: slot);
    } else if (slot is ReplaceSlot) {
      return ReplaceSlotWidget(slot: slot);
    } else if (slot is ExtraSlot) {
      return ExtraSlotWidget(slot: slot);
    } else {
      throw Exception("Slot type not known");
    }
  }
}
