import 'package:meta/meta.dart';

/// An appointment representation.
class Appointment {
  /// Unique id of the appointment.
  final String uid;

  /// Start of the appointment.
  final DateTime start;

  /// End of the appointment.
  final DateTime end;

  /// Summary of the appointments abouts.
  final String summary;

  /// Description of the appointment.
  final String description;

  /// Location of the appointment.
  final String location;

  /// Create appointment.
  Appointment({
    @required this.uid,
    @required this.start,
    @required this.end,
    @required this.summary,
    @required this.description,
    this.location,
  });
}
