import 'package:guide7/model/weekplan/custom/custom_event_cycle.dart';
import 'package:guide7/model/weekplan/week_plan_event.dart';
import 'package:meta/meta.dart';

/// A custom week plan event.
class CustomEvent extends WeekPlanEvent {
  /// Uuid to uniquely sign this event.
  final String uuid;

  /// Title of the event.
  final String title;

  /// Description of the event.
  final String description;

  /// Location of the event.
  final String location;

  /// Cycle in which the event will recur.
  /// null is a special value for "only once".
  final CustomEventCycle cycle;

  /// Create new custom event.
  CustomEvent({
    @required this.uuid,
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
  bool get isRecurring => !cycle.isOnlyOnce;
}
