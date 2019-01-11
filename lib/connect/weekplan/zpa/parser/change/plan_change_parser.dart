import 'package:guide7/model/weekplan/zpa/slot/change/plan_change.dart';
import 'package:guide7/util/parser/parser.dart';
import 'package:intl/intl.dart';

/// Parser parsing slot plan changes of ZPA week plan slots.
class PlanChangeParser implements Parser<Map<String, dynamic>, PlanChange> {
  /// Date format used to parse the change.
  static DateFormat _dateFormat = DateFormat("yyyy-MM-dd");

  /// Constant constructor.
  const PlanChangeParser();

  @override
  PlanChange parse(Map<String, dynamic> json) {
    String changeDescription = json["change_description"];

    bool cancelled = json["canceled"] != null ? json["canceled"] : false;
    bool roomChanged = json["room_changed"] != null ? json["room_changed"] : false;
    bool moved = json["moved"] != null ? json["moved"] : false;

    List<String> alternateRooms;
    if (roomChanged || moved) {
      alternateRooms = List<String>();

      if (json["alt_rooms"] != null) {
        for (final alternateRoom in json["alt_rooms"]) {
          alternateRooms.add(alternateRoom);
        }
      }
    }

    DateTime alternateStartDate;
    if (moved) {
      if (json["alt_date"] != null && json["alt_time"] != null) {
        alternateStartDate = _parseDateTime(json["alt_date"], json["alt_time"]);
      }
    }

    return PlanChange(
      changeDescription: changeDescription,
      cancelled: cancelled,
      roomChanged: roomChanged,
      moved: moved,
      alternateRooms: alternateRooms,
      alternateStartDate: alternateStartDate,
    );
  }

  /// Parse the date time for the slot.
  static DateTime _parseDateTime(String dateString, String time) {
    DateTime date = _dateFormat.parse(dateString);

    List<String> parts = time.split(":");

    int hour = int.parse(parts[0]);
    int minute = int.parse(parts[1]);

    return DateTime(date.year, date.month, date.day, hour, minute);
  }
}
