import 'package:guide7/model/hm_people/hm_person.dart';
import 'package:guide7/storage/database/app_database.dart';
import 'package:guide7/storage/storage.dart';

/// Storage storing HMPerson instances.
class HMPersonStorage implements Storage<List<HMPerson>> {
  /// Table name of where to store the HMPerson instances in the database.
  static const String _tableName = "HM_PERSON";

  /// Storage instance.
  static const HMPersonStorage _instance = HMPersonStorage._internal();

  /// Get the storage instance.
  factory HMPersonStorage() => _instance;

  /// Internal singleton constructor.
  const HMPersonStorage._internal();

  @override
  Future<void> clear() async {
    var database = await AppDatabase().getDatabase();

    await database.transaction((transaction) async {
      return await transaction.delete(_tableName);
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

  @override
  Future<List<HMPerson>> read() async {
    var database = await AppDatabase().getDatabase();

    List<Map<String, dynamic>> result = await database.transaction((transaction) async {
      return await transaction.query(_tableName);
    });

    return _convertMapsToPeople(result);
  }

  @override
  Future<void> write(List<HMPerson> data) async {
    await clear();

    var database = await AppDatabase().getDatabase();

    await database.transaction((transaction) async {
      var batch = transaction.batch();

      for (int i = 0; i < data.length; i++) {
        batch.insert(_tableName, _convertPersonToMap(i + 1, data[i]));
      }

      return await batch.commit(noResult: true);
    });
  }

  /// Convert table sets to HMPerson instances.
  List<HMPerson> _convertMapsToPeople(List<Map<String, dynamic>> maps) {
    List<HMPerson> result = new List<HMPerson>(maps.length);

    for (int i = 0; i < maps.length; i++) {
      result[i] = _convertMapToPerson(maps[i]);
    }

    return result;
  }

  /// Convert a person to a dataset map writable to the database table.
  Map<String, dynamic> _convertPersonToMap(int id, HMPerson person) {
    return {
      "id": id,
      "name": person.name,
      "room": person.room,
      "telephoneNumber": person.telephoneNumber,
      "image": person.image,
    };
  }

  /// Convert table dataset [map] to HM Person instance.
  HMPerson _convertMapToPerson(Map<String, dynamic> map) {
    return HMPerson(
      name: map["name"],
      room: map["room"],
      telephoneNumber: map["telephoneNumber"],
      image: map["image"],
    );
  }
}
