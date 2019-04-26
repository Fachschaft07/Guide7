import 'dart:async';

import 'package:flutter/material.dart';
import 'package:guide7/model/room/room.dart';

/// Repository providing free rooms.
abstract class FreeRoomsRepository {
  /// Get free rooms for the passed [date], [startTime] and [endTime].
  Future<List<Room>> getFreeRooms(DateTime date, TimeOfDay startTime, TimeOfDay endTime);
}
