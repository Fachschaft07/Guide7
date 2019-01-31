import 'package:guide7/storage/database/patch/database_patch.dart';
import 'package:sqflite/sqflite.dart';

/// This patch adds tables to store custom week plan events.
class Patch5 extends DatabasePatch {
  /// Custom event table name.
  static const String _eventTableName = "CUSTOM_WEEK_PLAN_EVENT";

  /// Version of the patch.
  static const int _version = 5;

  /// Constant constructor.
  const Patch5();

  @override
  int getVersion() => _version;

  @override
  Future<void> upgrade(Database db, int currentVersion) async {
    await db.transaction((transaction) async {
      await transaction.execute("""
      CREATE TABLE $_eventTableName (
        uuid TEXT,
        startDate INTEGER,
        endDate INTEGER,
        title TEXT,
        description TEXT,
        location TEXT,
        dayCycle INTEGER,
        monthCycle INTEGER,
        yearCycle INTEGER,
        PRIMARY KEY (uuid)
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
    });
  }
}
