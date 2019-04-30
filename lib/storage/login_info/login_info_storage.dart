import 'dart:async';

import 'package:guide7/model/login_info/login_info.dart';
import 'package:guide7/storage/storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Storage storing login info.
class LoginInfoStorage implements Storage<LoginInfo> {
  /// Base key in the shared preferences.
  static const String baseKey = "login_info";

  /// Key of the skipped login attribute.
  static const String skippedLoginKey = "skipped_login";

  /// Instance of the singleton.
  static const LoginInfoStorage _instance = LoginInfoStorage._internal();

  /// Factory constructor for the singleton.
  factory LoginInfoStorage() => _instance;

  /// Internal constructor.
  const LoginInfoStorage._internal();

  @override
  Future<void> clear() async {
    SharedPreferences prefs = await _getPrefs();

    for (final key in prefs.getKeys().where((key) => key.startsWith(baseKey)).toList(growable: false)) {
      await prefs.remove(key);
    }
  }

  @override
  Future<bool> isEmpty() async {
    SharedPreferences prefs = await _getPrefs();

    return prefs.getKeys().where((key) => key.contains(baseKey)).isEmpty;
  }

  @override
  Future<LoginInfo> read() async {
    SharedPreferences prefs = await _getPrefs();

    bool skippedLogin = prefs.getBool("$baseKey.$skippedLoginKey");

    return LoginInfo(
      skippedLogin: skippedLogin,
    );
  }

  @override
  Future<void> write(LoginInfo info) async {
    SharedPreferences prefs = await _getPrefs();

    await prefs.setBool("$baseKey.$skippedLoginKey", info.skippedLogin);
  }

  /// Get shared preferences.
  Future<SharedPreferences> _getPrefs() async => await SharedPreferences.getInstance();
}
