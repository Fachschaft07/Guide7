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
    // Create table for notice board entries.
    await db.execute("""
      CREATE TABLE NOTICE_BOARD_ENTRY (
        ID INTEGER,
        Author TEXT,
        Content TEXT,
        Valid_From DATE,
        Valid_To DATE,
        PRIMARY KEY (ID)
      );
    """);
  }

  @override
  Future<void> downgrade(Database db, int currentVersion) async {
    await db.execute("""
      DROP TABLE NOTICE_BOARD_ENTRY;
    """);
  }
}
