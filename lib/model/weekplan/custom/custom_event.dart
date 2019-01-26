import 'package:guide7/model/weekplan/week_plan_event.dart';
import 'package:meta/meta.dart';

/// A custom week plan event.
class CustomEvent extends WeekPlanEvent {
  /// Title of the event.
  final String title;

  /// Description of the event.
  final String description;

  /// Location of the event.
  final String location;

  /// Cycle in which the event will recur (in days).
  /// 0 is a special value for "only once".
  /// Example: cycle = 7 (Every 7 days = every week).
  final int cycle;

  /// Create new custom event.
  CustomEvent({
    @required this.title,
    @required this.description,
    @required this.location,
    @required this.cycle,
    @required DateTime start,
    @required DateTime end,
  }) : super(
          start: start,
          end: end,
        );

  /// Whether the event is recurring.
  bool get isRecurring => cycle != null;
}
