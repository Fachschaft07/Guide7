import 'dart:convert';

import 'package:guide7/connect/appointment/appointment_repository.dart';
import 'package:guide7/connect/appointment/parser/appointment_ical_parser.dart';
import 'package:guide7/model/appointment/appointment.dart';
import 'package:guide7/storage/appointment/appointment_storage.dart';
import 'package:guide7/util/parser/parser.dart';
import 'package:http/http.dart' as http;
import 'package:html/dom.dart';
import 'package:html/parser.dart' as htmlParser;

/// Repository delivering appointments for the munich university of applied sciences.
class HMAppointmentRepository implements AppointmentRepository {
  /// Where to find the iCalendar resource URL.
  static const String _resource = "https://www.hm.edu/studierende/mein_studium/verlauf/termine.de.html";

  /// Parser parsing iCalendar formatted strings to appointments.
  static const Parser<String, List<Appointment>> _iCalParser = AppointmentICalParser();

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

    return _iCalParser.parse(iCal);
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
