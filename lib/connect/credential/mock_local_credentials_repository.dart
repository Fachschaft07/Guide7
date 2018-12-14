import 'package:guide7/connect/credential/local_credentials_repository.dart';
import 'package:guide7/model/credentials/username_password_credentials.dart';

/// Local credentials repository used for tests.
class MockLocalCredentialsRepository implements LocalCredentialsRepository<UsernamePasswordCredentials> {
  /// Locally cached credentials.
  static UsernamePasswordCredentials _credentials;

  @override
  Future<UsernamePasswordCredentials> loadLocalCredentials() async => _credentials;

  @override
  Future<void> storeLocalCredentials(UsernamePasswordCredentials credentials) async => _credentials = credentials;

  @override
  Future<void> clearLocalCredentials() => _credentials = null;
}
