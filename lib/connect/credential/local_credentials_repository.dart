import 'package:guide7/model/credentials/credentials.dart';

/// Interface for repositories managing local credentials.
abstract class LocalCredentialsRepository<T extends Credentials> {
  /// Get credentials for local user.
  Future<T> loadLocalCredentials();

  /// Store credentials for local user.
  Future<void> storeLocalCredentials(T credentials);

  /// Clear currently stored credentials.
  Future<void> clearLocalCredentials();
}
