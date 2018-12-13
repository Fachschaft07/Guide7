import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:guide7/connect/credential/local_credentials_repository.dart';
import 'package:guide7/model/credentials/username_password_credentials.dart';

/// Repository managing local username and password credentials.
class LocalUsernamePasswordCredentialsRepository implements LocalCredentialsRepository<UsernamePasswordCredentials> {
  /// Key used to retrieve a username from secure storage.
  static const String _usernameKey = "username";

  /// Key used to retrieve a password from secure storage.
  static const String _passwordKey = "password";

  /// Secure storage to write to and read from.
  static final FlutterSecureStorage _storage = FlutterSecureStorage();

  @override
  Future<UsernamePasswordCredentials> loadLocalCredentials() async {
    String username = await _storage.read(key: _usernameKey);
    String password = await _storage.read(key: _passwordKey);

    return UsernamePasswordCredentials(username: username, password: password);
  }

  @override
  Future<void> storeLocalCredentials(UsernamePasswordCredentials credentials) async {
    await _storage.write(key: _usernameKey, value: credentials.username);
    await _storage.write(key: _passwordKey, value: credentials.password);
  }
}
