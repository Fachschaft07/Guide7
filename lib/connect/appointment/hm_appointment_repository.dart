import 'dart:convert';

import 'package:guide7/connect/appointment/appointment_repository.dart';
import 'package:guide7/model/appointment/appointment.dart';
import 'package:guide7/storage/appointment/appointment_storage.dart';
import 'package:http/http.dart' as http;
import 'package:html/dom.dart';
import 'package:html/parser.dart' as htmlParser;

/// Repository delivering appointments for the munich university of applied sciences.
class HMAppointmentRepository implements AppointmentRepository {
  /// Where to find the iCalendar resource URL.
  static const String _resource = "https://www.hm.edu/studierende/mein_studium/verlauf/termine.de.html";

  @override
  Future<List<Appointment>> loadAppointments({bool fromServer}) async {
    AppointmentStorage appointmentStorage = AppointmentStorage();

    if (fromServer || await appointmentStorage.isEmpty()) {
      List<Appointment> appointments = await _parseAppointmentsFromServer();

      // Cache appointments.
      await appointmentStorage.write(appointments);

      return appointments;
    } else {
      // Read from cache.
      return await appointmentStorage.read();
    }
  }

  /// Parse all appointments from server.
  Future<List<Appointment>> _parseAppointmentsFromServer() async {
    String iCal = await _fetchAppointmentsICalendar();

    List<Map<String, String>> events = _parseICalendarEvents(iCal);

    List<Appointment> appointments = List<Appointment>();

    for (Map<String, String> event in events) {
      String uid = event["UID"];
      String summary = event["SUMMARY"];
      String description = event["DESCRIPTION"];
      String location = event["LOCATION"];

      DateTime startDate = DateTime.parse(event["DTSTART;VALUE=DATE"]);
      DateTime endDate = DateTime.parse(event["DTSTART;VALUE=DATE"]);

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

  /// Fetch iCalendar holding all appointments.
  Future<String> _fetchAppointmentsICalendar() async {
    String url = await _fetchICalendarResourceURL();

    return await http.read(url);
  }

  /// Fetch the iCalendar resource URL
  Future<String> _fetchICalendarResourceURL() async {
    http.Response response = await http.get(_resource);

    if (response.statusCode == 200) {
      Document document = htmlParser.parse(response.body);

      List<Element> linkElements = document.getElementsByTagName("a"); // Get all links

      // Find the one link starting with the "webcal://" protocol.
      String url = _getHrefOfLinkWithWebcalProtocol(linkElements);

      if (url == null) {
        throw Exception("Could not fetch iCalendar resource URL from HTML");
      }

      url = url.replaceFirst("webcal", "https");

      return url;
    } else {
      throw Exception("Could not fetch iCalendar resource URL");
    }
  }

  /// Find the one link starting with the "webcal://" protocol.
  String _getHrefOfLinkWithWebcalProtocol(List<Element> elements) {
    for (Element e in elements) {
      String href = e.attributes["href"];

      if (href != null && href.startsWith("webcal")) {
        return href;
      }
    }

    return null;
  }
}
