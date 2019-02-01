import 'package:meta/meta.dart';

/// Cycle a custom event is recurring in.
class CustomEventCycle {
  /// Recurring each [days] days.
  final int days;

  /// Recurring each [months] months.
  final int months;

  /// Recurring each [years] years.
  final int years;

  /// Create event cycle.
  CustomEventCycle({
    @required this.days,
    @required this.months,
    @required this.years,
  });

  /// Whether the event should only occur once.
  bool get isOnlyOnce => days == 0 && months == 0 && years == 0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomEventCycle && runtimeType == other.runtimeType && days == other.days && months == other.months && years == other.years;

  @override
  int get hashCode => days.hashCode ^ months.hashCode ^ years.hashCode;
}
