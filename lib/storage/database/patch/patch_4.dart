import 'package:guide7/storage/database/patch/database_patch.dart';
import 'package:sqflite/sqflite.dart';

/// This patch adds tables to cache ZPA week plan events.
class Patch4 extends DatabasePatch {
  /// General event table name.
  static const String _eventTableName = "ZPA_WEEKPLAN_EVENT";

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

  /// Version of the patch.
  static const int _version = 4;

  /// Constant constructor.
  const Patch4();

  @override
  int getVersion() => _version;

  @override
  Future<void> upgrade(Database db, int currentVersion) async {
    await db.transaction((transaction) async {
      // General event table
      await transaction.execute("""
      CREATE TABLE $_eventTableName (
        calendarWeek INTEGER,
        id INTEGER,
        startDate INTEGER,
        endDate INTEGER,
        type TEXT,
        PRIMARY KEY (calendarWeek, id)
      )
      """);

      // Rooms for each event defined by calendar week and id
      await transaction.execute("""
      CREATE TABLE $_roomTableName (
        calendarWeek INTEGER,
        id INTEGER,
        room TEXT,
        PRIMARY KEY (calendarWeek, id, room)
      )
      """);

      // Descriptions for each event defined by calendar week and id
      await transaction.execute("""
      CREATE TABLE $_descriptionTableName (
        calendarWeek INTEGER,
        id INTEGER,
        description TEXT,
        PRIMARY KEY (calendarWeek, id, description)
      )
      """);

      // Modules for each event defined by calendar week and id
      await transaction.execute("""
      CREATE TABLE $_moduleTableName (
        calendarWeek INTEGER,
        id INTEGER,
        module TEXT,
        PRIMARY KEY (calendarWeek, id, module)
      )
      """);

      // Teachers for each event defined by calendar week and id
      await transaction.execute("""
      CREATE TABLE $_teacherTableName (
        calendarWeek INTEGER,
        id INTEGER,
        teacher TEXT,
        PRIMARY KEY (calendarWeek, id, teacher)
      )
      """);

      // Groups for each event defined by calendar week and id
      await transaction.execute("""
      CREATE TABLE $_groupTableName (
        calendarWeek INTEGER,
        id INTEGER,
        group TEXT,
        PRIMARY KEY (calendarWeek, id, group)
      )
      """);

      // Plan changes for each event defined by calendar week and id
      await transaction.execute("""
      CREATE TABLE $_planChangeTableName (
        calendarWeek INTEGER,
        id INTEGER,
        changeDescription TEXT,
        cancelled INTEGER,
        moved INTEGER,
        roomChanged INTEGER,
        alternateStartDate INTEGER,
        PRIMARY KEY (calendarWeek, id)
      )
      """);

      // Plan change alternate rooms
      await transaction.execute("""
      CREATE TABLE $_planChangeAlternateRoomTableName (
        calendarWeek INTEGER,
        id INTEGER,
        alternateRoom,
        PRIMARY KEY (calendarWeek, id, alternateRoom)
      )
      """);
    });
  }

  @override
  Future<void> downgrade(Database db, int currentVersion) async {
    await db.transaction((transaction) async {
      await transaction.execute("""
      DROP TABLE $_eventTableName
      """);

      await transaction.execute("""
      DROP TABLE $_teacherTableName
      """);

      await transaction.execute("""
      DROP TABLE $_roomTableName
      """);

      await transaction.execute("""
      DROP TABLE $_groupTableName
      """);

      await transaction.execute("""
      DROP TABLE $_moduleTableName
      """);

      await transaction.execute("""
      DROP TABLE $_descriptionTableName
      """);

      await transaction.execute("""
      DROP TABLE $_planChangeTableName
      """);

      await transaction.execute("""
      DROP TABLE $_planChangeAlternateRoomTableName
      """);
    });
  }
}
