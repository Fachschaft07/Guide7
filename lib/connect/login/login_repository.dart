import 'dart:async';

import 'package:guide7/model/credentials/credentials.dart';

/// Repository managing login to some kind of service.
abstract class LoginRepository<T extends Credentials, R> {
  /// Try to login using the provided [credentials].
  /// Returns null if login not successful.
  Future<R> tryLogin(T credentials);

  /// Try to logout the user.
  /// Return whether the logout was successful.
  Future<bool> tryLogout(R response);

  /// Whether user is currently logged in.
  bool isLoggedIn();

  /// Get the login response.
  R getLogin();
}
