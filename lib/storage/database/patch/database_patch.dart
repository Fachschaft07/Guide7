import 'dart:async';

import 'package:sqflite/sqflite.dart';

/// Patch for the database.
abstract class DatabasePatch {
  /// Const constructor.
  const DatabasePatch();

  /// Get the version the database is at after applying the patch.
  int getVersion();

  /// Whether to do the upgrade patch.
  bool handleUpgrade(int currentVersion) => currentVersion < getVersion();

  /// Whether to do the downgrade patch.
  bool handleDowngrade(int currentVersion) => currentVersion >= getVersion();

  /// Upgrade the version with this patch.
  Future<void> upgrade(Database db, int currentVersion);

  /// Downgrade the version with this patch.
  Future<void> downgrade(Database db, int currentVersion);
}
