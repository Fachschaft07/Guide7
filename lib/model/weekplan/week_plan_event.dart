import 'package:flutter/material.dart';

/// Base class for week plan events.
abstract class WeekPlanEvent {
  /// Start date of the event.
  final DateTime start;

  /// End date of the event.
  final DateTime end;

  /// Create event.
  WeekPlanEvent({
    @required this.start,
    @required this.end,
  });

  /// Get title of the event.
  String get title;

  /// Get description of the event.
  String get description;

  /// Get duration of the event.
  Duration get duration => end.difference(start);
}
