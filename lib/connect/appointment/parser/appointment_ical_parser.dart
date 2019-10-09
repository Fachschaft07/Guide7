import 'dart:convert';

import 'package:guide7/model/appointment/appointment.dart';
import 'package:guide7/util/parser/parser.dart';

/// Parser parsing iCalendar formatted string to appointments.
class AppointmentICalParser implements Parser<String, List<Appointment>> {
  /// Constant constructor.
  const AppointmentICalParser();

  @override
  List<Appointment> parse(String source) {
    List<Map<String, String>> events = _parseICalendarEvents(source);

    List<Appointment> appointments = List<Appointment>();

    for (Map<String, String> event in events) {
      String uid = event["UID"];
      String summary = event["SUMMARY"];
      String description = event["DESCRIPTION"];
      String location = event["LOCATION"];
      String startDateStr = event["DTSTART"];
      String endDateStr = event["DTEND"];

      if (startDateStr == null || endDateStr == null) {
        continue;
      }

      DateTime startDate = DateTime.parse(startDateStr);
      DateTime endDate = DateTime.parse(endDateStr);

      appointments.add(Appointment(
        uid: uid,
        start: startDate,
        end: endDate,
        summary: summary,
        description: description,
        location: location,
      ));
    }

    return appointments;
  }

  /// Parse all iCalendar events.
  List<Map<String, String>> _parseICalendarEvents(String iCalendar) {
    List<Map<String, String>> result = List<Map<String, String>>();
    Map<String, String> currentMap;

    String lastKey;
    for (final line in LineSplitter.split(iCalendar)) {
      int keyValueSplit = line.indexOf(":");

      bool continuesLastLineValue = keyValueSplit == -1;

      String key = continuesLastLineValue ? lastKey : line.substring(0, keyValueSplit);
      int splitterIndex = key.indexOf(";");
      if (splitterIndex != -1) {
        key = key.substring(0, splitterIndex);
      }

      String value = continuesLastLineValue ? line.trim() : line.substring(keyValueSplit + 1);

      if (key == "BEGIN" && value == "VEVENT") {
        // Begin of event
        currentMap = Map<String, String>();
      } else if (key == "END" && value == "VEVENT") {
        // End of event
        result.add(currentMap);
        currentMap = null;
      } else if (currentMap != null) {
        if (continuesLastLineValue) {
          // Add value to last value.
          currentMap[lastKey] = currentMap[lastKey] + value;
        } else {
          currentMap[key] = value; // Add attribute to event
        }
      }

      lastKey = key;
    }

    return result;
  }
}
