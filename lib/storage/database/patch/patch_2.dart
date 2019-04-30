import 'dart:async';

import 'package:guide7/storage/database/patch/database_patch.dart';
import 'package:sqflite/sqflite.dart';

/// This patch adds a table to cache hm persons.
class Patch2 extends DatabasePatch {
  /// Version of the patch.
  static const int _version = 2;

  /// Constant constructor.
  const Patch2();

  @override
  int getVersion() => _version;

  @override
  Future<void> upgrade(Database db, int currentVersion) async {
    await db.transaction((transaction) async {
      await transaction.execute("""
      CREATE TABLE HM_PERSON (
        id INTEGER,
        name TEXT,
        room TEXT,
        telephoneNumber TEXT,
        image BLOB,
        PRIMARY KEY (id)
      )
      """);
    });
  }

  @override
  Future<void> downgrade(Database db, int currentVersion) async {
    await db.transaction((transaction) async {
      await transaction.execute("""
      DROP TABLE HM_PERSON
      """);
    });
  }
}
