import 'dart:async';

import 'package:flutter/material.dart';
import 'package:guide7/connect/free_rooms/free_rooms_repository.dart';
import 'package:guide7/model/room/room.dart';

/// Mock repository fetching free/available rooms from the ZPA services.
class MockFreeRoomsRepository implements FreeRoomsRepository {
  @override
  Future<List<Room>> getFreeRooms(DateTime date, TimeOfDay startTime, TimeOfDay endTime) async {
    return [
      Room(roomId: 1, roomNumber: "R1.006", seatCount: 40),
      Room(roomId: 2, roomNumber: "R1.007", seatCount: 20),
      Room(roomId: 3, roomNumber: "R1.008", seatCount: 12),
    ];
  }
}
