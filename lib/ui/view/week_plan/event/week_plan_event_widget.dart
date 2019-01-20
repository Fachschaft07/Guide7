import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:guide7/model/weekplan/week_plan_event.dart';
import 'package:guide7/model/weekplan/zpa/zpa_week_plan_event.dart';
import 'package:guide7/ui/view/week_plan/event/zpa/zpa_week_plan_event_widget.dart';
import 'package:guide7/util/custom_colors.dart';
import 'package:intl/intl.dart';

/// Widget displaying a week plan event.
class WeekPlanEventWidget extends StatelessWidget {
  /// Date format to format time with.
  static DateFormat _timeFormat = DateFormat("H:mm");

  /// Event to display.
  final WeekPlanEvent event;

  /// Create week plan event widget.
  WeekPlanEventWidget({
    @required this.event,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(right: 5),
                child: Icon(
                  Icons.access_time,
                  color: CustomColors.slateGrey,
                ),
              ),
              Text(
                "${_timeFormat.format(event.start)} - ${_timeFormat.format(event.end)}",
                style: TextStyle(
                  fontFamily: "Raleway",
                  color: CustomColors.slateGrey,
                ),
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Expanded(child: _getEventDisplayWidget(context)),
            ],
          ),
        ],
      ),
    );
  }

  /// Get the events widget to display it.
  Widget _getEventDisplayWidget(BuildContext context) {
    if (event is ZPAWeekPlanEvent) {
      return ZPAWeekPlanEventWidget(event: event as ZPAWeekPlanEvent);
    } else {
      throw Exception("Event type unknown");
    }
  }
}
