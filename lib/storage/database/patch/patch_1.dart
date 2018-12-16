import 'package:guide7/storage/database/patch/database_patch.dart';
import 'package:sqflite/sqflite.dart';

/// Patch 1 is the first patch for the database and thus creates
/// basic tables for the database.
/// In this version we create the notice board entry table.
class Patch1 extends DatabasePatch {
  static const int _version = 1;

  /// Const constructor.
  const Patch1();

  @override
  int getVersion() => _version;

  @override
  Future<void> upgrade(Database db, int currentVersion) async {
    await db.transaction((transaction) async {
      await transaction.execute("""
      CREATE TABLE NOTICE_BOARD_ENTRY (
        id INTEGER,
        title TEXT,
        author TEXT,
        content TEXT,
        valid_from DATE,
        valid_to DATE,
        PRIMARY KEY (ID)
      )
      """);
    });
  }

  @override
  Future<void> downgrade(Database db, int currentVersion) async {
    await db.transaction((transaction) async {
      await transaction.execute("""
      DROP TABLE NOTICE_BOARD_ENTRY
      """);
    });
  }
}
