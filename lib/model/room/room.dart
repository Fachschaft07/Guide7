import 'package:meta/meta.dart';

/// Room on some university campus.
class Room {
  /// Id of the room.
  final int roomId;

  /// Number of the room.
  final String roomNumber;

  /// Count of available seats in the room.
  final int seatCount;

  /// Create room.
  Room({
    @required this.roomId,
    @required this.roomNumber,
    @required this.seatCount,
  });
}
