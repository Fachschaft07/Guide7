import 'package:guide7/model/weekplan/zpa/slot/zpa_week_plan_slot.dart';
import 'package:guide7/util/parser/parser.dart';
import 'package:intl/intl.dart';

/// Parser parsing a ZPA week plan slot.
class WeekPlanSlotParser implements Parser<Map<String, dynamic>, ZPAWeekPlanSlot> {
  /// Date format used to parse the slot.
  static DateFormat _dateFormat = DateFormat("yyyy-MM-dd");

  /// Constant constructor.
  const WeekPlanSlotParser();

  @override
  ZPAWeekPlanSlot parse(Map<String, dynamic> json) {
    List<String> rooms = List<String>();
    for (final room in json["rooms"]) {
      rooms.add(room);
    }

    List<String> teachers = List<String>();
    for (final teacher in json["teachers"]) {
      teachers.add(teacher);
    }

    DateTime date = _dateFormat.parse(json["date"]);

    DateTime start = _parseDateTime(date, json["starttime"]);
    DateTime end = _parseDateTime(date, json["endtime"]);

    String type = json["type"];

    return ZPAWeekPlanSlot(
      start: start,
      end: end,
      rooms: rooms,
      teachers: teachers,
      type: type,
    );
  }

  /// Parse the date time for the slot.
  static DateTime _parseDateTime(DateTime date, String time) {
    List<String> parts = time.split(":");

    int hour = int.parse(parts[0]);
    int minute = int.parse(parts[1]);

    return DateTime(date.year, date.month, date.day, hour, minute);
  }
}
