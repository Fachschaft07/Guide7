import 'package:guide7/connect/appointment/appointment_repository.dart';
import 'package:guide7/model/appointment/appointment.dart';

/// Mock appointments with this repository.
class MockAppointmentRepository implements AppointmentRepository {
  @override
  Future<List<Appointment>> loadAppointments({bool fromServer}) async {
    return [
      Appointment(
        uid: "1",
        start: DateTime(2018, 2, 1),
        end: DateTime(2018, 3, 1),
        description: "Test appointment",
        summary: "Test appointment",
        location: "Nowhere",
      ),
    ];
  }
}
