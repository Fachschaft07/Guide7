import 'dart:async';

import 'package:guide7/storage/database/patch/database_patch.dart';
import 'package:sqflite/sqflite.dart';

/// This patch adds tables to store meal plans.
class Patch6 extends DatabasePatch {
  /// Meal plan table name.
  static const String _mealTableName = "MEAL_PLAN";

  /// Name of table holding meal prices.
  static const String _mealPriceTableName = "MEAL_PLAN_PRICE";

  /// Name of the table holding meal notes.
  static const String _mealNotesTableName = "MEAL_PLAN_NOTE";

  /// Version of the patch.
  static const int _version = 6;

  /// Constant constructor.
  const Patch6();

  @override
  int getVersion() => _version;

  @override
  Future<void> upgrade(Database db, int currentVersion) async {
    await db.transaction((transaction) async {
      await transaction.execute("""
      CREATE TABLE $_mealTableName (
        canteenId INTEGER,
        date INTEGER,
        mealId INTEGER,
        name TEXT,
        category TEXT,
        PRIMARY KEY (canteenId, date, mealId)
      )
      """);

      await transaction.execute("""
      CREATE TABLE $_mealPriceTableName (
        canteenId INTEGER,
        date INTEGER,
        mealId INTEGER,
        students REAL,
        employees REAL,
        pupils REAL,
        others REAL,
        PRIMARY KEY (canteenId, date, mealId)
      )
      """);

      await transaction.execute("""
      CREATE TABLE $_mealNotesTableName (
        canteenId INTEGER,
        date INTEGER,
        mealId INTEGER,
        note TEXT,
        PRIMARY KEY (canteenId, date, mealId, note)
      )
      """);
    });
  }

  @override
  Future<void> downgrade(Database db, int currentVersion) async {
    await db.transaction((transaction) async {
      await transaction.execute("""
      DROP TABLE $_mealTableName
      """);

      await transaction.execute("""
      DROP TABLE $_mealPriceTableName
      """);

      await transaction.execute("""
      DROP TABLE $_mealNotesTableName
      """);
    });
  }
}
