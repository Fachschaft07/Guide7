import 'dart:async';

import 'package:guide7/storage/storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Storage storing the next route to display when clicking on a notification.
class RouteStorage implements Storage<String> {
  /// Base key in the shared preferences.
  static const String _baseKey = "next_route";

  /// Instance of the singleton.
  static RouteStorage _instance = RouteStorage._internal();

  /// Factory constructor for the singleton.
  factory RouteStorage() => _instance;

  /// Internal constructor.
  RouteStorage._internal();

  @override
  Future<void> clear() async {
    SharedPreferences prefs = await _getPrefs();

    for (final key in prefs.getKeys().where((key) => key.startsWith(_baseKey)).toList(growable: false)) {
      await prefs.remove(key);
    }
  }

  @override
  Future<bool> isEmpty() async {
    SharedPreferences prefs = await _getPrefs();

    return prefs.getKeys().where((key) => key.contains(_baseKey)).isEmpty;
  }

  @override
  Future<String> read() async {
    SharedPreferences prefs = await _getPrefs();

    String nextRoute = prefs.getString("$_baseKey");

    return nextRoute;
  }

  @override
  Future<void> write(String data) async {
    SharedPreferences prefs = await _getPrefs();

    await prefs.setString("$_baseKey", data);
  }

  /// Get shared preferences.
  Future<SharedPreferences> _getPrefs() async => await SharedPreferences.getInstance();
}
