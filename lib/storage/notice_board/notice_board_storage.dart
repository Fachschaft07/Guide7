import 'package:guide7/model/notice_board/notice_board_entry.dart';
import 'package:guide7/storage/database/app_database.dart';
import 'package:guide7/storage/storage.dart';
import 'package:intl/intl.dart';

/// Storage for notice board entries.
class NoticeBoardStorage implements Storage<List<NoticeBoardEntry>> {
  /// Notice board storage table name.
  static const String _tableName = "NOTICE_BOARD_ENTRY";

  /// Date formatter formatting dates from and to the correct format for the database.
  static DateFormat _dateFormatter = DateFormat("yyyy-MM-dd");

  /// Storage instance.
  static const NoticeBoardStorage _instance = NoticeBoardStorage._internal();

  /// Get the storage instance.
  factory NoticeBoardStorage() => _instance;

  /// Internal singleton constructor.
  const NoticeBoardStorage._internal();

  @override
  Future<void> clear() async {
    var database = await AppDatabase().getDatabase();

    await database.transaction((transaction) async {
      return await transaction.delete(_tableName);
    });
  }

  @override
  Future<List<NoticeBoardEntry>> read() async {
    var database = await AppDatabase().getDatabase();

    List<Map<String, dynamic>> result = await database.transaction((transaction) async {
      return await transaction.query(_tableName);
    });

    return _convertMapToEntries(result);
  }

  @override
  Future<void> write(List<NoticeBoardEntry> data) async {
    await clear();

    var database = await AppDatabase().getDatabase();

    await database.transaction((transaction) async {
      var batch = transaction.batch();

      for (int i = 0; i < data.length; i++) {
        batch.insert(_tableName, _convertEntryToMap(i + 1, data[i]));
      }

      return await batch.commit(noResult: true);
    });
  }

  @override
  Future<bool> isEmpty() async {
    var database = await AppDatabase().getDatabase();

    List<Map<String, dynamic>> result = await database.rawQuery("""
    SELECT COUNT(*) FROM $_tableName
    """);

    assert(result.length == 1);
    assert(result[0].values.length == 1);

    var value = result[0].values.first;

    assert(value is int);

    return (value as int) == 0;
  }

  /// Convert notice board entries to values for an SQL statement.
  Map<String, dynamic> _convertEntryToMap(int id, NoticeBoardEntry entry) {
    return {
      "id": id,
      "author": entry.author,
      "title": entry.title,
      "content": entry.content,
      "valid_from": _dateFormatter.format(entry.validFrom),
      "valid_to": _dateFormatter.format(entry.validTo),
    };
  }

  /// Convert table entries to notice board entries.
  List<NoticeBoardEntry> _convertMapToEntries(List<Map<String, dynamic>> maps) {
    List<NoticeBoardEntry> result = new List<NoticeBoardEntry>(maps.length);

    for (int i = 0; i < maps.length; i++) {
      result[i] = _convertMapToEntry(maps[i]);
    }

    return result;
  }

  /// Convert table entry [map] to notice board entry.
  NoticeBoardEntry _convertMapToEntry(Map<String, dynamic> map) {
    return NoticeBoardEntry(
      author: map["author"],
      title: map["title"],
      content: map["content"],
      validFrom: _dateFormatter.parse(map["valid_from"]),
      validTo: _dateFormatter.parse(map["valid_to"]),
    );
  }
}
