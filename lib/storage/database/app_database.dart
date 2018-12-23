import 'dart:io';

import 'package:guide7/storage/database/patch/database_patch.dart';
import 'package:guide7/storage/database/patch/patch_1.dart';
import 'package:guide7/storage/database/patch/patch_2.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:synchronized/synchronized.dart';

/// Central database of the application.
class AppDatabase {
  /// Version of the database.
  /// NOTE: Increase whenever you add a new patch for the database. See [_patches].
  static const int _databaseVersion = 2;

  /// List of patches for the database.
  /// Make sure this list is ordered after patch versions (newer patches are at the end)!
  /// NOTE: Whenevery you add a new patch, make sure to increase the [_databaseVersion] in this class.
  static const List<DatabasePatch> _patches = [
    Patch1(),
    Patch2(),
  ];

  /// File name of the database.
  static const String _databaseFileName = "guide7.db";

  /// Instance of the app database.
  static const AppDatabase _instance = AppDatabase._internal();

  /// Underlying database.
  static Database _db;

  /// Lock used to avoid race conditions when fetching the database.
  static Lock _lock = Lock();

  /// Factory constructor to provide this singleton.
  factory AppDatabase() => _instance;

  /// Internal constructor.
  const AppDatabase._internal();

  /// Get the underlying data base.
  Future<Database> getDatabase() async {
    if (_db == null) {
      await _lock.synchronized(() async {
        // Check again once entering the synchronized block!
        if (_db == null) {
          _db = await _initializeDatabase();
        }
      });
    }

    return _db;
  }

  /// Initialize a database.
  Future<Database> _initializeDatabase() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, _databaseFileName);

    // Make sure the directory exists.
    try {
      await Directory(databasesPath).create(recursive: true);
    } catch (_) {}

    return await openDatabase(path, version: _databaseVersion, onCreate: _onCreate, onUpgrade: _onUpgrade, onDowngrade: _onDowngrade);
  }

  /// Create the database tables, etc. here.
  void _onCreate(Database db, int version) async {
    _onUpgrade(db, 0, version); // Just redirect to the upgrade mechanism to handle the database creation.
  }

  /// Upgrade the database from the [oldVersion] to the [newVersion].
  /// If you want to create the database, just pass 0 as [oldVersion].
  void _onUpgrade(Database db, int oldVersion, int newVersion) async {
    int currentVersion = oldVersion;

    // Apply all patches in list order!
    for (DatabasePatch patch in _patches) {
      if (patch.handleUpgrade(currentVersion)) {
        try {
          await patch.upgrade(db, currentVersion);
        } catch (e) {
          db.setVersion(currentVersion);
          throw Exception("Database upgrade patch aborted because an error occurred. Database now at version $currentVersion");
        }

        currentVersion = patch.getVersion();
      }
    }
  }

  /// Downgrade the database from the [oldVersion] to the [newVersion].
  void _onDowngrade(Database db, int oldVersion, int newVersion) async {
    int currentVersion = oldVersion;

    /// Apply all patches in reverse order!
    for (DatabasePatch patch in _patches.reversed) {
      if (patch.handleDowngrade(currentVersion)) {
        try {
          await patch.downgrade(db, currentVersion);
        } catch (e) {
          db.setVersion(currentVersion);
          throw Exception("Database downgrade patch aborted because an error occurred. Database now at version $currentVersion");
        }

        currentVersion = patch.getVersion();
      }
    }
  }
}
