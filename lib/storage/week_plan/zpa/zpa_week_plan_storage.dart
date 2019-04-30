import 'dart:async';

import 'package:guide7/model/weekplan/zpa/slot/change/plan_change.dart';
import 'package:guide7/model/weekplan/zpa/slot/types/extra_slot.dart';
import 'package:guide7/model/weekplan/zpa/slot/types/regular_slot.dart';
import 'package:guide7/model/weekplan/zpa/slot/types/replace_slot.dart';
import 'package:guide7/model/weekplan/zpa/slot/types/single_slot.dart';
import 'package:guide7/model/weekplan/zpa/slot/zpa_week_plan_slot.dart';
import 'package:guide7/model/weekplan/zpa/zpa_week_plan_event.dart';
import 'package:guide7/storage/database/app_database.dart';
import 'package:guide7/storage/storage.dart';
import 'package:sqflite/sqflite.dart';

/// Storage for ZPA week plan events.
class ZPAWeekPlanStorage implements Storage<List<ZPAWeekPlanEvent>> {
  /// General event table name.
  static const String _eventTableName = "ZPA_WEEKPLAN_EVENT";

  /// Table where to store what calendar weeks are cached.
  static const String _calendarWeekCacheTableName = "${_eventTableName}_CALENDAR_WEEK";

  /// Table name where rooms for each event are stored.
  static const String _roomTableName = "${_eventTableName}_ROOM";

  /// Table name where modules for each event are stored.
  static const String _moduleTableName = "${_eventTableName}_MODULE";

  /// Table name where groups for each event are stored.
  static const String _groupTableName = "${_eventTableName}_GROUP";

  /// Table name where descriptions for each event are stored.
  static const String _descriptionTableName = "${_eventTableName}_DESCRIPTION";

  /// Table name where teachers for each event are stored.
  static const String _teacherTableName = "${_eventTableName}_TEACHER";

  /// Table name where plan changes (if any) are stored for each event.
  static const String _planChangeTableName = "${_eventTableName}_PLAN_CHANGE";

  /// Table name where alternate rooms for plan changes (if any) are stored for each event.
  static const String _planChangeAlternateRoomTableName = "${_planChangeTableName}_ROOM";

  /// Storage instance.
  static const ZPAWeekPlanStorage _instance = ZPAWeekPlanStorage._internal();

  /// Get the storage instance.
  factory ZPAWeekPlanStorage() => _instance;

  /// Internal singleton constructor.
  const ZPAWeekPlanStorage._internal();

  @override
  Future<void> clear() async {
    var database = await AppDatabase().getDatabase();

    await database.transaction((transaction) async {
      await transaction.delete(_eventTableName);
      await transaction.delete(_calendarWeekCacheTableName);
      await transaction.delete(_roomTableName);
      await transaction.delete(_descriptionTableName);
      await transaction.delete(_teacherTableName);
      await transaction.delete(_groupTableName);
      await transaction.delete(_moduleTableName);
      await transaction.delete(_planChangeTableName);
      await transaction.delete(_planChangeAlternateRoomTableName);
    });
  }

  @override
  Future<bool> isEmpty() async {
    var database = await AppDatabase().getDatabase();

    List<Map<String, dynamic>> result = await database.rawQuery("""
    SELECT COUNT(*) FROM $_eventTableName
    """);

    assert(result.length == 1);
    assert(result[0].values.length == 1);

    var value = result[0].values.first;

    assert(value is int);

    return (value as int) == 0;
  }

  /// Check if there are any events cached for the passed [calendarWeek].
  Future<bool> hasEventsForCalendarWeek(int calendarWeek) async {
    var database = await AppDatabase().getDatabase();

    List<Map<String, dynamic>> result = await database.rawQuery("""
    SELECT COUNT(*) FROM $_calendarWeekCacheTableName
    WHERE calendarWeek = $calendarWeek
    """);

    assert(result.length == 1);
    assert(result[0].values.length == 1);

    var value = result[0].values.first;

    assert(value is int);

    return (value as int) != 0;
  }

  @override
  Future<List<ZPAWeekPlanEvent>> read() async {
    throw Exception("Can only read per calendar week. This operation is not supported.");
  }

  @override
  Future<void> write(List<ZPAWeekPlanEvent> data) async {
    throw Exception("Can only write per calendar week. This operation is not supported.");
  }

  /// Write passed [events] for the passed [calendarWeek].
  Future<void> writeEvents(List<ZPAWeekPlanEvent> events, int calendarWeek) async {
    var database = await AppDatabase().getDatabase();

    await database.transaction((transaction) async {
      Batch batch = transaction.batch();

      /// First and foremost clear events for the passed calendar week.
      _clearEvents(calendarWeek, batch);

      // Add the calendar week to the cached calendar weeks table.
      batch.insert(_calendarWeekCacheTableName, {
        "calendarWeek": calendarWeek,
      });

      for (int i = 0; i < events.length; i++) {
        ZPAWeekPlanEvent event = events[i];
        int id = i + 1;

        // Insert general information.
        batch.insert(_eventTableName, _convertEventToMap(id, calendarWeek, event));

        _storeSlot(batch, event.slot, id, calendarWeek);
      }

      return await batch.commit(noResult: true);
    });
  }

  /// Clear events for the passed calendar week.
  void _clearEvents(int calendarWeek, Batch batch) {
    String where = "calendarWeek = $calendarWeek";

    batch.delete(_eventTableName, where: where);
    batch.delete(_calendarWeekCacheTableName, where: where);
    batch.delete(_roomTableName, where: where);
    batch.delete(_descriptionTableName, where: where);
    batch.delete(_teacherTableName, where: where);
    batch.delete(_groupTableName, where: where);
    batch.delete(_moduleTableName, where: where);
    batch.delete(_planChangeTableName, where: where);
    batch.delete(_planChangeAlternateRoomTableName, where: where);
  }

  /// Read events for the passed [calendarWeek].
  Future<List<ZPAWeekPlanEvent>> readEvents(int calendarWeek) async {
    var database = await AppDatabase().getDatabase();

    List<Map<String, dynamic>> eventsResult = await database.transaction((transaction) async {
      return await transaction.rawQuery("""
      SELECT * FROM $_eventTableName
      WHERE calendarWeek = $calendarWeek
      """);
    });

    List<Map<String, dynamic>> roomsResult = await database.transaction((transaction) async {
      return await transaction.rawQuery("""
      SELECT * FROM $_roomTableName
      WHERE calendarWeek = $calendarWeek
      """);
    });

    List<Map<String, dynamic>> teachersResult = await database.transaction((transaction) async {
      return await transaction.rawQuery("""
      SELECT * FROM $_teacherTableName
      WHERE calendarWeek = $calendarWeek
      """);
    });

    List<Map<String, dynamic>> descriptionsResult = await database.transaction((transaction) async {
      return await transaction.rawQuery("""
      SELECT * FROM $_descriptionTableName
      WHERE calendarWeek = $calendarWeek
      """);
    });

    List<Map<String, dynamic>> modulesResult = await database.transaction((transaction) async {
      return await transaction.rawQuery("""
      SELECT * FROM $_moduleTableName
      WHERE calendarWeek = $calendarWeek
      """);
    });

    List<Map<String, dynamic>> groupsResult = await database.transaction((transaction) async {
      return await transaction.rawQuery("""
      SELECT * FROM $_groupTableName
      WHERE calendarWeek = $calendarWeek
      """);
    });

    List<Map<String, dynamic>> planChangesResult = await database.transaction((transaction) async {
      return await transaction.rawQuery("""
      SELECT * FROM $_planChangeTableName
      WHERE calendarWeek = $calendarWeek
      """);
    });

    List<Map<String, dynamic>> planChangeAlternateRoomsResult = await database.transaction((transaction) async {
      return await transaction.rawQuery("""
      SELECT * FROM $_planChangeAlternateRoomTableName
      WHERE calendarWeek = $calendarWeek
      """);
    });

    return _convertDataSetsToEvents(
      eventsResult,
      roomsResult,
      teachersResult,
      descriptionsResult,
      modulesResult,
      groupsResult,
      planChangesResult,
      planChangeAlternateRoomsResult,
    );
  }

  /// Convert the passed [event] to a map writable to the database table.
  Map<String, dynamic> _convertEventToMap(int id, int calendarWeek, ZPAWeekPlanEvent event) {
    return {
      "calendarWeek": calendarWeek,
      "id": id,
      "startDate": event.start.millisecondsSinceEpoch,
      "endDate": event.end.millisecondsSinceEpoch,
      "type": event.slot.type,
    };
  }

  /// Store the passed [slot] to the passed [batch].
  void _storeSlot(Batch batch, ZPAWeekPlanSlot slot, int id, int calendarWeek) {
    // Store teachers.
    if (slot.teachers != null && slot.teachers.isNotEmpty) {
      for (String teacher in slot.teachers) {
        batch.insert(_teacherTableName, {
          "calendarWeek": calendarWeek,
          "id": id,
          "teacher": teacher,
        });
      }
    }

    // Store rooms.
    if (slot.rooms != null && slot.rooms.isNotEmpty) {
      for (String teacher in slot.rooms) {
        batch.insert(_roomTableName, {
          "calendarWeek": calendarWeek,
          "id": id,
          "room": teacher,
        });
      }
    }

    if (slot is RegularSlot) {
      _storeRegularSlot(batch, slot, id, calendarWeek);
    } else if (slot is ReplaceSlot) {
      _storeReplaceSlot(batch, slot, id, calendarWeek);
    } else if (slot is SingleSlot) {
      _storeSingleSlot(batch, slot, id, calendarWeek);
    } else if (slot is ExtraSlot) {
      _storeExtraSlot(batch, slot, id, calendarWeek);
    } else {
      throw Exception("Slot type unknown");
    }
  }

  /// Store a regular slot.
  void _storeRegularSlot(Batch batch, RegularSlot slot, int id, int calendarWeek) {
    // Store groups
    if (slot.groups != null && slot.groups.isNotEmpty) {
      for (String group in slot.groups) {
        batch.insert(_groupTableName, {
          "calendarWeek": calendarWeek,
          "id": id,
          "groupName": group,
        });
      }
    }

    // Store descriptions
    if (slot.descriptions != null && slot.descriptions.isNotEmpty) {
      for (String description in slot.descriptions) {
        batch.insert(_descriptionTableName, {
          "calendarWeek": calendarWeek,
          "id": id,
          "description": description,
        });
      }
    }

    // Store modules
    if (slot.modules != null && slot.modules.isNotEmpty) {
      for (String module in slot.modules) {
        batch.insert(_moduleTableName, {
          "calendarWeek": calendarWeek,
          "id": id,
          "module": module,
        });
      }
    }

    // Store plan change (if any)
    if (slot.hasPlanChange) {
      _storePlanChange(batch, slot.planChange, id, calendarWeek);
    }
  }

  /// Store the passed [planChange] using the passed [batch].
  void _storePlanChange(Batch batch, PlanChange planChange, int id, int calendarWeek) {
    // Insert general plan change info.
    batch.insert(_planChangeTableName, {
      "calendarWeek": calendarWeek,
      "id": id,
      "changeDescription": planChange.changeDescription,
      "cancelled": planChange.cancelled ? 1 : 0,
      "moved": planChange.moved ? 1 : 0,
      "roomChanged": planChange.roomChanged ? 1 : 0,
      "alternateStartDate": planChange.alternateStartDate != null ? planChange.alternateStartDate.millisecondsSinceEpoch : null,
    });

    // Insert alternate rooms (if any).
    if (planChange.alternateRooms != null && planChange.alternateRooms.isNotEmpty) {
      for (String alternateRoom in planChange.alternateRooms) {
        batch.insert(_planChangeAlternateRoomTableName, {
          "calendarWeek": calendarWeek,
          "id": id,
          "alternateRoom": alternateRoom,
        });
      }
    }
  }

  /// Store a single slot.
  void _storeSingleSlot(Batch batch, SingleSlot slot, int id, int calendarWeek) {
    if (slot.description != null) {
      batch.insert(_descriptionTableName, {
        "calendarWeek": calendarWeek,
        "id": id,
        "description": slot.description,
      });
    }
  }

  /// Store a extra slot.
  void _storeExtraSlot(Batch batch, ExtraSlot slot, int id, int calendarWeek) {
    if (slot.description != null) {
      batch.insert(_descriptionTableName, {
        "calendarWeek": calendarWeek,
        "id": id,
        "description": slot.description,
      });
    }

    // Store groups
    if (slot.groups != null && slot.groups.isNotEmpty) {
      for (String group in slot.groups) {
        batch.insert(_groupTableName, {
          "calendarWeek": calendarWeek,
          "id": id,
          "groupName": group,
        });
      }
    }
  }

  /// Store a replace slot.
  void _storeReplaceSlot(Batch batch, ReplaceSlot slot, int id, int calendarWeek) {
    if (slot.description != null) {
      batch.insert(_descriptionTableName, {
        "calendarWeek": calendarWeek,
        "id": id,
        "description": slot.description,
      });
    }

    // Store groups
    if (slot.groups != null && slot.groups.isNotEmpty) {
      for (String group in slot.groups) {
        batch.insert(_groupTableName, {
          "calendarWeek": calendarWeek,
          "id": id,
          "groupName": group,
        });
      }
    }
  }

  /// Convert the passed data sets to events.
  List<ZPAWeekPlanEvent> _convertDataSetsToEvents(
    List<Map<String, dynamic>> eventsResult,
    List<Map<String, dynamic>> roomsResult,
    List<Map<String, dynamic>> teachersResult,
    List<Map<String, dynamic>> descriptionsResult,
    List<Map<String, dynamic>> modulesResult,
    List<Map<String, dynamic>> groupsResult,
    List<Map<String, dynamic>> planChangesResult,
    List<Map<String, dynamic>> planChangeAlternateRoomsResult,
  ) {
    Map<int, List<Map<String, dynamic>>> roomsLookup = _generateLookup(roomsResult);
    Map<int, List<Map<String, dynamic>>> teacherLookup = _generateLookup(teachersResult);
    Map<int, List<Map<String, dynamic>>> descriptionLookup = _generateLookup(descriptionsResult);
    Map<int, List<Map<String, dynamic>>> moduleLookup = _generateLookup(modulesResult);
    Map<int, List<Map<String, dynamic>>> groupLookup = _generateLookup(groupsResult);
    Map<int, List<Map<String, dynamic>>> planChangeLookup = _generateLookup(planChangesResult);
    Map<int, List<Map<String, dynamic>>> planChangeAlternateRoomLookup = _generateLookup(planChangeAlternateRoomsResult);

    List<ZPAWeekPlanEvent> result = List<ZPAWeekPlanEvent>();

    for (Map<String, dynamic> dataSet in eventsResult) {
      int id = dataSet["id"];
      String type = dataSet["type"];
      DateTime start = DateTime.fromMillisecondsSinceEpoch(dataSet["startDate"]);
      DateTime end = DateTime.fromMillisecondsSinceEpoch(dataSet["endDate"]);

      List<String> rooms = roomsLookup[id]?.map((entry) => entry["room"] as String)?.toList(growable: false);
      List<String> teachers = teacherLookup[id]?.map((entry) => entry["teacher"] as String)?.toList(growable: false);
      List<String> descriptions = descriptionLookup[id]?.map((entry) => entry["description"] as String)?.toList(growable: false);
      List<String> modules = moduleLookup[id]?.map((entry) => entry["module"] as String)?.toList(growable: false);
      List<String> groups = groupLookup[id]?.map((entry) => entry["groupName"] as String)?.toList(growable: false);

      if (type == "regular") {
        // Get plan change.
        List<String> alternateRooms = planChangeAlternateRoomLookup[id]?.map((entry) => entry["alternateRoom"])?.toList(growable: false);
        PlanChange change = planChangeLookup[id]
            ?.map((entry) => PlanChange(
                  changeDescription: entry["changeDescription"],
                  cancelled: entry["cancelled"] == 1,
                  roomChanged: entry["roomChanged"] == 1,
                  moved: entry["moved"] == 1,
                  alternateStartDate: entry["alternateStartDate"] != null ? DateTime.fromMillisecondsSinceEpoch(entry["alternateStartDate"]) : null,
                  alternateRooms: alternateRooms,
                ))
            ?.first;

        result.add(ZPAWeekPlanEvent(
          slot: RegularSlot(
            type: type,
            rooms: rooms,
            teachers: teachers,
            start: start,
            end: end,
            descriptions: descriptions,
            modules: modules,
            groups: groups,
            planChange: change,
          ),
        ));
      } else if (type == "single") {
        result.add(ZPAWeekPlanEvent(
          slot: SingleSlot(
            type: type,
            rooms: rooms,
            teachers: teachers,
            start: start,
            end: end,
            description: descriptions != null && descriptions.isNotEmpty ? descriptions.first : null,
          ),
        ));
      } else if (type == "replace") {
        result.add(ZPAWeekPlanEvent(
          slot: ReplaceSlot(
            type: type,
            rooms: rooms,
            teachers: teachers,
            start: start,
            end: end,
            description: descriptions != null && descriptions.isNotEmpty ? descriptions.first : null,
            groups: groups,
          ),
        ));
      } else if (type == "extra") {
        result.add(ZPAWeekPlanEvent(
          slot: ExtraSlot(
            type: type,
            rooms: rooms,
            teachers: teachers,
            start: start,
            end: end,
            description: descriptions != null && descriptions.isNotEmpty ? descriptions.first : null,
            groups: groups,
          ),
        ));
      } else {
        throw Exception("Slot type unknown");
      }
    }

    return result;
  }

  /// Map all entries from their id to their dataset for faster lookups.
  Map<int, List<Map<String, dynamic>>> _generateLookup(List<Map<String, dynamic>> dataSets) {
    Map<int, List<Map<String, dynamic>>> lookup = Map();

    for (Map<String, dynamic> dataSet in dataSets) {
      int id = dataSet["id"];

      lookup.putIfAbsent(id, () => List<Map<String, dynamic>>()).add(dataSet);
    }

    return lookup;
  }
}
