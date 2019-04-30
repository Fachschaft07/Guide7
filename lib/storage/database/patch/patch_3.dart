import 'dart:async';

import 'package:guide7/storage/database/patch/database_patch.dart';
import 'package:sqflite/sqflite.dart';

/// This patch adds a table to cache appointments.
class Patch3 extends DatabasePatch {
  /// Version of the patch.
  static const int _version = 3;

  /// Constant constructor.
  const Patch3();

  @override
  int getVersion() => _version;

  @override
  Future<void> upgrade(Database db, int currentVersion) async {
    await db.transaction((transaction) async {
      await transaction.execute("""
      CREATE TABLE APPOINTMENT (
        id INTEGER,
        uid TEXT,
        summary TEXT,
        description TEXT,
        location TEXT,
        startDate INTEGER,
        endDate INTEGER,
        PRIMARY KEY (id)
      )
      """);
    });
  }

  @override
  Future<void> downgrade(Database db, int currentVersion) async {
    await db.transaction((transaction) async {
      await transaction.execute("""
      DROP TABLE APPOINTMENT
      """);
    });
  }
}
