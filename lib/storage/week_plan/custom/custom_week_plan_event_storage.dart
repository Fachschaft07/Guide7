import 'package:guide7/model/weekplan/custom/custom_event.dart';
import 'package:guide7/model/weekplan/custom/custom_event_cycle.dart';
import 'package:guide7/storage/database/app_database.dart';
import 'package:guide7/storage/storage.dart';

/// Storage for custom week plan events.
class CustomWeekPlanEventStorage implements Storage<List<CustomEvent>> {
  /// Custom event table name.
  static const String _tableName = "CUSTOM_WEEK_PLAN_EVENT";

  /// Storage instance.
  static const CustomWeekPlanEventStorage _instance = CustomWeekPlanEventStorage._internal();

  /// Get the storage instance.
  factory CustomWeekPlanEventStorage() => _instance;

  /// Internal singleton constructor.
  const CustomWeekPlanEventStorage._internal();

  @override
  Future<void> clear() async {
    var database = await AppDatabase().getDatabase();

    await database.transaction((transaction) async {
      return await transaction.delete(_tableName);
    });
  }

  /// Clear a single event.
  Future<void> clearEvent(String uuid) async {
    final database = await AppDatabase().getDatabase();

    String where = "uuid = '$uuid'";

    await database.transaction((transaction) async {
      return await transaction.delete(_tableName, where: where);
    });
  }

  @override
  Future<bool> isEmpty() async {
    var database = await AppDatabase().getDatabase();

    List<Map<String, dynamic>> result = await database.rawQuery("""
    SELECT COUNT(*) FROM $_tableName
    """);

    assert(result.length == 1);
    assert(result[0].values.length == 1);

    var value = result[0].values.first;

    assert(value is int);

    return (value as int) == 0;
  }

  @override
  Future<List<CustomEvent>> read() async {
    var database = await AppDatabase().getDatabase();

    List<Map<String, dynamic>> result = await database.transaction((transaction) async {
      return await transaction.query(_tableName);
    });

    return _convertMapsToEvents(result);
  }

  /// Read a single event.
  Future<CustomEvent> readEvent(String uuid) async {
    final database = await AppDatabase().getDatabase();

    String where = "uuid = '$uuid'";

    List<Map<String, dynamic>> result = await database.transaction((transaction) async {
      return await transaction.query(_tableName, where: where);
    });

    assert(result.length <= 1);

    if (result.length == 1) {
      return _convertMapToEvent(result.first);
    }

    return null;
  }

  @override
  Future<void> write(List<CustomEvent> data) async {
    var database = await AppDatabase().getDatabase();

    await database.transaction((transaction) async {
      var batch = transaction.batch();

      for (int i = 0; i < data.length; i++) {
        batch.insert(_tableName, _convertEventToMap(data[i]));
      }

      return await batch.commit(noResult: true);
    });
  }

  /// Write a single event.
  Future<void> writeEvent(CustomEvent event) async {
    var database = await AppDatabase().getDatabase();

    await database.transaction((transaction) async {
      return await transaction.insert(_tableName, _convertEventToMap(event));
    });
  }

  /// Convert table sets to event instances.
  List<CustomEvent> _convertMapsToEvents(List<Map<String, dynamic>> maps) {
    List<CustomEvent> result = new List<CustomEvent>(maps.length);

    for (int i = 0; i < maps.length; i++) {
      result[i] = _convertMapToEvent(maps[i]);
    }

    return result;
  }

  /// Convert table dataset [map] to event instance.
  CustomEvent _convertMapToEvent(Map<String, dynamic> map) {
    return CustomEvent(
      uuid: map["uuid"],
      start: DateTime.fromMillisecondsSinceEpoch(map["startDate"]),
      end: DateTime.fromMillisecondsSinceEpoch(map["endDate"]),
      title: map["title"],
      description: map["description"],
      location: map["location"],
      cycle: CustomEventCycle(
        days: map["dayCycle"],
        months: map["monthCycle"],
        years: map["yearCycle"],
      ),
    );
  }

  /// Convert event instance to table dataset [map].
  Map<String, dynamic> _convertEventToMap(CustomEvent event) {
    return {
      "uuid": event.uuid,
      "startDate": event.start.millisecondsSinceEpoch,
      "endDate": event.end.millisecondsSinceEpoch,
      "title": event.title,
      "description": event.description,
      "location": event.location,
      "dayCycle": event.cycle.days,
      "monthCycle": event.cycle.months,
      "yearCycle": event.cycle.years,
    };
  }
}
