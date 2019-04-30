import 'dart:async';

import 'package:guide7/model/appointment/appointment.dart';

/// Repository serving appointments.
abstract class AppointmentRepository {
  /// Load all available appointments.
  Future<List<Appointment>> loadAppointments({
    bool fromServer,
  });
}
