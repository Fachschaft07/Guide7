import 'package:meta/meta.dart';

/// Slot of the ZPA week plan.
class ZPAWeekPlanSlot {
  /// Type of the slot.
  final String type;

  /// Rooms of the slot.
  /// Typically only one.
  final List<String> rooms;

  /// Teachers associated with the slot.
  final List<String> teachers;

  /// Start of the slot.
  final DateTime start;

  /// End of the slot.
  final DateTime end;

  /// Create week plan slot.
  ZPAWeekPlanSlot({
    @required this.type,
    @required this.rooms,
    @required this.teachers,
    @required this.start,
    @required this.end,
  });

  /// Get duration of the slot.
  Duration get duration => end.difference(start);
}
