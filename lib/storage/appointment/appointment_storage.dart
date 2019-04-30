import 'dart:async';

import 'package:guide7/model/appointment/appointment.dart';
import 'package:guide7/storage/database/app_database.dart';
import 'package:guide7/storage/storage.dart';

/// Storage storing Appointment instances.
class AppointmentStorage implements Storage<List<Appointment>> {
  /// Table name of where to store the appointment instances in the database.
  static const String _tableName = "APPOINTMENT";

  /// Storage instance.
  static const AppointmentStorage _instance = AppointmentStorage._internal();

  /// Get the storage instance.
  factory AppointmentStorage() => _instance;

  /// Internal singleton constructor.
  const AppointmentStorage._internal();

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
  Future<List<Appointment>> read() async {
    var database = await AppDatabase().getDatabase();

    List<Map<String, dynamic>> result = await database.transaction((transaction) async {
      return await transaction.query(_tableName);
    });

    return _convertMapsToAppointments(result);
  }

  @override
  Future<void> write(List<Appointment> data) async {
    await clear();

    var database = await AppDatabase().getDatabase();

    await database.transaction((transaction) async {
      var batch = transaction.batch();

      for (int i = 0; i < data.length; i++) {
        batch.insert(_tableName, _convertAppointmentToMap(i + 1, data[i]));
      }

      return await batch.commit(noResult: true);
    });
  }

  /// Convert table sets to appointment instances.
  List<Appointment> _convertMapsToAppointments(List<Map<String, dynamic>> maps) {
    List<Appointment> result = new List<Appointment>(maps.length);

    for (int i = 0; i < maps.length; i++) {
      result[i] = _convertMapToAppointment(maps[i]);
    }

    return result;
  }

  /// Convert an appointment to a dataset map writable to the database table.
  Map<String, dynamic> _convertAppointmentToMap(int id, Appointment appointment) {
    return {
      "id": id,
      "uid": appointment.uid,
      "startDate": appointment.start.millisecondsSinceEpoch,
      "endDate": appointment.end.millisecondsSinceEpoch,
      "summary": appointment.summary,
      "description": appointment.description,
      "location": appointment.location,
    };
  }

  /// Convert table dataset [map] to appointment instance.
  Appointment _convertMapToAppointment(Map<String, dynamic> map) {
    return Appointment(
      uid: map["uid"],
      start: DateTime.fromMillisecondsSinceEpoch(map["startDate"]),
      end: DateTime.fromMillisecondsSinceEpoch(map["endDate"]),
      summary: map["summary"],
      description: map["description"],
      location: map["location"],
    );
  }
}
