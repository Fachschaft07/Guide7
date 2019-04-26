import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:guide7/connect/free_rooms/free_rooms_repository.dart';
import 'package:guide7/connect/login/zpa/util/zpa_variables.dart';
import 'package:guide7/model/room/room.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

/// Repository fetching free/available rooms from the ZPA services.
class ZPAFreeRoomsRepository implements FreeRoomsRepository {
  /// Resource where to find the free rooms webservice.
  static const String _resource = "room_admin/get_free_rooms/";

  /// Date format for the room search API.
  static DateFormat _dateFormat = DateFormat("yyyy-MM-dd");

  @override
  Future<List<Room>> getFreeRooms(DateTime date, TimeOfDay startTime, TimeOfDay endTime) async {
    http.Response httpResponse =
        await http.get("${ZPAVariables.url}/$_resource?date=${_dateFormat.format(date)}&start_time=${_formatTime(startTime)}&end_time=${_formatTime(endTime)}");

    if (httpResponse.statusCode == 200) {
      return _convertJSONToRooms(json.decode(httpResponse.body));
    } else {
      throw Exception("Could not fetch free rooms.");
    }
  }

  /// Format the passed time for the API.
  String _formatTime(TimeOfDay time) => _getIn24HourFormat(time.hour) + _getIn24HourFormat(time.minute);

  /// Get the passed number in 24 hour format.
  /// e. g. number between 0 and 9 will be converted to 00 - 09.
  String _getIn24HourFormat(int number) => number < 10 ? "0" + number.toString() : number.toString();

  /// Convert json to rooms.
  List<Room> _convertJSONToRooms(Map<String, dynamic> json) {
    List<Room> result = List<Room>();

    for (final roomJson in json["free_rooms"]) {
      result.add(Room(
        roomId: roomJson[0],
        roomNumber: roomJson[1],
        seatCount: roomJson[2],
      ));
    }

    return result;
  }
}
