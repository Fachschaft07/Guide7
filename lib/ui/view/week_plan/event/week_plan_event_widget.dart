import 'package:flutter/widgets.dart';
import 'package:guide7/model/weekplan/week_plan_event.dart';
import 'package:intl/intl.dart';

/// Widget displaying a week plan event.
class WeekPlanEventWidget extends StatelessWidget {
  /// Event to display.
  final WeekPlanEvent event;

  /// Create week plan event widget.
  WeekPlanEventWidget({
    @required this.event,
  });

  @override
  Widget build(BuildContext context) {
    DateFormat dateFormat = DateFormat.yMd(Localizations.localeOf(context).languageCode);

    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      child: Text(
        "${dateFormat.format(event.start)} - ${dateFormat.format(event.end)}",
      ),
    );
  }
}
