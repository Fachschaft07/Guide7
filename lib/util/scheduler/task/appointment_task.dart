import 'package:connectivity/connectivity.dart';
import 'package:guide7/connect/appointment/appointment_repository.dart';
import 'package:guide7/connect/repository.dart';
import 'package:guide7/model/appointment/appointment.dart';
import 'package:guide7/util/notification/notification_manager.dart';
import 'package:guide7/util/notification/payload_handler/appointment_payload_handler.dart';
import 'package:guide7/util/scheduler/task/background_task.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Background task to refresh the appointments and fire notifications in case of upcoming appointments.
class AppointmentTask implements BackgroundTask {
  /// Key of a value in shared preferences which is the last date where upcoming notifications have been checked.
  /// This is used to avoid several similar notifications.
  static const String _lastCheckDateKey = "appointment-task.last-check-date";

  /// Date format used to store the last check date.
  static DateFormat _dateFormat = DateFormat("yyyyMMdd");

  /// Constant constructor.
  const AppointmentTask();

  @override
  Future<void> execute() async {
    /// Check that internet connection is available first.
    var connectivityResult = await (new Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      return null;
    }

    Repository repository = Repository();
    AppointmentRepository appointmentRepository = repository.getAppointmentRepository();

    // Load fresh appointments from server (they will be cached by the repository itself when done loading).
    List<Appointment> appointments = await appointmentRepository.loadAppointments(fromServer: true);

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String lastCheckedDate = sharedPreferences.getString(_lastCheckDateKey);

    DateTime lastChecked;
    if (lastCheckedDate != null) {
      lastChecked = DateTime.tryParse(lastCheckedDate);
    }

    DateTime now = DateTime.now();
    DateTime currentDate = DateTime(now.year, now.month, now.day);

    bool checkForUpcomingNotifications = lastChecked == null || currentDate.isAfter(lastChecked);

    print("[LastChecked]: $lastCheckedDate $lastChecked $checkForUpcomingNotifications");

    if (checkForUpcomingNotifications) {
      // Store check date
      await sharedPreferences.setString(_lastCheckDateKey, _dateFormat.format(currentDate));

      List<Appointment> upcomingAppointments = _getUpcomingAppointments(appointments, currentDate);
      if (upcomingAppointments.isNotEmpty) {
        NotificationManager().showNotification(
          title: "Erinnerung",
          content: upcomingAppointments.length == 1
              ? "\"${upcomingAppointments.first.summary} beginnt in Kürze"
              : "${upcomingAppointments.length} Termine beginnen in Kürze",
          payload: AppointmentPayloadHandler.payload,
        );
      }
    }
  }

  /// Get upcoming appointments.
  List<Appointment> _getUpcomingAppointments(List<Appointment> appointments, DateTime currentDate) {
    appointments = List.of(appointments); // Make sure appointments is a growable list.

    // Remove old appointments.
    appointments.removeWhere((appointment) => appointment.end.isBefore(DateTime.now()));

    List<Appointment> upcomingAppointments = List<Appointment>();
    for (Appointment appointment in appointments) {
      if (appointment.start.year == currentDate.year && appointment.start.month == currentDate.month && appointment.start.day == currentDate.day + 1) {
        upcomingAppointments.add(appointment);
      }
    }

    return upcomingAppointments;
  }
}
