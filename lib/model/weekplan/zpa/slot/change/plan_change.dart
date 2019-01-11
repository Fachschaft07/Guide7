import 'package:meta/meta.dart';

/// Plan change of a ZPA week event.
class PlanChange {
  /// Description of the plan change.
  final String changeDescription;

  /// Whether the event has been cancelled.
  final bool cancelled;

  /// Whether the room of the event has been changed.
  final bool roomChanged;

  /// Alternate rooms in case the room has changed or the event moved (see [roomChanged] and/or [moved]).
  final List<String> alternateRooms;

  /// Whether the event has been moved.
  final bool moved;

  /// Alternate start date of the event in case the event has been [moved].
  final DateTime alternateStartDate;

  /// Create change.
  PlanChange({
    @required this.changeDescription,
    @required this.cancelled,
    @required this.roomChanged,
    @required this.moved,
    this.alternateRooms,
    this.alternateStartDate,
  });
}
